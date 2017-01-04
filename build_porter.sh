#!/bin/bash

function print_and_exit()
{
	printf "\E[1;31;40m"
	echo $1
	printf "\E[0m"
	echo " "
	exit 1
}

PORTER_PATH="$PWD/meta-renesas/meta-rcar-gen2"
PORTER_GLES_USER_PATH="$PORTER_PATH/recipes-graphics/gles-module/gles-user-module"
PORTER_MM_PATH="$PORTER_PATH/recipes-multimedia"

. ./init.sh porter

echo " "
if [ ! -f $PORTER_GLES_USER_PATH/r8a7791_linux_sgx_binaries_gles2.tar.bz2 ]; then
	print_and_exit "Please complete copy_gfx_software_porter.sh in meta-renesas!!!"
fi

if [ ! -f $PORTER_MM_PATH/fdpm-module/files/fdpm.tar.bz2 ]; then
	print_and_exit "Please complete copy_mm_software_lcb.sh in meta-renesas!!!"
fi

bitbake genivi-dev-platform
