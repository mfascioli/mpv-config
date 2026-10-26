# Removes uosc from the mpv config directory.
#
# - Deletes scripts/uosc, fonts/uosc_icons.otf and fonts/uosc_textures.ttf.
# - Deletes script-opts/uosc.conf unless -KeepConf is given.
# - Never touches mpv.conf, input.conf, the other scripts or Merriweather.
# - The built-in OSC (script-opts/osc.conf) takes over on the next launch.
#
# Usage (from the mpv config directory, where this file lives):
#   powershell -ExecutionPolicy Bypass -File .\uninstall-uosc.ps1
#   powershell -ExecutionPolicy Bypass -File .\uninstall-uosc.ps1 -KeepConf
#   powershell -ExecutionPolicy Bypass -File .\uninstall-uosc.ps1 -ConfigDir "C:\path\to\mpv"

[CmdletBinding()]
param(
    [string]$ConfigDir = $PSScriptRoot,
    [switch]$KeepConf
)

$ErrorActionPreference = 'Stop'

$targets = @(
    (Join-Path $ConfigDir 'scripts/uosc'),
    (Join-Path $ConfigDir 'fonts/uosc_icons.otf'),
    (Join-Path $ConfigDir 'fonts/uosc_textures.ttf')
)
if (-not $KeepConf) { $targets += (Join-Path $ConfigDir 'script-opts/uosc.conf') }

$removed = $false
foreach ($target in $targets) {
    if (Test-Path $target) {
        Remove-Item $target -Recurse -Force
        Write-Host "removed: $target"
        $removed = $true
    }
}

if ($KeepConf -and (Test-Path (Join-Path $ConfigDir 'script-opts/uosc.conf'))) {
    Write-Host "kept: $(Join-Path $ConfigDir 'script-opts/uosc.conf')"
}

if ($removed) {
    Write-Host "uosc uninstalled. The built-in OSC (script-opts/osc.conf) is used again."
} else {
    Write-Host "uosc was not installed in $ConfigDir"
}
