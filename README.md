# PES 2021 + Sider on a headless Linux server

These are the steps I used to install BMPES 15.0 AIO (or any sider compatible mod) and update 15.10 on my
headless Debian server, then launch eFootball PES 2021 through Steam with
Sider and Proton Experimental. No desktop environment is needed on the
server. The graphical installers ran in a temporary Xvfb session viewed
over an SSH tunnel; the game uses its normal Steam display.

This repository contains instructions and my small Steam wrapper. It does
**not** contain PES 2021, BMPES, Sider binaries, Windows installers, Proton
prefixes, save files, or passwords. Obtain those from their respective
sources.

## Host-specific paths

| Item | Path or value |
| --- | --- |
| Steam AppID | `1259970` |
| Game directory | `/srv/storage/games/steam/steamapps/common/eFootball PES 2021` |
| Proton prefix | `/srv/storage/games/steam/steamapps/compatdata/1259970/pfx` |
| Proton | `~/.steam/debian-installation/steamapps/common/Proton - Experimental/proton` |
| Steam launch wrapper | `~/scripts/start-pes-via-sider.sh` |

Change these paths if your Steam library differs. The wrapper checks Steam's
exact game path and stops if it does not match.

## Procedure

1. Confirm PES starts from Steam with Proton Experimental before applying
   BMPES. Back up the game and save data as needed.
2. Follow [Headless Windows installers](docs/headless-installers.md) to install
   BMPES 15.0 AIO Parts 01, 02, and 03, followed by update 15.10 Parts 01
   and 02. The Save installers target the existing save directory in the
   Proton prefix, while the other parts target the game directory.
3. Stop the temporary VNC, Openbox, and Xvfb `:99` session after installation.
   Leave unrelated Xvfb displays and Steam processes alone.
4. Follow [Start Sider through Steam](docs/sider-steam.md) to add
   `start.game = "PES2021.exe"` to the existing `sider.ini`, install the
   wrapper, and set Steam Launch Options.
5. Verify fresh `sider-app.log` and `sider.log` timestamps and confirm the
   BMPES content inside the game.

The native `sider7-linux` ptrace injector was tested but is **not** used by
this working setup. Steam starts `sider.exe`, which initializes and then
launches `PES2021.exe` through Sider's `start.game` option.

## Keeping only my changes

This repository tracks the wrapper and instructions only. I keep my actual
BMPES `sider.ini` and its many `cpk.root`/`lua.module` lines with the
game files, not in Git. The documented one-line `start.game` change is the
part needed for this launch method. No upstream Sider or Proton source was
modified.

The launch wrapper installed at `~/scripts/start-pes-via-sider.sh` is a copy
of [start-pes-via-sider.sh](start-pes-via-sider.sh). If I change that installed
copy, I copy it back into this repository and review `git diff` before
committing. This repository can stay private.
