#!/bin/sh

SRC_PATH=$PWD/gdp-src-build/tmp/deploy/images/porter
TARGET_DEV="/dev/sdc"
TARGET_DEV_PART=${TARGET_DEV}1
MNT_POINT="/mnt"

echo "mount SD..."
sudo mount $TARGET_DEV_PART $MNT_POINT

echo "clean SD..."
sudo rm -rf $MNT_POINT/*

echo "extact package to SD..."
sudo tar --extract --numeric-owner --preserve-permissions --preserve-order --totals \
	 --directory=$MNT_POINT --file=$SRC_PATH/genivi-dev-platform-porter.tar.bz2 
sudo cp --remove-destination $SRC_PATH/uImage $SRC_PATH/uImage-r8a7791-porter.dtb $MNT_POINT/boot

echo "tweak sshd config..."
for config in sshd_config sshd_config_readonly; do
	if [ -e $MNT_POINT/etc/ssh/$config ]; then
		sudo sed -i 's/^PermitEmptyPasswords.*/#PermitEmptyPasswords yes/' $MNT_POINT/etc/ssh/$config
	fi
done

echo "sync..."
sync

echo "umount SD..."
sudo umount $MNT_POINT
