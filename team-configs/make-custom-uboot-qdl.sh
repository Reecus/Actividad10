#!/bin/bash
# Script for uboot build with custom image 
# Original author: Francesco Montefoschi <francesco.monte@gmail.com>
# License: GNU GPL version 2

ubootrepo="https://github.com/UDOOboard/uboot-imx.git"
ubootdir="temp_uboot"
binarydir="$(pwd)/boards/udoo-qdl"
logo="$(pwd)/team-configs/logo.bmp"
customlogomk="$(pwd)/team-configs/Makefile"

targetfile="uboot.imx"

BLUE="\e[34m"

echo -e "${BLUE}Removing default uboot-imx...${RST}" >&1 >&2
rm -rf $binarydir/$targetfile

echo -e "${BLUE}Downloading U-Boot sources...${RST}" >&1 >&2
git clone $ubootrepo $ubootdir
cd $ubootdir
git checkout 2015.10.fslc-qdl
#Cambios sobre el repo para usar el logo
echo -e "${BLUE}Adding custom logo...${RST}" >&1 >&2
cp -f $logo tools/logos/
echo -e "${BLUE}Replacing tool's makefile..${RST}" >&1 >&2
cp -f $customlogomk tools/
 
ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make clean
ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make udoo_qdl_defconfig
ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j8
cd -

if [ ! -e $ubootdir/SPL ]; then
    echo -e "${GREENBOLD}SPL file missing! Check build messages for errors.${RST}" >&1 >&2
    exit 1
fi

if [ ! -e $ubootdir/u-boot.img ]; then
    echo -e "${GREENBOLD}u-boot.img file missing! Check build messages for errors.${RST}" >&1 >&2
    exit 1
fi

truncate $binarydir/$targetfile --size 500k
dd if=$ubootdir/SPL of=$binarydir/$targetfile bs=1K seek=0 conv=notrunc
dd if=$ubootdir/u-boot.img of=$binarydir/$targetfile bs=1K seek=68

rm -rf $ubootdir 

#echo -e "${BLUE}U-Boot compiled in $ubootdir. ${RST}" >&1 >&2
echo -e "${GREENBOLD}Your u-boot is in $binarydir/$targetfile. ${RST}" >&1 >&2

