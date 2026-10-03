#!/usr/bin/env bash
set -euo pipefail

game_dir='/srv/storage/games/steam/steamapps/common/eFootball PES 2021'
game_exe="$game_dir/PES2021.exe"
sider_exe="$game_dir/sider.exe"

args=("$@")
if (( ${#args[@]} == 0 )); then
    echo 'Steam supplied no launch command.' >&2
    exit 1
fi

last=$((${#args[@]} - 1))
if [[ "${args[$last]}" != "$game_exe" ]]; then
    echo 'Unexpected Steam launch command; refusing to replace its executable.' >&2
    exit 1
fi

cd "$game_dir"
args[$last]="$sider_exe"
exec "${args[@]}"
