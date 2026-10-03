# Run graphical Windows installers on a headless host

Use this guide only if your mod ships with a graphical Windows installer.
Run **host** commands as your normal Linux user; **client** means your
computer. These examples use X display `:99` and VNC port `5902`. Choose
unused numbers if either is occupied.

## 1. Locate the game and Proton (host)

Replace the example game path with your Steam library path. Adjust the Steam
client and Proton locations if yours differ:

```bash
game_dir='/path/to/steam-library/steamapps/common/eFootball PES 2021'
steam_client="$HOME/.steam/debian-installation"
proton="$steam_client/steamapps/common/Proton - Experimental/proton"
steamapps_dir=$(dirname -- "$(dirname -- "$game_dir")")
compat_data="$steamapps_dir/compatdata/1259970"

test -f "$game_dir/PES2021.exe"
test -d "$compat_data/pfx"
test -x "$proton"
```

If a check fails, find your actual paths before continuing. Use the Proton
version and compatibility prefix that already launch your game. Make a backup
and check free space before installing a mod.

## 2. Start a temporary display (host)

Install `Xvfb`, `openbox`, and `x11vnc`. On Debian based systems:

```bash
sudo apt update
sudo apt install xvfb openbox x11vnc
```

Create a separate VNC password. Do not reuse an SSH or sudo password.
Traditional VNC password authentication has an eight character limit; keep
the VNC service bound to loopback and connect through SSH.

```bash
mkdir -p "$HOME/.vnc"
chmod 700 "$HOME/.vnc"
x11vnc -storepasswd
chmod 600 "$HOME/.vnc/passwd"
```

In a terminal you can keep open:

```bash
Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp \
  > /tmp/pes-install-xvfb.log 2>&1 &
xvfb_pid=$!

DISPLAY=:99 openbox > /tmp/pes-install-openbox.log 2>&1 &
openbox_pid=$!

x11vnc -display :99 -localhost -rfbport 5902 -forever -shared \
  -rfbauth "$HOME/.vnc/passwd" > /tmp/pes-install-vnc.log 2>&1 &
vnc_pid=$!

printf 'Xvfb=%s Openbox=%s x11vnc=%s\n' \
  "$xvfb_pid" "$openbox_pid" "$vnc_pid"
```

Record the PIDs. A blank desktop is normal until an installer opens. The
VNC listener is local to the host, so no router or firewall port is needed.

## 3. Connect the viewer (client)

Replace `<user>` and `<host>` with your SSH login and server address:

```bash
ssh -N -L 5902:127.0.0.1:5902 <user>@<host>
```

Leave the tunnel running. Point a VNC viewer to `127.0.0.1:5902` and use
the VNC password created above. On macOS, you can open Screen Sharing with:

```bash
open 'vnc://127.0.0.1:5902'
```

## 4. Run the installers under Proton (host)

In another host terminal, set the variables from step 1 again if necessary.
Then set the display and the game's existing Steam paths:

```bash
export DISPLAY=:99
export STEAM_COMPAT_DATA_PATH="$compat_data"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$steam_client"

installer='/path/to/mod/installer.exe'
cd -- "$(dirname -- "$installer")"
"$proton" run "./$(basename -- "$installer")"
```

Replace `installer` with the actual executable. Run each part in the order
given by the mod author and wait for it to finish. Keep multipart installer
files together in their original directory.

An installer may target the **game directory** or a **save directory inside
the Proton prefix**. Inspect the existing save tree under
`"$compat_data/pfx/drive_c/users"`; do not guess a save destination. Proton
usually exposes Linux paths to Windows programs under `Z:\\`.

Read any installer errors. A file sharing violation can mean another process
has the file open. Close installers and mod launchers before testing the game.

## 5. Close the temporary display

Close the installer and viewer. Stop the client SSH tunnel with Ctrl+C. In
the original host terminal, stop only the PIDs you recorded:

```bash
kill -TERM "$vnc_pid" "$openbox_pid" "$xvfb_pid"
```

If that shell is gone, identify the exact `:99` and VNC processes first:

```bash
ps -eo pid,comm,args |
  awk '$2=="Xvfb" || $2=="x11vnc" || $2=="openbox" {print}'
ss -ltnp | grep -E ':5902([[:space:]]|$)' || true
```

Other X displays may belong to Steam or unrelated services. Leave the
game's Proton prefix intact; it may contain saves and settings.
