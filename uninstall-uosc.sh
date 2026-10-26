#!/usr/bin/env bash
# Removes uosc from the mpv config directory.
#
# - Deletes scripts/uosc, fonts/uosc_icons.otf and fonts/uosc_textures.ttf.
# - Deletes script-opts/uosc.conf unless --keep-conf is given.
# - Never touches mpv.conf, input.conf, the other scripts or Merriweather.
# - The built-in OSC (script-opts/osc.conf) takes over on the next launch.

set -eu

config_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
keep_conf=0

usage() {
    cat <<'EOF'
Usage: bash uninstall-uosc.sh [options]

  --config-dir <path>  mpv config directory (default: the directory of this script)
  --keep-conf          keep script-opts/uosc.conf (your settings) for later
  -h, --help           show this help
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --config-dir) config_dir="$2"; shift 2 ;;
        --keep-conf) keep_conf=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
done

removed=0
for path in \
    "$config_dir/scripts/uosc" \
    "$config_dir/fonts/uosc_icons.otf" \
    "$config_dir/fonts/uosc_textures.ttf"
do
    if [ -e "$path" ]; then
        rm -rf "$path"
        echo "removed: $path"
        removed=1
    fi
done

conf="$config_dir/script-opts/uosc.conf"
if [ -e "$conf" ]; then
    if [ "$keep_conf" -eq 1 ]; then
        echo "kept: $conf"
    else
        rm -f "$conf"
        echo "removed: $conf"
        removed=1
    fi
fi

if [ "$removed" -eq 0 ]; then
    echo "uosc was not installed in $config_dir"
else
    echo "uosc uninstalled. The built-in OSC (script-opts/osc.conf) is used again."
fi
