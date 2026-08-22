<#
    Read-only health dashboard for every mod in the workspace. Touches nothing - safe to run anytime.

    Per mod it reports:
        Ver     <Version> from src/*.csproj
        Dist    is dist/<Mod>-<Ver>.zip present (mod's own dist/ or the shared root dist/)?
        Git     count of uncommitted changes in the mod's repo
        Remote  ahead/behind its upstream (+ahead / -behind), or 'no upstream'
        Sync    do pack.ps1 and Directory.Build.props match the tools/ canonicals? else which drift
        (retired mods are flagged and skipped for Sync)

    Usage:
        pwsh tools/status-mods.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$Retired = @('BiggerUI')

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$root     = Split-Path -Parent $toolsDir
$modsDir  = Join-Path $root 'mods'
$rootDist = Join-Path $root 'dist'
if (-not (Test-Path $modsDir)) { throw "No mods/ directory at $modsDir" }

$sha = [System.Security.Cryptography.SHA256]::Create()
function Get-Sha([string]$path) {
    if (-not (Test-Path $path)) { return $null }
    [BitConverter]::ToString($sha.ComputeHash([System.IO.File]::ReadAllBytes($path)))
}

# Canonical hashes for the synced shared files.
$canonical = @{
    'pack.ps1'              = Get-Sha (Join-Path $toolsDir 'pack.template.ps1')
    'Directory.Build.props' = Get-Sha (Join-Path $toolsDir 'Directory.Build.props')
}

$rows = foreach ($mod in Get-ChildItem $modsDir -Directory | Sort-Object Name) {
    $name       = $mod.Name
    $isRetired  = $Retired -contains $name

    $csproj = Get-ChildItem -Path (Join-Path $mod.FullName 'src') -Filter '*.csproj' -File `
        -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $csproj) { continue }  # not a mod project

    $version = @(([xml](Get-Content $csproj.FullName)).Project.PropertyGroup.Version | Where-Object { $_ })
    $version = if ($version.Count -eq 1) { $version[0] } else { '??' }

    # Dist: zip for the current version, in the mod's own dist/ or the shared root dist/.
    $zipName = "$name-$version.zip"
    $hasDist = (Test-Path (Join-Path $mod.FullName "dist\$zipName")) -or (Test-Path (Join-Path $rootDist $zipName))

    # Git: uncommitted count + ahead/behind upstream. --no-optional-locks keeps this strictly
    # read-only (plain 'git status' can refresh .git/index).
    $statusOut = git --no-optional-locks -C $mod.FullName status --porcelain 2>$null
    $gitCol = if ($LASTEXITCODE -ne 0) { 'git error' }
              elseif ($statusOut)      { "$(@($statusOut).Count) changed" }
              else                     { 'clean' }

    $remote = 'no upstream'
    $counts = git --no-optional-locks -C $mod.FullName rev-list --left-right --count '@{upstream}...HEAD' 2>$null
    if ($LASTEXITCODE -eq 0 -and $counts) {
        $behind, $ahead = $counts -split '\s+'
        $parts = @()
        if ([int]$ahead -gt 0)  { $parts += "+$ahead" }   # commits to push
        if ([int]$behind -gt 0) { $parts += "-$behind" }  # commits to pull
        $remote = if ($parts.Count) { $parts -join ' ' } else { 'up to date' }
    }

    # Sync drift vs canonicals (retired mods opt out).
    if ($isRetired) {
        $sync = 'retired'
    }
    else {
        $off = @()
        foreach ($f in 'pack.ps1', 'Directory.Build.props') {
            if ((Get-Sha (Join-Path $mod.FullName $f)) -ne $canonical[$f]) { $off += $f }
        }
        $sync = if ($off.Count) { $off -join ',' } else { 'ok' }
    }

    [PSCustomObject]@{
        Mod    = $name
        Ver    = $version
        Dist   = if ($hasDist) { 'yes' } else { 'no' }
        Git    = $gitCol
        Remote = $remote
        Sync   = $sync
    }
}

$rows | Format-Table -AutoSize | Out-Host

$drifted = @($rows | Where-Object { $_.Sync -ne 'ok' -and $_.Sync -ne 'retired' })
$dirtyMods = @($rows | Where-Object { $_.Git -like '*changed*' })
Write-Host ("Summary: {0} mods, {1} with drift, {2} with uncommitted changes." -f `
    $rows.Count, $drifted.Count, $dirtyMods.Count)
if ($drifted.Count) { Write-Host "  Drift -> run tools/sync-mod-files.ps1: $(($drifted.Mod) -join ', ')" }
