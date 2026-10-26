#!/usr/bin/env bash
# Installs or updates uosc from its official GitHub release (CachyOS/Arch).
#
# - Downloads the latest uosc.zip into this config directory:
#   scripts/uosc, fonts/uosc_icons.otf, fonts/uosc_textures.ttf.
# - Keeps your existing script-opts/uosc.conf; only downloads it when missing
#   (use --force to replace it with the defaults).
# - Never touches mpv.conf, input.conf, the other scripts or Merriweather.
# - Verifies the SHA-256 that GitHub publishes for uosc.zip (and for uosc.conf
#   when it installs it) before replacing anything; --no-verify skips the check.
# - Uses curl and bsdtar (libarchive), both part of the Arch base install.
#   If one is missing it offers to install that package only, with your
#   package manager (yay, paru or pacman). Nothing else is installed.

set -euo pipefail

release="https://github.com/tomasklaen/uosc/releases/latest/download"
api_url="https://api.github.com/repos/tomasklaen/uosc/releases/latest"
license_url="https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/LICENSE.LGPL"
config_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
force=0
assume_yes=0
verify=1

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

  --config-dir <path>  existing mpv config directory (default: directory of this script)
  --force              replace script-opts/uosc.conf with the defaults
  -y, --yes            install a missing tool (curl/libarchive) without asking
  --no-verify          skip the SHA-256 check (not recommended)
  -h, --help           show this help
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --config-dir) config_dir="$2"; shift 2 ;;
        --force) force=1; shift ;;
        -y|--yes) assume_yes=1; shift ;;
        --no-verify) verify=0; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1" ;;
    esac
done

[ -n "$config_dir" ] || die "--config-dir cannot be empty"
[ -d "$config_dir" ] || die "config directory not found: $config_dir"
config_dir="$(cd "$config_dir" && pwd)"
[ "$config_dir" != "/" ] || die "refusing to use / as the mpv config directory"

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

download() {
    curl --proto '=https' --proto-redir '=https' --tlsv1.2 \
        --connect-timeout 15 --max-time 300 --max-filesize 52428800 \
        -fsSL "$1" -o "$2"
}

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# SHA-256 published by GitHub for each release asset, e.g. "sha256:4be9..."
asset_digest() {
    awk -v want="$1" '
        index($0, "\"name\": \"" want "\"") { found = 1; next }
        found && /"digest": "sha256:/ {
            line = $0
            sub(/.*"digest": "sha256:/, "", line)
            sub(/".*/, "", line)
            print line
            exit
        }
        found && /"name": "/ { found = 0 }
    ' "$work/release.json"
}

verify_checksum() {
    expected="$1"
    file="$2"
    label="$3"
    if have sha256sum; then
        actual="$(sha256sum "$file" | awk '{print $1}')"
    elif have shasum; then
        actual="$(shasum -a 256 "$file" | awk '{print $1}')"
    elif have openssl; then
        actual="$(openssl dgst -sha256 "$file" | awk '{print $NF}')"
    else
        die "no SHA-256 tool found (sha256sum, shasum or openssl)"
    fi
    if [ "$actual" != "$expected" ]; then
        die "SHA-256 mismatch for $label (expected $expected, got $actual); nothing was changed"
    fi
}

if [ "$verify" -eq 1 ]; then
    echo "uosc: fetching the release checksums..."
    if ! download "$api_url" "$work/release.json"; then
        die "could not fetch release metadata from api.github.com (rate limit?); rerun with --no-verify to skip the checksum"
    fi
    zip_sha="$(asset_digest uosc.zip)"
    [ -n "$zip_sha" ] || die "the latest release does not publish a SHA-256 for uosc.zip; rerun with --no-verify to skip the checksum"
fi

echo "uosc: downloading the latest official release..."
download "$release/uosc.zip" "$work/uosc.zip"
if [ "$verify" -eq 1 ]; then
    verify_checksum "$zip_sha" "$work/uosc.zip" "uosc.zip"
    echo "uosc: checksum verified"
fi
bsdtar -xf "$work/uosc.zip" -C "$work"

[ -f "$work/scripts/uosc/main.lua" ] || die "unexpected archive layout: scripts/uosc/main.lua not found"
[ -d "$work/fonts" ] || die "unexpected archive layout: fonts/ not found"

rm -rf "$config_dir/scripts/uosc"
mkdir -p "$config_dir/scripts" "$config_dir/fonts"
cp -r "$work/scripts/uosc" "$config_dir/scripts/uosc"

# Keep the LGPL notice next to the code (not a release asset, so no digest)
if download "$license_url" "$work/LICENSE.LGPL"; then
    cp "$work/LICENSE.LGPL" "$config_dir/scripts/uosc/LICENSE.LGPL"
else
    echo "warning: could not download LICENSE.LGPL" >&2
fi

cp "$work"/fonts/* "$config_dir/fonts/"

conf="$config_dir/script-opts/uosc.conf"
if [ "$force" -eq 1 ] || [ ! -f "$conf" ]; then
    if [ "$verify" -eq 1 ]; then
        conf_sha="$(asset_digest uosc.conf)"
        [ -n "$conf_sha" ] || die "the latest release does not publish a SHA-256 for uosc.conf; rerun with --no-verify to skip the checksum"
    fi
    download "$release/uosc.conf" "$work/uosc.conf"
    if [ "$verify" -eq 1 ]; then
        verify_checksum "$conf_sha" "$work/uosc.conf" "uosc.conf"
    fi
    mkdir -p "$config_dir/script-opts"
    cp "$work/uosc.conf" "$conf"
    echo "uosc: uosc.conf installed"
else
    echo "uosc: kept existing uosc.conf"
fi

version="$(sed -n "s/.*uosc_version = '\([^']*\)'.*/\1/p" "$config_dir/scripts/uosc/main.lua" | head -n1)"
echo "uosc $version installed in $config_dir"
