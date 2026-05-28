# dinit-gentoo

Gentoo-compatible dinit service files. These are based on the example services
from the [dinit source](https://github.com/davmac314/dinit) with all the fixes
needed to actually boot on Gentoo with btrfs and systemd-udevd.

## What was fixed

| File | Problem | Fix |
|------|---------|-----|
| `udevd` | Pointed to `/sbin/udevd` (eudev) | Changed to `/usr/lib/systemd/systemd-udevd` |
| `tty1-6` | `/sbin/agetty` doesn't exist | Changed to `/usr/bin/agetty` |
| `rootfscheck.sh` | Calls fsck on btrfs, always fails | Replaced with no-op `exit 0` |
| `auxfscheck` | `fsck` non-zero exit kills boot with `set -e` | Made non-fatal with `; true` |
| `filesystems.sh` | `swapon /swapfile` fails if no swapfile, `set -e` kills boot | Removed `set -e`, made swapon non-fatal |
| `loginready` | Depended on `syslogd` which isn't installed | Removed syslogd dependency |
| `rcboot.sh` | `/sbin/ifconfig`, hardcoded hostname "myhost", `mkdir /var/run/dbus` fails if exists | Fixed paths, hostname, added `|| true` to mkdir |

## Requirements

- Gentoo Linux
- btrfs root filesystem (if ext4, edit rootfscheck.sh to re-enable fsck)
- systemd-udevd (standard on modern Gentoo, NOT eudev)
- dinit built from source: https://github.com/davmac314/dinit

## Install

```sh
# 1. Build and install dinit
cd /tmp
git clone https://github.com/davmac314/dinit
cd dinit
make
sudo make install

# 2. Install service files
git clone https://github.com/YOUR_USERNAME/dinit-gentoo
cd dinit-gentoo
sudo sh install.sh

# 3. Edit your hostname in rcboot.sh
sudo nano /etc/dinit.d/rcboot.sh

# 4. Add Limine boot entry (edit /boot/efi/limine.conf):
# /Gentoo Linux (dinit)
#     protocol: linux
#     kernel_path: boot():/vmlinuz
#     cmdline: root=/dev/sdXY rw quiet init=/usr/bin/dinit
```

## Hyprland without a display manager

Add to `~/.bash_profile`:

```sh
export XDG_RUNTIME_DIR=/run/user/$(id -u)
mkdir -p $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR
```

Make sure your user is in the `video` and `input` groups:

```sh
sudo usermod -aG video,input YOUR_USERNAME
```

Then just login on tty1 and run `Hyprland`.

## WiFi with wpa_supplicant

First configure your network:

```sh
sudo wpa_passphrase "YourSSID" "YourPassword" > /etc/wpa_supplicant/wpa_supplicant.conf
```

Then edit `services/wpa_supplicant` and change `wlp4s0` to your actual wifi interface (`ip link` to find it). Add it to boot.d:

```sh
sudo cp services/wpa_supplicant /etc/dinit.d/
sudo ln -s ../wpa_supplicant /etc/dinit.d/boot.d/wpa_supplicant
```

## elogind (recommended for Hyprland)

elogind handles seat management, which Hyprland needs for proper GPU access, screen locking, and power management. It only uses ~1-3MB RAM so worth running.

```sh
sudo emerge elogind
sudo cp services/elogind /etc/dinit.d/
sudo ln -s ../elogind /etc/dinit.d/boot.d/elogind
```

Also add elogind as a dependency of loginready:

```sh
# Add this line to /etc/dinit.d/loginready:
# waits-for: elogind
```

With elogind running you no longer need the `XDG_RUNTIME_DIR` workaround in `~/.bash_profile` — elogind sets it automatically on login.

## Notes

- No display manager required — just login on tty1 and run `Hyprland`
- sshd is not auto-started at boot (add symlink to boot.d if you want it)
- elogind is optional but recommended for Hyprland users
