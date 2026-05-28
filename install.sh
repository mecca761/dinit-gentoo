#!/bin/sh
# dinit-gentoo install script
# Run as root: sudo sh install.sh

set -e

echo "Installing dinit service files for Gentoo..."

# Create directories
mkdir -p /etc/dinit.d/boot.d
mkdir -p /var/state
mkdir -p /var/log

# Copy all service files and scripts
cp services/boot          /etc/dinit.d/
cp services/rcboot.sh     /etc/dinit.d/
cp services/rootfscheck   /etc/dinit.d/
cp services/rootfscheck.sh /etc/dinit.d/
cp services/filesystems   /etc/dinit.d/
cp services/filesystems.sh /etc/dinit.d/
cp services/auxfscheck    /etc/dinit.d/
cp services/loginready    /etc/dinit.d/
cp services/udevd         /etc/dinit.d/
cp services/tty1          /etc/dinit.d/
cp services/tty2          /etc/dinit.d/
cp services/tty3          /etc/dinit.d/
cp services/tty4          /etc/dinit.d/
cp services/tty5          /etc/dinit.d/
cp services/tty6          /etc/dinit.d/
cp services/wpa_supplicant /etc/dinit.d/
cp services/elogind       /etc/dinit.d/

# Copy remaining services from dinit source (these don't need patching)
# Assumes you've cloned dinit to /tmp/dinit
if [ -d /tmp/dinit/doc/linux/services ]; then
  for svc in early-filesystems early-filesystems.sh late-filesystems late-filesystems.sh \
              modules modules.sh rootrw hwclock udev-trigger udev-settle \
              dbusd sshd recovery single; do
    [ -f /tmp/dinit/doc/linux/services/$svc ] && \
      cp /tmp/dinit/doc/linux/services/$svc /etc/dinit.d/
  done
fi

# Make scripts executable
chmod +x /etc/dinit.d/rcboot.sh
chmod +x /etc/dinit.d/rootfscheck.sh
chmod +x /etc/dinit.d/filesystems.sh

# Set up boot.d symlinks
ln -sf ../late-filesystems /etc/dinit.d/boot.d/late-filesystems
ln -sf ../modules          /etc/dinit.d/boot.d/modules

echo ""
echo "Done! Now:"
echo "1. Edit /etc/dinit.d/rcboot.sh and set your hostname"
echo "2. Add to /boot/efi/limine.conf:"
echo ""
echo "   /Gentoo Linux (dinit)"
echo "       protocol: linux"
echo "       kernel_path: boot():/vmlinuz"
echo "       cmdline: root=/dev/sdXY rw quiet init=/usr/bin/dinit"
echo ""
echo "3. Add to ~/.bash_profile for Hyprland without a display manager:"
echo "   export XDG_RUNTIME_DIR=/run/user/\$(id -u)"
echo "   mkdir -p \$XDG_RUNTIME_DIR && chmod 700 \$XDG_RUNTIME_DIR"
