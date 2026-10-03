# Start Sider before PES through Steam

The successful setup uses the installed `sider.exe` and `sider.dll`
from BMPES, not the experimental `sider7-linux` ptrace injector.

## 1. Check files and save the configuration

```bash
game='/srv/storage/games/steam/steamapps/common/eFootball PES 2021'
ls -l "$game/PES2021.exe" "$game/sider.exe" "$game/sider.dll" "$game/sider.ini"
cp -a "$game/sider.ini" "$game/sider.ini.backup-$(date +%Y%m%d-%H%M%S)"
```

Edit the *existing* `sider.ini` in the game directory. In its
`[sider]` section, add this line exactly once:

```ini
start.game = "PES2021.exe"
```

For this BMPES installation, it sits next to:

```ini
close.on.exit = 0
start.minimized = 1
start.game = "PES2021.exe"
```

Preserve every existing `cpk.root`, `lua.module`, and other mod setting.
Do not replace the BMPES file with a generic Sider sample. Verify:

```bash
grep -niE '^[[:space:]]*start[.]game[[:space:]]*=' "$game/sider.ini"
```

Sider's `start.game` option runs the game after Sider initializes.
The Steam wrapper changes into the game directory so the relative
`PES2021.exe` path resolves.

## 2. Install this repository's wrapper

From a checkout of this repository:

```bash
mkdir -p "$HOME/scripts"
install -m 0755 start-pes-via-sider.sh "$HOME/scripts/start-pes-via-sider.sh"
bash -n "$HOME/scripts/start-pes-via-sider.sh"
```

The wrapper receives Steam's usual `%command%` arguments, verifies the
expected PES path, replaces that executable with `sider.exe`, and
executes the same Steam/Proton command. Sider launches PES itself.

## 3. Set Steam Launch Options

In Steam: eFootball PES 2021 -> Properties -> General -> Launch Options:

```text
"/home/eloy/scripts/start-pes-via-sider.sh" %command%
```

Keep Proton Experimental selected for this game. Do not combine this
Launch Options entry with the old native-injector script. Start the game.

## 4. Verify the mod loaded

```bash
game='/srv/storage/games/steam/steamapps/common/eFootball PES 2021'
stat -c '%y %n' "$game/sider-app.log" "$game/sider.log"
tail -n 30 "$game/sider-app.log"
tail -n 35 "$game/sider.log"
```

On the successful 2026-10-03 launch, `sider-app.log` reported Sider App
7.3.3, `Main: Init DONE`, and `start.game: PES2021.exe`. A fresh
`sider.log` showed BMPES Lua modules and kit data processing. Finally,
confirm the mod appears in the game.

The preserved `close.on.exit = 0` means Sider may stay open after PES
exits. If Steam still displays Playing, close Sider normally.

## Rollback and troubleshooting

- To return to vanilla Steam launching, clear the game's Launch Options.
- Restore the appropriate timestamped `sider.ini.backup-...` file if needed.
- If Sider starts but PES does not, check `start.game` and the fresh
  `sider-app.log`.
- If PES starts without BMPES, check the fresh `sider.log` and existing
  mod paths/files.
- If the wrapper reports an unexpected command, inspect the actual
  executable Steam passes and update `game_dir` in the wrapper only
  after confirming the intended path.
- If the abandoned native injector interpreter still carries
  `cap_sys_ptrace=eip`, and it is no longer used, revoke that capability:

```bash
/usr/sbin/getcap "$HOME/sider7-linux/.venv/bin/sider-inject-python"
sudo setcap -r "$HOME/sider7-linux/.venv/bin/sider-inject-python"
/usr/sbin/getcap "$HOME/sider7-linux/.venv/bin/sider-inject-python"
```

The last command should print nothing. Skip the capability commands if
that interpreter no longer exists. The current Sider/Steam method is
independent of it.
