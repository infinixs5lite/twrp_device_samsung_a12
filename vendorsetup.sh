#
# Copyright (C) 2023 The OrangeFox Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

FDEVICE="a12"

fox_get_target_device() {
local chkdev=$(echo "$BASH_SOURCE" | grep -w $FDEVICE)
	if [ -n "$chkdev" ]; then
		FOX_BUILD_DEVICE="$FDEVICE"
	else
		chkdev=$(set | grep BASH_ARGV | grep -w $FDEVICE)
		[ -n "$chkdev" ] && FOX_BUILD_DEVICE="$FDEVICE"
	fi
}

if [ -z "$1" -a -z "$FOX_BUILD_DEVICE" ]; then
	fox_get_target_device
fi

if [ "$1" = "$FDEVICE" -o "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
	export TW_DEFAULT_LANGUAGE="en"
	export LC_ALL="C"
	export ALLOW_MISSING_DEPENDENCIES=true

chmod a+x device/samsung/a12/mkbootimg

# TWRP/OFR flags (Common)
export TW_DEFAULT_LANGUAGE="en"
export TARGET_ARCH="arm64"

# Device-specific flags
export FOX_RECOVERY_INSTALL_PARTITION="/dev/block/bootdevice/by-name/recovery"
export OF_FIX_OTA_UPDATE_MANUAL_FLASH_ERROR="1"
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER="1"
export OF_USE_MAGISKBOOT_FOR_ALL_PATCHES="0"
export OF_DISABLE_MIUI_SPECIFIC_FEATURES="1"
export OF_NO_TREBLE_COMPATIBILITY_CHECK="1"
export OF_SKIP_MULTIUSER_FOLDERS_BACKUP="1"
export LZMA_RAMDISK_TARGETS="recovery"
export OF_TWRP_COMPATIBILITY_MODE="1"
export OF_USE_SYSTEM_FINGERPRINT="1"
export OF_USE_LZMA_COMPRESSION="1"
export OF_STATUS_INDENT_RIGHT="34"
export OF_STATUS_INDENT_LEFT="34"
export FOX_ADVANCED_SECURITY="1"
export OF_FLASHLIGHT_ENABLE="1"
export OF_FL_PATH1="/sys/class/backlight/panel/max_brightness"
export OF_FL_PATH1="/sys/class/backlight/panel/brightness"
export FOX_USE_NANO_EDITOR="0"
export FOX_USE_BASH_SHELL="1"
export FOX_USE_TAR_BINARY="1"
export FOX_USE_XZ_UTILS="1"
export FOX_ASH_IS_BASH="1"
export OF_SCREEN_H="2340"

# MediaTek
	export FOX_RECOVERY_INSTALL_PARTITION="/dev/block/platform/bootdevice/by-name/recovery"

	# Magisk
	function download_magisk(){
		# Usage: download_magisk <destination_path>
		local DEST=$1
		if [ -n "${DEST}" ]; then
			if [ ! -e ${DEST} ]; then
				echo "Downloading the Latest Release of Magisk..."
				local LATEST_MAGISK_URL=$(curl -sL https://api.github.com/repos/topjohnwu/Magisk/releases/latest | grep browser_download_url | grep Magisk- | cut -d : -f 2,3 | tr -d '"')
				mkdir -p $(dirname ${DEST})
				wget -q ${LATEST_MAGISK_URL} -O ${DEST} || wget ${LATEST_MAGISK_URL} -O ${DEST}
				local RCODE=$?
				if [ "$RCODE" = "0" ]; then
					echo "Successfully Downloaded Magisk to ${DEST}!"
					echo "Done!"
				else
					echo "Failed to Download Magisk to ${DEST}!"
				fi
			fi
		fi
	}
	export FOX_USE_SPECIFIC_MAGISK_ZIP=~/Magisk/Magisk.zip
	download_magisk $FOX_USE_SPECIFIC_MAGISK_ZIP

	# maximum permissible splash image size (in kilobytes); do *NOT* increase!
	export OF_SPLASH_MAX_SIZE=130

	# let's see what are our build VARs
	if [ -n "$FOX_BUILD_LOG_FILE" -a -f "$FOX_BUILD_LOG_FILE" ]; then
  	   export | grep "FOX" >> $FOX_BUILD_LOG_FILE
  	   export | grep "OF_" >> $FOX_BUILD_LOG_FILE
   	   export | grep "TARGET_" >> $FOX_BUILD_LOG_FILE
  	   export | grep "TW_" >> $FOX_BUILD_LOG_FILE
 	fi
else
	if [ -z "$FOX_BUILD_DEVICE" -a -z "$BASH_SOURCE" ]; then
		echo "I: This script requires bash. Not processing the $FDEVICE $(basename $0)"
	fi
fi
