# Installs or updates uosc from its official GitHub release.
#
# - Downloads the latest release (uosc.zip) and extracts it into this config
#   directory: scripts/uosc, fonts/uosc_icons.otf, fonts/uosc_textures.ttf.
# - Keeps your existing script-opts/uosc.conf; only downloads it when missing
#   (use -Force to replace it with the defaults).
# - Never touches mpv.conf, input.conf, the other scripts or Merriweather.
# - The archive is checked (HTTPS only, expected layout) before the previous
#   uosc is removed, so a broken download cannot leave you without a UI.
#
# Usage (from the mpv config directory, where this file lives):
#   powershell -ExecutionPolicy Bypass -File .\install-uosc.ps1
#   powershell -ExecutionPolicy Bypass -File .\install-uosc.ps1 -ConfigDir "C:\path\to\mpv"
#   powershell -ExecutionPolicy Bypass -File .\install-uosc.ps1 -Force

[CmdletBinding()]
param(
    [string]$ConfigDir,
    [switch]$Force
)

# Resolve the default here: with [CmdletBinding()] and -File, PowerShell 5.1
# still has $PSScriptRoot empty while the parameters are being bound.
if (-not $PSBoundParameters.ContainsKey('ConfigDir')) {
    $ConfigDir = $PSScriptRoot
}

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue' # much faster downloads, no console progress bar

# Windows PowerShell 5.1 can still negotiate TLS 1.0, which GitHub rejects.
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {
    # Newer runtimes already pick a modern protocol on their own
}

function New-Directory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        [IO.Directory]::CreateDirectory($Path) | Out-Null
    }
}

function Get-File([string]$Uri, [string]$OutFile) {
    if (([Uri]$Uri).Scheme -ne 'https') {
        throw "refusing a non-HTTPS download: $Uri"
    }
    # -OutFile treats brackets as wildcards, so download to a plain name first
    $download = Join-Path $script:work ('download-' + [guid]::NewGuid().ToString('N'))
    try {
        Invoke-WebRequest -Uri $Uri -OutFile $download -UseBasicParsing -TimeoutSec 300
        if ((Get-Item -LiteralPath $download).Length -gt 52428800) {
            throw "download is larger than 50 MB, refusing: $Uri"
        }
        [IO.File]::Copy($download, $OutFile, $true)
    } finally {
        if (Test-Path -LiteralPath $download) {
            Remove-Item -LiteralPath $download -Force
        }
    }
}

# Refuse paths that would make the cleanup sweep too wide.
if ([string]::IsNullOrWhiteSpace($ConfigDir)) {
    throw 'config directory cannot be empty; pass -ConfigDir'
}
$full = [IO.Path]::GetFullPath($ConfigDir)
if ($full.TrimEnd('\', '/') -eq [IO.Path]::GetPathRoot($full).TrimEnd('\', '/')) {
    throw "refusing to use the filesystem root as the mpv config directory: $full"
}
$ConfigDir = $full.TrimEnd('\', '/')
if (-not (Test-Path -LiteralPath $ConfigDir -PathType Container)) {
    throw "config directory not found: $ConfigDir (create it first or pass -ConfigDir)"
}

$release = 'https://github.com/tomasklaen/uosc/releases/latest/download'
$work = Join-Path $env:TEMP ('uosc-install-' + [guid]::NewGuid().ToString('N'))

Write-Host "uosc: downloading the latest official release..."
New-Directory $work
try {
    Get-File "$release/uosc.zip" (Join-Path $work 'uosc.zip')
    try {
        Expand-Archive -LiteralPath (Join-Path $work 'uosc.zip') -DestinationPath $work -Force
    } catch {
        throw "could not extract uosc.zip (corrupt archive or unsafe paths): $($_.Exception.Message)"
    }

    # Check the layout *before* deleting anything
    $source = Join-Path $work 'scripts/uosc'
    $sourceFonts = Join-Path $work 'fonts'
    if (-not (Test-Path -LiteralPath (Join-Path $source 'main.lua') -PathType Leaf)) {
        throw 'unexpected archive layout: scripts/uosc/main.lua not found; nothing was changed'
    }
    if (-not (Test-Path -LiteralPath $sourceFonts -PathType Container)) {
        throw 'unexpected archive layout: fonts/ not found; nothing was changed'
    }

    # Replace the script (removes leftovers from older versions)
    $scripts = Join-Path $ConfigDir 'scripts'
    $uosc = Join-Path $scripts 'uosc'
    New-Directory $scripts
    if (Test-Path -LiteralPath $uosc) {
        Remove-Item -LiteralPath $uosc -Recurse -Force
    }
    Copy-Item -LiteralPath $source -Destination $scripts -Recurse -Force

    # Keep the LGPL notice next to the code
    try {
        Get-File 'https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/LICENSE.LGPL' (Join-Path $uosc 'LICENSE.LGPL')
    } catch {
        Write-Warning "uosc: could not download LICENSE.LGPL ($($_.Exception.Message))"
    }

    # Icon font, next to any other fonts (e.g. Merriweather)
    $fonts = Join-Path $ConfigDir 'fonts'
    New-Directory $fonts
    Get-ChildItem -LiteralPath $sourceFonts -File | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $fonts -Force
    }

    # Default options, only if the user does not have their own yet
    $conf = Join-Path $ConfigDir 'script-opts/uosc.conf'
    if ($Force -or -not (Test-Path -LiteralPath $conf)) {
        New-Directory (Split-Path $conf)
        Get-File "$release/uosc.conf" $conf
        Write-Host "uosc: uosc.conf installed"
    } else {
        Write-Host "uosc: kept existing uosc.conf"
    }

    $main = Join-Path $uosc 'main.lua'
    $version = (Select-String -LiteralPath $main -Pattern "uosc_version = '([^']+)'" | Select-Object -First 1).Matches[0].Groups[1].Value
    Write-Host "uosc $version installed in $ConfigDir"
} finally {
    if (Test-Path -LiteralPath $work) {
        Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}
