#!/bin/sh
export PATH=/usr/bin:/usr/sbin:/bin:/sbin
umask 0077

if [ "$1" != "stop" ]; then
  # Cleanup /tmp
  rm -rf /tmp/* /tmp/.[!.]* /tmp/..?*

  # Empty utmp
  : > /var/run/utmp

  # Create /var/run/dbus if it doesn't exist (|| true so it won't fail if already there)
  mkdir -m og-w /var/run/dbus 2>/dev/null || true

  # Create /run/user so user sessions can create their XDG_RUNTIME_DIR
  mkdir -p /run/user
  chmod 755 /run/user

  # Configure random number generator
  if [ -e /var/state/random-seed ]; then
    cat /var/state/random-seed > /dev/urandom
  fi

  # Configure loopback
  /usr/bin/ifconfig lo 127.0.0.1

  # Set hostname (change this to match your hostname)
  echo "gentoo" > /proc/sys/kernel/hostname

else
  # Shutdown - save random seed
  POOLSIZE="$(cat /proc/sys/kernel/random/poolsize)"
  dd if=/dev/urandom of=/var/state/random-seed bs="$POOLSIZE" count=1 2>/dev/null
fi
