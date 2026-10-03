#!/usr/bin/env bash
set -euo pipefail

# Steam Launch Options: "/absolute/path/to/start-pes-via-sider.sh" %command%
args=("$@")
if (( ${#args[@]} == 0 )); then
    echo 'Steam supplied no launch command.' >&2
    exit 1
fi

last=$((${#args[@]} - 1))
game_exe="${args[$last]}"
if [[ "$(basename -- "$game_exe")" != 'PES2021.exe' || ! -f "$game_exe" ]]; then
    echo 'Expected an existing PES2021.exe as the final Steam argument.' >&2
    exit 1
fi

game_dir=$(dirname -- "$game_exe")
sider_exe="$game_dir/sider.exe"
if [[ ! -f "$sider_exe" ]]; then
    echo "Sider executable not found: $sider_exe" >&2
    exit 1
fi

cd -- "$game_dir"
args[$last]="$sider_exe"
exec "${args[@]}"
