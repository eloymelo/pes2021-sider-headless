# PES 2021 Sider mods on a headless Linux host

Install a Windows based PES 2021 mod without a desktop environment on the
host, then launch the game through Steam with Sider running first. Mods with
no graphical installer can skip the temporary display steps.

This method was used with the Steam release of eFootball PES 2021 (AppID
`1259970`) and Proton Experimental on Debian. Your paths, Proton version,
installer names, and installation order may differ. Follow the mod author's
instructions for the files and destinations.

This repository contains a small Steam launch script and instructions. It
does not include the game, a mod, Sider binaries, installers, Proton prefixes,
save data, or credentials.

## The approach

1. If your mod has a graphical Windows installer, run it under Proton in a
   temporary `Xvfb` display. View it through VNC over an SSH tunnel, then
   close the display when installation is complete.
2. Add `start.game = "PES2021.exe"` to your existing `sider.ini`. Preserve
   the mod's other settings.
3. Set Steam Launch Options to run this repository's wrapper with
   `%command%`. The wrapper preserves Steam's Proton command, starts
   `sider.exe` in place of `PES2021.exe`, and Sider starts the game.

The wrapper expects `sider.exe` beside `PES2021.exe` in the Steam game
directory. If your mod uses a different layout, adapt the wrapper and
`start.game` path to that layout.

## Before you begin

- Confirm the game starts normally from Steam with your chosen Proton version
  before installing the mod. Keep using that version and compatibility prefix.
- Back up the game, relevant saves, and any existing `sider.ini`.
- Obtain the game and mod from sources you trust. Read the mod's own
  instructions for installation order and target directories.
- For remote graphical installation, have SSH access to the host and a VNC
  viewer on your client computer.

## Guides

- [Run graphical Windows installers on a headless host](docs/headless-installers.md)
- [Start Sider before PES 2021 through Steam](docs/sider-steam.md)

If the mod is already installed, start with the second guide. The wrapper
checks the final executable supplied by Steam and refuses an unexpected
command. It does not modify game files or manage the temporary display.

Keep downloaded mod assets, your `sider.ini`, and private files outside this
repository. Only the reusable instructions and launch script belong here.
