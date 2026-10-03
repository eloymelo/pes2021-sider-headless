# Install BMPES without a desktop environment

This procedure ran on Debian 13 (`phantom`) with a macOS client. All
`SERVER` commands run as the normal user (`eloy`), not root, except
package installation. The temporary VNC service binds to loopback, so the
Mac connects through SSH.

## 1. Check the existing Steam game and prerequisites (SERVER)

```bash
game='/srv/storage/games/steam/steamapps/common/eFootball PES 2021'
test -f "$game/PES2021.exe"
test -d /srv/storage/games/steam/steamapps/compatdata/1259970/pfx
test -x "$HOME/.steam/debian-installation/steamapps/common/Proton - Experimental/proton"
command -v Xvfb
command -v openbox
command -v x11vnc
```

If the three display utilities are absent on a Debian host:

```bash
sudo apt update
sudo apt install xvfb openbox x11vnc
```

Keep using the Proton version and prefix that already run this Steam game.
Check free disk space before installing the mod.

## 2. Create a separate VNC password (SERVER, once)

```bash
mkdir -p "$HOME/.vnc"
chmod 700 "$HOME/.vnc"
x11vnc -storepasswd
chmod 600 "$HOME/.vnc/passwd"
```

Use a separate VNC password. Do not reuse the SSH or sudo password. The
traditional VNC authentication protocol considers only the first eight
password characters. Keep the password file out of this repository.

## 3. Start a temporary display (SERVER)

```bash
Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp \
  > /tmp/bmpes-xvfb.log 2>&1 &
xvfb_pid=$!

DISPLAY=:99 openbox > /tmp/bmpes-openbox.log 2>&1 &
openbox_pid=$!

x11vnc -display :99 -localhost -rfbport 5902 -forever -shared \
  -rfbauth "$HOME/.vnc/passwd" > /tmp/bmpes-vnc.log 2>&1 &
vnc_pid=$!

printf 'Xvfb=%s Openbox=%s x11vnc=%s\n' \
  "$xvfb_pid" "$openbox_pid" "$vnc_pid"
```

Keep this terminal open, or save the three PIDs. If `:99` or `5902`
is already in use, inspect the existing processes first rather than
starting duplicates.

## 4. Connect from macOS

Leave this running in a Mac Terminal, replacing `<server-address>`:

```bash
ssh -N -L 5902:127.0.0.1:5902 eloy@<server-address>
```

In another Mac Terminal:

```bash
open 'vnc://127.0.0.1:5902'
```

Enter the VNC password from step 2. Openbox can show a black screen
until an installer opens. No LAN/router VNC rule is necessary because
`x11vnc` is bound to loopback.

## 5. Run the installers in order (SERVER, another SSH terminal)

```bash
export DISPLAY=:99
export STEAM_COMPAT_DATA_PATH='/srv/storage/games/steam/steamapps/compatdata/1259970'
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/debian-installation"
PROTON="$HOME/.steam/debian-installation/steamapps/common/Proton - Experimental/proton"

cd '/srv/storage/downloads/Bmpes 15.0 ( Versão AIO )/Instalador da atualização/Parte 01'
"$PROTON" run './Bmpes Instalador.part001.exe'
```

Wait for each installer to finish. Launch the next executable from its
own directory, keeping adjacent multipart data together:

| Order | Installer | Target chosen inside installer |
| --- | --- | --- |
| 1 | BMPES 15.0 AIO, `Parte 01/Bmpes Instalador.part001.exe` | Game directory |
| 2 | BMPES 15.0 AIO, `Parte 02/Versão da Database.exe` | Game directory |
| 3 | BMPES 15.0 AIO, `Parte 03 ( Save )/Parte 03 ( Save ).exe` | Existing PES save directory in Proton prefix |
| 4 | Update 15.10, `Parte 01/Instalador BMPES.part01.exe` | Game directory |
| 5 | Update 15.10, `Parte 02 ( Save )/Save.exe` | Existing PES save directory in Proton prefix |

The source folders are beneath `/srv/storage/downloads/Bmpes 15.0
( Versão AIO )/Instalador da atualização` and
`/srv/storage/downloads/Atualização 15.10/Instalador da atualização`.
The installed PES save directory is inside the Proton prefix, not the game
directory; inspect its existing `Documents/KONAMI/.../save` tree before
choosing a path. Proton exposes Linux files to Windows installers under
`Z:\\`, for example `Z:\\srv\\storage\\games\\steam\\steamapps\\common\\eFootball PES 2021`.

Read each installer's final message. A file-sharing violation is a real
file access error, not evidence that the absence of a desktop environment
caused it. The optional `BMPES Launcher.exe` was not needed in this
working setup. A launcher left running in the Proton prefix had earlier
prevented a subsequent Steam launch; close it normally before testing
the game.

## 6. Shut down the temporary session

Close the Windows installer and its Proton process. On the Mac, close
Screen Sharing and press Ctrl+C in the SSH tunnel terminal. In the
original SERVER terminal:

```bash
kill -TERM "$vnc_pid" "$openbox_pid" "$xvfb_pid"
```

If that shell is gone, first identify the exact `:99`/VNC processes:

```bash
ps -eo pid,comm,args |
  awk '$2=="Xvfb" || $2=="x11vnc" || $2=="openbox" {print}'
ss -ltnp | grep -E ':59[0-9][0-9]([[:space:]]|$)' || true
```

Terminate only the processes associated with display `:99` and its VNC
port. An unrelated Xvfb process may belong to Steam. Verify the `:99`
processes and VNC listener disappear. Leave game files and the Proton
prefix intact.
