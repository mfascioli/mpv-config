#!/usr/bin/env bash
# Installs or updates uosc from its official GitHub release (macOS).
#
# - Downloads the latest uosc.zip into this config directory:
#   scripts/uosc, fonts/uosc_icons.otf, fonts/uosc_textures.ttf.
# - Keeps your existing script-opts/uosc.conf; only downloads it when missing
#   (use --force to replace it with the defaults).
# - Never touches mpv.conf, input.conf, the other scripts or Merriweather.
# - Uses only curl and unzip, which ship with macOS. Nothing is installed.

set -euo pipefail

release="https://github.com/tomasklaen/uosc/releases/latest/download"
license_url="https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/LICENSE.LGPL"
config_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
force=0

die() {
    echo "error: $*" >&2
    exit 1
}

have() {
    command -v "$1" >/dev/null 2>&1
}

usage() {
    cat <<'EOF'
Usage: bash install-uosc-macos.sh [options]

  --config-dir <path>  existing mpv config directory (default: directory of this script)
  --force              replace script-opts/uosc.conf with the defaults
  -h, --help           show this help
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --config-dir) config_dir="$2"; shift 2 ;;
        --force) force=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1" ;;
    esac
done

[ -n "$config_dir" ] || die "--config-dir cannot be empty"
[ -d "$config_dir" ] || die "config directory not found: $config_dir"
config_dir="$(cd "$config_dir" && pwd)"
[ "$config_dir" != "/" ] || die "refusing to use / as the mpv config directory"

[ "$(uname -s)" = "Darwin" ] \
    || die "this installer is for macOS; use install-uosc.ps1 (Windows), install-uosc-ubuntu.sh or install-uosc-cachyos.sh"

have curl || die "curl not found, but it ships with macOS; install mpv and the command line tools first"
have unzip || die "unzip not found, but it ships with macOS; install mpv and the command line tools first"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "uosc: downloading the latest official release..."
curl --proto '=https' --proto-redir '=https' --tlsv1.2 \
    --connect-timeout 15 --max-time 300 --max-filesize 52428800 \
    -fsSL "$release/uosc.zip" -o "$work/uosc.zip"
unzip -q "$work/uosc.zip" -d "$work"

[ -f "$work/scripts/uosc/main.lua" ] || die "unexpected archive layout: scripts/uosc/main.lua not found"
[ -d "$work/fonts" ] || die "unexpected archive layout: fonts/ not found"

rm -rf "$config_dir/scripts/uosc"
mkdir -p "$config_dir/scripts" "$config_dir/fonts"
cp -r "$work/scripts/uosc" "$config_dir/scripts/uosc"

# Keep the LGPL notice next to the code
curl --proto '=https' --proto-redir '=https' --tlsv1.2 \
    --connect-timeout 15 --max-time 300 --max-filesize 52428800 \
    -fsSL "$license_url" -o "$config_dir/scripts/uosc/LICENSE.LGPL" \
    || echo "warning: could not download LICENSE.LGPL" >&2

cp "$work"/fonts/* "$config_dir/fonts/"

conf="$config_dir/script-opts/uosc.conf"
if [ "$force" -eq 1 ] || [ ! -f "$conf" ]; then
    mkdir -p "$config_dir/script-opts"
    curl --proto '=https' --proto-redir '=https' --tlsv1.2 \
        --connect-timeout 15 --max-time 300 --max-filesize 52428800 \
        -fsSL "$release/uosc.conf" -o "$conf"
    echo "uosc: uosc.conf installed"
else
    echo "uosc: kept existing uosc.conf"
fi

version="$(sed -n "s/.*uosc_version = '\([^']*\)'.*/\1/p" "$config_dir/scripts/uosc/main.lua" | head -n1)"
echo "uosc $version installed in $config_dir"
