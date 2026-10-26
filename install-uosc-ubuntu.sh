#!/usr/bin/env bash
# Installs or updates uosc from its official GitHub release (Ubuntu/Debian).
#
# - Downloads the latest uosc.zip into this config directory:
#   scripts/uosc, fonts/uosc_icons.otf, fonts/uosc_textures.ttf.
# - Keeps your existing script-opts/uosc.conf; only downloads it when missing
#   (use --force to replace it with the defaults).
# - Never touches mpv.conf, input.conf, the other scripts or Merriweather.
# - Uses curl or wget and unzip. If one of them is missing it offers to install
#   that package only, with apt. Nothing else is installed.

set -euo pipefail

release="https://github.com/tomasklaen/uosc/releases/latest/download"
license_url="https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/LICENSE.LGPL"
config_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
force=0
assume_yes=0

die() {
    echo "error: $*" >&2
    exit 1
}

have() {
    command -v "$1" >/dev/null 2>&1
}

usage() {
    cat <<'EOF'
Usage: bash install-uosc-ubuntu.sh [options]

  --config-dir <path>  existing mpv config directory (default: directory of this script)
  --force              replace script-opts/uosc.conf with the defaults
  -y, --yes            install a missing tool (curl/unzip) without asking
  -h, --help           show this help
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --config-dir) config_dir="$2"; shift 2 ;;
        --force) force=1; shift ;;
        -y|--yes) assume_yes=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1" ;;
    esac
done

[ -n "$config_dir" ] || die "--config-dir cannot be empty"
[ -d "$config_dir" ] || die "config directory not found: $config_dir"
config_dir="$(cd "$config_dir" && pwd)"
[ "$config_dir" != "/" ] || die "refusing to use / as the mpv config directory"

[ -r /etc/os-release ] || die "cannot read /etc/os-release; this installer is for Ubuntu/Debian"
# shellcheck source=/dev/null
. /etc/os-release
case " ${ID:-} ${ID_LIKE:-} " in
    *ubuntu*|*debian*) ;;
    *) die "this installer is for Ubuntu/Debian (detected: ${PRETTY_NAME:-unknown}); use install-uosc-cachyos.sh or install-uosc-macos.sh" ;;
esac

# Install only the named package(s), and only after asking
install_packages() {
    if [ "$assume_yes" -eq 0 ]; then
        printf 'missing: %s. Install with apt? [Y/n] ' "$*"
        if ! read -r answer; then
            echo
            die "no answer; run again with --yes to install it"
        fi
        case "$answer" in
            [nN]*) die "aborted; install them yourself with: sudo apt-get install $*" ;;
        esac
    fi
    if [ "$(id -u)" -eq 0 ]; then
        apt-get install -y --no-install-recommends "$@"
    elif have sudo; then
        sudo apt-get install -y --no-install-recommends "$@"
    else
        die "cannot install $*: run as root or install it with: sudo apt-get install $*"
    fi
}

if have curl; then
    download() {
        curl --proto '=https' --proto-redir '=https' --tlsv1.2 \
            --connect-timeout 15 --max-time 300 --max-filesize 52428800 \
            -fsSL "$1" -o "$2"
    }
elif have wget; then
    download() {
        wget --https-only --max-redirect=5 --timeout=30 --tries=3 -qO "$2" "$1"
    }
else
    install_packages curl
    download() {
        curl --proto '=https' --proto-redir '=https' --tlsv1.2 \
            --connect-timeout 15 --max-time 300 --max-filesize 52428800 \
            -fsSL "$1" -o "$2"
    }
fi

if ! have unzip; then
    install_packages unzip
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "uosc: downloading the latest official release..."
download "$release/uosc.zip" "$work/uosc.zip"
unzip -q "$work/uosc.zip" -d "$work"

[ -f "$work/scripts/uosc/main.lua" ] || die "unexpected archive layout: scripts/uosc/main.lua not found"
[ -d "$work/fonts" ] || die "unexpected archive layout: fonts/ not found"

rm -rf "$config_dir/scripts/uosc"
mkdir -p "$config_dir/scripts" "$config_dir/fonts"
cp -r "$work/scripts/uosc" "$config_dir/scripts/uosc"

# Keep the LGPL notice next to the code
download "$license_url" "$config_dir/scripts/uosc/LICENSE.LGPL" \
    || echo "warning: could not download LICENSE.LGPL" >&2

cp "$work"/fonts/* "$config_dir/fonts/"

conf="$config_dir/script-opts/uosc.conf"
if [ "$force" -eq 1 ] || [ ! -f "$conf" ]; then
    mkdir -p "$config_dir/script-opts"
    download "$release/uosc.conf" "$conf"
    echo "uosc: uosc.conf installed"
else
    echo "uosc: kept existing uosc.conf"
fi

version="$(sed -n "s/.*uosc_version = '\([^']*\)'.*/\1/p" "$config_dir/scripts/uosc/main.lua" | head -n1)"
echo "uosc $version installed in $config_dir"
