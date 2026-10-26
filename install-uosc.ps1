# Installs or updates uosc from its official GitHub release.
#
# - Downloads the latest release (uosc.zip) and extracts it into this config
#   directory: scripts/uosc, fonts/uosc_icons.otf, fonts/uosc_textures.ttf.
# - Keeps your existing script-opts/uosc.conf; only downloads it when missing
#   (use -Force to replace it with the defaults).
# - Never touches mpv.conf, input.conf, the other scripts or Merriweather.
#
# Usage (from the mpv config directory, where this file lives):
#   powershell -ExecutionPolicy Bypass -File .\install-uosc.ps1
#   powershell -ExecutionPolicy Bypass -File .\install-uosc.ps1 -ConfigDir "C:\path\to\mpv"
#   powershell -ExecutionPolicy Bypass -File .\install-uosc.ps1 -Force

[CmdletBinding()]
param(
    [string]$ConfigDir = $PSScriptRoot,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue' # much faster downloads, no console progress bar

# Windows PowerShell 5.1 can still negotiate TLS 1.0, which GitHub rejects.
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {
    # Newer runtimes already pick a modern protocol on their own
}

$release = 'https://github.com/tomasklaen/uosc/releases/latest/download'
$work = Join-Path $env:TEMP ('uosc-install-' + [guid]::NewGuid().ToString('N'))

Write-Host "uosc: downloading the latest official release..."
New-Item -ItemType Directory -Force -Path $work | Out-Null
try {
    Invoke-WebRequest "$release/uosc.zip" -OutFile (Join-Path $work 'uosc.zip') -UseBasicParsing
    Expand-Archive (Join-Path $work 'uosc.zip') -DestinationPath $work -Force

    # Replace the script (removes leftovers from older versions)
    $scripts = Join-Path $ConfigDir 'scripts'
    $uosc = Join-Path $scripts 'uosc'
    if (Test-Path $uosc) { Remove-Item $uosc -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $scripts | Out-Null
    Copy-Item (Join-Path $work 'scripts/uosc') $scripts -Recurse -Force

    # Keep the LGPL notice next to the code
    try {
        Invoke-WebRequest 'https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/LICENSE.LGPL' -OutFile (Join-Path $uosc 'LICENSE.LGPL') -UseBasicParsing
    } catch {
        Write-Warning "uosc: could not download LICENSE.LGPL ($($_.Exception.Message))"
    }

    # Icon font, next to any other fonts (e.g. Merriweather)
    $fonts = Join-Path $ConfigDir 'fonts'
    New-Item -ItemType Directory -Force -Path $fonts | Out-Null
    Copy-Item (Join-Path $work 'fonts/*') $fonts -Force

    # Default options, only if the user does not have their own yet
    $conf = Join-Path $ConfigDir 'script-opts/uosc.conf'
    if ($Force -or -not (Test-Path $conf)) {
        New-Item -ItemType Directory -Force -Path (Split-Path $conf) | Out-Null
        Invoke-WebRequest "$release/uosc.conf" -OutFile $conf -UseBasicParsing
        Write-Host "uosc: uosc.conf installed"
    } else {
        Write-Host "uosc: kept existing uosc.conf"
    }

    $main = Join-Path $uosc 'main.lua'
    $version = (Select-String -Path $main -Pattern "uosc_version = '([^']+)'" | Select-Object -First 1).Matches[0].Groups[1].Value
    Write-Host "uosc $version installed in $ConfigDir"
} finally {
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
}
