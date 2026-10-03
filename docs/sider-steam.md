# Start Sider before PES 2021 through Steam

This setup assumes your Sider based mod installs `sider.exe`, `sider.dll`,
and `sider.ini` next to the Steam game's `PES2021.exe`. The wrapper does not
provide these files. For a different layout, adapt the wrapper and
`start.game` path to the mod's instructions.

## 1. Preserve and edit your configuration

Set the real path to your Steam game:

```bash
game_dir='/path/to/steam-library/steamapps/common/eFootball PES 2021'
ls -l "$game_dir/PES2021.exe" "$game_dir/sider.exe" \
  "$game_dir/sider.dll" "$game_dir/sider.ini"
cp -a "$game_dir/sider.ini" \
  "$game_dir/sider.ini.backup-$(date +%Y%m%d-%H%M%S)"
```

In the existing `[sider]` section of `sider.ini`, add or update this one
setting:

```ini
start.game = "PES2021.exe"
```

Preserve the mod's `cpk.root`, `lua.module`, and other settings. Confirm
there is one active `start.game` line:

```bash
grep -niE '^[[:space:]]*start[.]game[[:space:]]*=' \
  "$game_dir/sider.ini"
```

The wrapper changes to the game directory before starting Sider, so this
relative executable name resolves there.

## 2. Install the wrapper

From this repository's directory:

```bash
mkdir -p "$HOME/scripts"
install -m 0755 start-pes-via-sider.sh \
  "$HOME/scripts/start-pes-via-sider.sh"
bash -n "$HOME/scripts/start-pes-via-sider.sh"
printf '%s\n' "$HOME/scripts/start-pes-via-sider.sh"
```

The last command prints **your** absolute wrapper path. The script expects
Steam's final executable argument to be an existing `PES2021.exe` and
`sider.exe` beside it. It preserves the rest of Steam's `%command%`,
including its Proton runner and game prefix.

## 3. Set Steam Launch Options

In **eFootball PES 2021 → Properties → General → Launch Options**, replace
the example path with the absolute path printed above:

```text
"/absolute/path/to/start-pes-via-sider.sh" %command%
```

Keep the Proton version that already starts your game. Steam starts Sider;
Sider's `start.game` setting starts PES 2021.

## 4. Verify the mod loaded

Look for fresh log timestamps after launching:

```bash
stat -c '%y %n' "$game_dir/sider-app.log" "$game_dir/sider.log"
tail -n 30 "$game_dir/sider-app.log"
tail -n 35 "$game_dir/sider.log"
```

Check for Sider initialization, `start.game`, and activity from the mod's
Lua modules or content paths. Confirm its effect in the game. Some Sider
configurations leave Sider open when the game exits; close it normally if
Steam still says the game is running.

## Troubleshooting and rollback

- If the wrapper rejects Steam's command, confirm the game executable and
  Launch Options before adjusting the script's safety check.
- If Sider starts but the game does not, check the active `start.game` value
  and fresh `sider-app.log`.
- If the game starts without the mod, inspect fresh `sider.log` and the
  mod's existing `cpk.root` and `lua.module` paths.
- To return to ordinary Steam launching, clear this Launch Options entry.
  If needed, restore the timestamped `sider.ini` backup.
