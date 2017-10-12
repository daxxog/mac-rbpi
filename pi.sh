#!/bin/sh

#- {} raspberry pi install/run script for mac
#- {} requires brew
#- {} https://azeria-labs.com/emulate-raspberry-pi-with-qemu/

brew install qemu wget

if [ ! -f ./raspbian_latest ]
then
    wget https://downloads.raspberrypi.org/raspbian_latest
fi

if [ ! -f ./raspbian_latest.img ]
then
    unzip raspbian_latest
    mv *.img raspbian_latest.img
fi

if [ ! -f ./raspbian_latest.expanded.qcow2 ]
then
	EXTSTART=$(hdiutil imageinfo raspbian_latest.img | grep partition-start | sed -e '$!d' | sed 's/[^0-9]*//g')
	#mkdir mnt
	#sudo mount -v -o offset=$(($EXTSTART * 512)) -t ext4 ./raspbian_latest.img.mod ./mnt
    qemu-img convert -f raw -O qcow2 raspbian_latest.img raspbian_latest.expanded.qcow2
    qemu-img resize raspbian_latest.expanded.qcow2 16G
fi

if qemu-system-arm -machine help | grep raspi2
then
    echo "INFO: system ready for Raspberry Pi"
    qemu-system-arm -kernel ./qemu-rpi-kernel/kernel-qemu-4.4.34-jessie -cpu arm1176 -m 256 -M versatilepb -serial stdio -append "fsck.repair=yes rootwait root=/dev/sda2 rootfstype=ext4 rw" -hda ./raspbian_latest.expanded.qcow2 -no-reboot
    #qemu-system-arm -M versatilepb -cpu arm1176 -hda raspbian_latest.expanded.qcow2 -kernel zImage -m 192 -append "console=ttyAMA0 root=/dev/sda2 rootfstype=ext4 fsck.repair=yes rootwait init=/bin/sh" -nographic
    #qemu-system-arm -kernel zImage -append "console=ttyAMA0 root=/dev/sda2" -hda raspbian_latest.expanded.qcow2 -M versatilepb -cpu arm1176 -nographic
else
	echo "ERROR: qemu does not support raspi2!"
fi