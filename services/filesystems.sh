#!/bin/sh
export PATH=/usr/bin:/usr/sbin:/bin:/sbin

if [ "$1" != "stop" ]; then
  echo "Mounting auxiliary filesystems...."
  swapon /swapfile 2>/dev/null || true
  mount -avt noproc,nonfs 2>/dev/null || true
fi
