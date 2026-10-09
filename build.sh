#!/bin/bash
# Script to build image for qemu or rpi3.
# Author: Siddhant Jajoo, Joshua Roberson 
#Usage: ./build.sh [qenu|rpi3] (defaults to qemu)

#exit script with error code if any commands fail

TARGET="${1:-qemu}"
BUILD_ENV="NONE"

# git submodule init
# git submodule sync
# git submodule update

add_conf_line(){
	local confline="$1"
	cat conf/local.conf | grep -F "${confline}" > /dev/null
	local_conf_info=$?

	if [ $local_conf_info -ne 0 ];then
		echo "Append ${confline} in the local.conf file"
		echo ${confline} >> conf/local.conf
		
	else
		echo "${confline} already exists in the local.conf file"
	fi
}

add_layer(){
	local layer_name="$1"
	local layer_path="$2"
	bitbake-layers show-layers | grep -F "${layer_name}" > /dev/null
	layer_info=$?

	if [ $layer_info -ne 0 ];then
		echo "Adding ${layer_name} layer"
		bitbake-layers add-layer "${layer_path}"
	else
		echo "${layer_name} layer already exists"
	fi
}

case "$TARGET" in
	qemu)
		MAC_CONFLINE="MACHINE = \"qemuarm64\""
		BUILD_ENV="build-qemu"
		;;
	rpi3)
		MAC_CONFLINE="MACHINE = \"raspberrypi3-64\""
		BUILD_ENV="build-rpi3"
		;;
	*)
		echo "Unknown target '${TARGET}'. Use 'qemu' or 'rpi3'"
		exit 1
		;;
esac

# local.conf won't exist until this step on first execution
source poky/oe-init-build-env ${BUILD_ENV}

add_conf_line "${MAC_CONFLINE}"
add_conf_line 'DL_DIR ?= "${TOPDIR}/../downloads"'
add_conf_line 'SSTATE_DIR ?= "${TOPDIR}/../sstate-cache"'

add_layer "meta-aesd" "../meta-aesd"
add_layer "meta-oe" "../meta-openembedded/meta-oe"
add_layer "meta-python" "../meta-openembedded/meta-python"
add_layer "meta-networking" "../meta-openembedded/meta-networking"
add_conf_line 'DISTRO_FEATURES:append = " wifi"'
add_conf_line 'IMAGE_INSTALL:append = " wireless-regdb-static wpa-supplicant"'
add_conf_line 'WIRELESS_REGDOM = "US"'

if [ "$TARGET" = "rpi3" ]; then
	add_conf_line 'LICENSE_FLAGS_ACCEPTED += "synaptics-killswitch"'
	add_layer "meta-raspberrypi" "../meta-raspberrypi"
	add_conf_line 'ENABLE_I2C = "1"'
	add_conf_line 'KERNEL_MODULE_AUTOLOAD:rpi += "i2c-dev i2c-bcm2708"'
	add_conf_line 'IMAGE_INSTALL:append = " i2c-tools"'
	add_conf_line 'ENABLE_UART = "1"'

fi

set -e
bitbake core-image-aesd
