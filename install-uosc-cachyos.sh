#!/usr/bin/env bash
# Installs or updates uosc from its official GitHub release (CachyOS/Arch).
#
# - Downloads the latest uosc.zip into this config directory:
#   scripts/uosc, fonts/uosc_icons.otf, fonts/uosc_textures.ttf.
# - Keeps your existing script-opts/uosc.conf; only downloads it when missing
#   (use --force to replace it with the defaults).
# - Never touches mpv.conf, input.conf, the other scripts or Merriweather.
# - Uses curl and bsdtar (libarchive), both part of the Arch base install.
#   If one is missing it offers to install that package only, with your
#   package manager (yay, paru or pacman). Nothing else is installed.

set -eu

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
Usage: bash install-uosc-cachyos.sh [options]

  --config-dir <path>  mpv config directory (default: the directory of this script)
  --force              replace script-opts/uosc.conf with the defaults
  -y, --yes            install a missing tool (curl/libarchive) without asking
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

[ -r /etc/os-release ] || die "cannot read /etc/os-release; this installer is for CachyOS/Arch"
# shellcheck source=/dev/null
. /etc/os-release
case " ${ID:-} ${ID_LIKE:-} " in
    *arch*|*cachyos*) ;;
    *) die "this installer is for CachyOS/Arch (detected: ${PRETTY_NAME:-unknown}); use install-uosc-ubuntu.sh or install-uosc-macos.sh" ;;
esac

# Install only the named package(s), and only after asking
install_packages() {
    if [ "$assume_yes" -eq 0 ]; then
        printf 'missing: %s. Install with the package manager? [Y/n] ' "$*"
        if ! read -r answer; then
            echo
            die "no answer; run again with --yes to install it"
        fi
        case "$answer" in
            [nN]*) die "aborted; install them yourself with: sudo pacman -S $*" ;;
        esac
    fi
    for manager in yay paru pacman; do
        have "$manager" || continue
        if [ "$manager" = pacman ]; then
            if [ "$(id -u)" -eq 0 ]; then
                pacman -S --needed --noconfirm "$@"
            elif have sudo; then
                sudo pacman -S --needed --noconfirm "$@"
            else
                die "cannot install $*: run as root or install it with: sudo pacman -S $*"
            fi
        else
            # yay and paru must not run as root; they ask for sudo themselves
            "$manager" -S --needed --noconfirm "$@"
        fi
        return 0
    done
    die "no package manager found (tried yay, paru, pacman)"
}

if ! have curl; then
    install_packages curl
fi
if ! have bsdtar; then
    install_packages libarchive
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "uosc: downloading the latest official release..."
curl -fsSL "$release/uosc.zip" -o "$work/uosc.zip"
bsdtar -xf "$work/uosc.zip" -C "$work"

[ -f "$work/scripts/uosc/main.lua" ] || die "unexpected archive layout: scripts/uosc/main.lua not found"
[ -d "$work/fonts" ] || die "unexpected archive layout: fonts/ not found"

rm -rf "$config_dir/scripts/uosc"
mkdir -p "$config_dir/scripts" "$config_dir/fonts"
cp -r "$work/scripts/uosc" "$config_dir/scripts/uosc"

# Keep the LGPL notice next to the code
curl -fsSL "$license_url" -o "$config_dir/scripts/uosc/LICENSE.LGPL" \
    || echo "warning: could not download LICENSE.LGPL" >&2

cp "$work"/fonts/* "$config_dir/fonts/"

conf="$config_dir/script-opts/uosc.conf"
if [ "$force" -eq 1 ] || [ ! -f "$conf" ]; then
    mkdir -p "$config_dir/script-opts"
    curl -fsSL "$release/uosc.conf" -o "$conf"
    echo "uosc: uosc.conf installed"
else
    echo "uosc: kept existing uosc.conf"
fi

version="$(sed -n "s/.*uosc_version = '\([^']*\)'.*/\1/p" "$config_dir/scripts/uosc/main.lua" | head -n1)"
echo "uosc $version installed in $config_dir"
