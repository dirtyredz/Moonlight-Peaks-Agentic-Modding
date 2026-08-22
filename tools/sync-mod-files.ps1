<#
    Keeps every mod's shared, generic files byte-identical to the workspace's canonical copies in
    tools/, so they can never drift. Each synced file is generic (no per-mod content), so "sync" is a
    plain byte-for-byte copy.

    Synced files (canonical in tools/  ->  path in each mod):
        pack.template.ps1      ->  pack.ps1                (generic packer)
        Directory.Build.props  ->  Directory.Build.props   (game paths + version target)

    Usage (from anywhere):
        pwsh tools/sync-mod-files.ps1          # write any out-of-date file into every mod
        pwsh tools/sync-mod-files.ps1 -Check   # report drift and exit 1 if any (no writes) - for CI

    A target is any directory under mods/ with a .csproj under src/, except mods named in $Retired.
#>

[CmdletBinding()]
param([switch]$Check)

$ErrorActionPreference = 'Stop'

# Mods that are retired / should not carry the standard shared files. See docs/FEATURES.md.
$Retired = @('BiggerUI')

# Canonical source (basename in tools/) -> destination path relative to each mod root.
$Files = @(
    @{ Source = 'pack.template.ps1';     Dest = 'pack.ps1' }
    @{ Source = 'Directory.Build.props'; Dest = 'Directory.Build.props' }
)

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root     = Split-Path -Parent $toolsDir
$modsDir  = Join-Path $root 'mods'
if (-not (Test-Path $modsDir)) { throw "No mods/ directory at $modsDir" }

$sha = [System.Security.Cryptography.SHA256]::Create()
function Get-Sha([byte[]]$bytes) { if ($null -eq $bytes) { return $null }; [BitConverter]::ToString($sha.ComputeHash($bytes)) }

# Load canonical bytes + hashes once.
foreach ($f in $Files) {
    $f.Path = Join-Path $toolsDir $f.Source
    if (-not (Test-Path $f.Path)) { throw "Canonical file not found: $($f.Path)" }
    $f.Bytes = [System.IO.File]::ReadAllBytes($f.Path)
    $f.Hash  = Get-Sha $f.Bytes
}

$drift = @()
foreach ($mod in Get-ChildItem $modsDir -Directory | Sort-Object Name) {
    if ($Retired -contains $mod.Name) { Write-Host "skip   $($mod.Name) (retired)"; continue }

    $csproj = Get-ChildItem -Path (Join-Path $mod.FullName 'src') -Filter '*.csproj' -File `
        -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $csproj) { Write-Host "skip   $($mod.Name) (no src/*.csproj)"; continue }

    foreach ($f in $Files) {
        $destPath    = Join-Path $mod.FullName $f.Dest
        $currentHash = if (Test-Path $destPath) { Get-Sha ([System.IO.File]::ReadAllBytes($destPath)) } else { $null }

        if ($currentHash -eq $f.Hash) { Write-Host "ok     $($mod.Name)/$($f.Dest)"; continue }

        $drift += "$($mod.Name)/$($f.Dest)"
        $tag = if ($null -eq $currentHash) { ' (missing)' } else { '' }
        if ($Check) {
            Write-Host "DRIFT  $($mod.Name)/$($f.Dest)$tag"
        }
        else {
            [System.IO.File]::WriteAllBytes($destPath, $f.Bytes)
            Write-Host "update $($mod.Name)/$($f.Dest)$tag"
        }
    }
}

Write-Host ''
if ($Check -and $drift.Count) {
    # -ErrorAction Continue so the explicit exit code below is reached under $ErrorActionPreference=Stop.
    Write-Error "drift in: $($drift -join ', '). Run tools/sync-mod-files.ps1 to fix." -ErrorAction Continue
    exit 1
}
$verb = if ($Check) { 'out of date' } else { 'updated' }
Write-Host "Done. $($drift.Count) file(s) $verb."
