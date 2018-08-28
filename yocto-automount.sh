#!/bin/bash

###########################################################################
#  yocto-automount.sh                                                     #
#                                                                         #
#  Copyright 2018 Mustafa Ozcelikors <mozcelikors@gmail.com>              #
#                                                                         #
#  Designed for Yocto-Linux for USB drive mount point redirection to      #
#  conventional /media/<username> mount point.                            #
#  Remounts a drive that is mounted to /run/media/<device-name>           #
#  to /media/<username>/<device-name>                                     #
#  Requires readlink, and bash interpreter to work                        #
#                                                                         #
#    This program is free software: you can redistribute it and/or modify #
#    it under the terms of the GNU General Public License as published by #
#    the Free Software Foundation, either version 3 of the License, or    #
#    (at your option) any later version.                                  #
#                                                                         #
#    This program is distributed in the hope that it will be useful,      #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of       #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
#    GNU General Public License for more details.                         #
#                                                                         #
#    You should have received a copy of the GNU General Public License    #
#    along with this program.  If not, see <https://www.gnu.org/licenses/>#
#                                                                         #
#  Set username below as your default user. Typically this is "root" in   #
#  Yocto-Linux built targets.                                             #
###########################################################################

# User Inputs
username="root" # Typical user in Yocto-Linux-based system

# Global variables
prev_drive_name=""

# Create /run/media and /media/$username if they do not exist
mkdir -p /run/media
mkdir -p /media/$username

while true; do

	# Get drive path /dev/sdX or /dev/mmcblkX etc.
	drive_path=`readlink -f /dev/disk/by-id/usb-* | tail -1`

        if [ "$drive_path" = "/dev/disk/by-id/usb-*" ]; then
                drive_path=""
        fi

	# Extract drive name sdX or mmcblkX etc.
        drive_name=`echo $drive_path | sed -e "s/^\/dev\///"`

	if [ -z "$drive_path" ]; then
		# USB drive path is empty, hence no drive connected.

		if ! ls /media/$username/$prev_drive_name 1>/dev/null 2>/dev/null ; then
			echo "Device unmount failure. Forcing unmount.."
			umount -f -l /media/$username/$prev_drive_name
			rm -rf /media/$username/$prev_drive_name
		fi

		if [ ! -z "$(ls -A /run/media 2>/dev/null)" ]; then
			# Drive is not detected but /run/media is non empty
			echo "USB drive is not detected, but /run/media/ is not empty."

			echo "Clearing /run/media"
			rm -rf /run/media/sd*
		fi

	else
		# USB drive path is non-empty, USB detected

		prev_drive_name=$drive_name
		if [ -z "$(ls -A /run/media 2>/dev/null)" ]; then
			# /run/media is empty
			echo "USB drive detected, /run/media is empty"
		else
			# /run/media is non-empty
			echo "USB drive detected, /run/media is non empty."

			if [ -d "/run/media/$drive_name" ]; then
				echo "Remounting to /media/$username"
            	
                        	mkdir -p /media/$username/$drive_name
                        	umount /run/media/$drive_name
                        	rm -rf /run/media/$drive_name
                        	mount /dev/$drive_name /media/$username/$drive_name
			fi
			
		fi

	fi

	# Delay & poll
	sleep 0.5

done
