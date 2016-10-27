#!/bin/bash
RAMDISK=$1
BOOTIMG=$2
SELINUX=$3
if [ -z $1 ] && [ -z $2 ]; then	
	echo "Usage: build.sh <ramdisk image> <bootimg> <option>"
	echo "Build the kernel using the specified ramdisk image"
	echo "the second argument set the bootimg program location"
	echo "Use the option -p to build the image with a permissive kernel"
	exit 1
fi
if [ ! -f $1 ]; then
	echo "Ramdisk image not found"
	exit 1
fi
if [ ! -f $1 ]; then
	echo "bootimage not found"
	exit 1
fi
echo "Cleaning old build."
rm ~/xkernel.img -f
make mrproper
echo "Setting up the enviroment."
export USE_CCACHE=1
export ARCH=arm64
export PATH=~/aarch64-linux-android-4.9-kernel/bin/:$PATH
export CROSS_COMPILE=aarch64-linux-android-
make xkernel_defconfig
echo "Starting to build the kernel image."
make 
if [ $SELINUX = "-p" ]; then
	echo "Packing permissive kernel and ramdisk."
	$BOOTIMG mkimg --cmdline "androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 boot_cpus=0-5 dwc3_msm.prop_chg_detect=Y coherent_pool=2M dwc3_msm.hvdcp_max_current=1500 androidboot.selinux=permissive" --base 0x00000000 --kernel arch/arm64/boot/Image.gz-dtb --ramdisk $RAMDISK --ramdisk_offset 0x02000000 --pagesize 4096 -o ~/xkernel_permissive.img --tags_offset 0x01E00000
	echo "Xkernel Permissive has been built successfully."
else
	echo "Packing kernel and ramdisk."
	$BOOTIMG mkimg --cmdline "androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 boot_cpus=0-5 dwc3_msm.prop_chg_detect=Y coherent_pool=2M dwc3_msm.hvdcp_max_current=1500" --base 0x00000000 --kernel arch/arm64/boot/Image.gz-dtb --ramdisk $RAMDISK --ramdisk_offset 0x02000000 --pagesize 4096 -o ~/xkernel.img --tags_offset 0x01E00000
	echo "Xkernel has been built successfully."
fi

