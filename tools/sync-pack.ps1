<#
    Regenerates every mod's pack.ps1 from the single canonical template (tools/pack.template.ps1),
    so the copies can never drift. pack.ps1 is generic - the same bytes work in every mod - so
    "sync" is simply "write the template into each mod as pack.ps1".

    Usage (from anywhere):
        pwsh tools/sync-pack.ps1          # write the template into every mod that is out of date
        pwsh tools/sync-pack.ps1 -Check   # report drift and exit 1 if any (no writes) - for CI

    A target is any directory under mods/ that has a .csproj under src/, except mods named in
    $Retired below. Files are written UTF-8 without BOM so every copy is byte-identical to the
    template.
#>

[CmdletBinding()]
param([switch]$Check)

$ErrorActionPreference = 'Stop'

# Mods that are retired / should not carry the standard pack.ps1. See docs/FEATURES.md.
$Retired = @('BiggerUI')

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root     = Split-Path -Parent $toolsDir
$template = Join-Path $toolsDir 'pack.template.ps1'
$modsDir  = Join-Path $root 'mods'
if (-not (Test-Path $template)) { throw "Template not found at $template" }
if (-not (Test-Path $modsDir))  { throw "No mods/ directory at $modsDir" }

# Compare and copy at the byte level so "same" means byte-identical (encoding/BOM/case included),
# not merely text-equal.
$sha = [System.Security.Cryptography.SHA256]::Create()
function Get-FileHashBytes([byte[]]$bytes) { [BitConverter]::ToString($sha.ComputeHash($bytes)) }

$templateBytes = [System.IO.File]::ReadAllBytes($template)
$templateHash  = Get-FileHashBytes $templateBytes

$drift = @()
foreach ($mod in Get-ChildItem $modsDir -Directory | Sort-Object Name) {
    if ($Retired -contains $mod.Name) { Write-Host "skip   $($mod.Name) (retired)"; continue }

    $csproj = Get-ChildItem -Path (Join-Path $mod.FullName 'src') -Filter '*.csproj' -File `
        -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $csproj) { Write-Host "skip   $($mod.Name) (no src/*.csproj)"; continue }

    $packPath    = Join-Path $mod.FullName 'pack.ps1'
    $currentHash = if (Test-Path $packPath) { Get-FileHashBytes ([System.IO.File]::ReadAllBytes($packPath)) } else { $null }

    if ($currentHash -eq $templateHash) { Write-Host "ok     $($mod.Name)"; continue }

    $drift += $mod.Name
    $tag = if ($null -eq $currentHash) { ' (missing)' } else { '' }
    if ($Check) {
        Write-Host "DRIFT  $($mod.Name)$tag"
    }
    else {
        [System.IO.File]::WriteAllBytes($packPath, $templateBytes)
        Write-Host "update $($mod.Name)$tag"
    }
}

Write-Host ''
if ($Check -and $drift.Count) {
    # -ErrorAction Continue so the explicit exit code below is reached under $ErrorActionPreference=Stop.
    Write-Error "pack.ps1 drift in: $($drift -join ', '). Run tools/sync-pack.ps1 to fix." -ErrorAction Continue
    exit 1
}
$verb = if ($Check) { 'out of date' } else { 'updated' }
Write-Host "Done. $($drift.Count) mod(s) $verb."
