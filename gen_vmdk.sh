#!/bin/sh


BUILD_PATH=$PWD/gdp-src-build/tmp
SRC_PATH=$BUILD_PATH/deploy/images/qemux86-64
MNT_POINT="/mnt"

hdddirect_file_path=`realpath $SRC_PATH/genivi-dev-platform-qemux86-64.hdddirect`
hdddirect_file=`basename $hdddirect_file_path`
vmdk_file="${hdddirect_file%.*}".vmdk

echo "copy raw disk image..."
cp -f $hdddirect_file_path .

echo "mount raw disk image..."
sudo kpartx -av $hdddirect_file
sleep 3
sudo mount /dev/mapper/loop0p2 $MNT_POINT

echo "tweak sshd config..."
for config in sshd_config sshd_config_readonly; do
	if [ -e $MNT_POINT/etc/ssh/$config ]; then
		sudo sed -i 's/^PermitEmptyPasswords.*/#PermitEmptyPasswords yes/' $MNT_POINT/etc/ssh/$config
	fi
done

echo "umount raw disk image..."
sudo umount $MNT_POINT
sudo kpartx -dv $hdddirect_file

# convert to VMDK
echo "convert raw disk image to VMDK..."
$BUILD_PATH/sysroots/x86_64-linux/usr/bin/qemu-img convert -O vmdk $hdddirect_file $vmdk_file
rm $hdddirect_file

echo "done..."
