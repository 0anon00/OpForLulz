#!/bin/sh

export HOME=/home PATH=/bin:/sbin

mountpoint -q proc || mount -t proc proc proc
mountpoint -q sys || mount -t sysfs sys sys
if ! mountpoint -q dev; then
  mount -t devtmpfs dev dev || mdev -s
  for i in ,fd /0,stdin /1,stdout /2,stderr
  do ln -sf /proc/self/fd${i/,*/} dev/${i/*,/}; done
  mkdir -p dev/{shm,pts}
  mountpoint -q dev/pts || mount -t devpts dev/pts dev/pts
  chmod +t /dev/shm
fi

sleep 2
echo ""
echo "Operation ForLulz would like to welcome you."
/bin/sh
umount /dev/pts /dev /sys /proc
