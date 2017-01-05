#!/bin/sh

SRC_PATH=$PWD/gdp-src-build/tmp/deploy/images/porter

image_file=`date +%Y-%m-%d`-gdp11-4G.img
echo "create empty disk image..."
dd if=/dev/zero of=$image_file bs=1GB count=4
echo "create disk partitions for disk image..."
fdisk $image_file <<EOF
n
p



w
EOF

MNT_POINT=/tmp/mnt
MNT_POINT_ROOT=$MNT_POINT/root

echo "attach loop device..."
losetup -f $image_file
echo "format partition to ext4..."
mkfs.ext3 /dev/loop0p1

echo "mount disk image..."
mkdir -p $MNT_POINT_ROOT
mount /dev/loop0p1 $MNT_POINT_ROOT

echo "dump files to disk image..."
rm -rf $MNT_POINT_ROOT/*
tar --extract --numeric-owner --preserve-permissions --preserve-order --totals \
    --directory=$MNT_POINT_ROOT --file=$SRC_PATH/genivi-dev-platform-porter.tar.bz2
rm -rf $MNT_POINT_ROOT/boot/*
cp --remove-destination $SRC_PATH/uImage $SRC_PATH/uImage-r8a7791-porter.dtb $MNT_POINT_ROOT/boot

echo "tweak sshd config..."
for config in sshd_config sshd_config_readonly; do
	if [ -e $MNT_POINT_ROOT/etc/ssh/$config ]; then
		sudo sed -i 's/^PermitEmptyPasswords.*/#PermitEmptyPasswords yes/' $MNT_POINT_ROOT/etc/ssh/$config
	fi
done

echo "sync..."
sync
echo "umount disk image..."
umount $MNT_POINT_ROOT
rm -rf $MNT_POINT
echo "deattach loop device..."
losetup -d /dev/loop0
