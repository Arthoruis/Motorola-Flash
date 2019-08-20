#!/bin/sh

# -----------------------------------------------------------------
# MOTOROLA Flash ROM files from Linux.
# Tested on Arch Linux.
# -----------------------------------------------------------------
# Written by: Arthur de O. Pereira <https://github.com/Arthoruis/>
# (c) 2019 Arthur de O. Pereira under GNU GPL v.2.0+
# -----------------------------------------------------------------
# Last Update: 19/08/2019.
# -----------------------------------------------------------------
# Usage: motorola-flash [XML file]
# Ex: motorola-flash flashfile.xml
# -----------------------------------------------------------------

function platform
{       if [ $(uname -s) = 'Linux' ]; then
        ADB="/usr/bin/adb"
        FASTBOOT="/usr/bin/fastboot"
        MD5SUM="md5sum"
        version="Linux"          
        fi
}

platform
        echo ""
	echo "---------------------------------------"
	echo " Flash 'Motorola ROM Files' from Linux "
	echo "---------------------------------------"
	echo "     'Press Enter' to flash files      "
	echo "---------------------------------------"
	echo ""
    		    read \n
getValue(){
	val=$(echo "$1" | sed "s/.*$2=\"\([^\"]*\).*/\1/")
	echo "$val" | grep -q " "
	if [ $? -ne 1 ];then
		val=""
	fi
	echo "$val"
}
PATH=.:$PATH
if hash "$FASTBOOT" 2>/dev/null;then
	cat "$1" | grep step[^s] | while read -r line;do
		MD5=$(getValue "$line" "MD5")
		file=$(getValue "$line" "filename");
		op=$(getValue "$line" "operation");
		part=$(getValue "$line" "partition");
		var=$(getValue "$line" "var");
		if [ "$MD5" != "" ];then
			fileMD5=$($MD5SUM "$file" | sed 's/ \(.*\)//');
			if [ "$MD5" != "$fileMD5" ];then
				echo "$file: MD5 mismatch."
				exit 1;
			fi
		fi
		cmd=$(echo $FASTBOOT "$op" "$part" "$file" "$var" | sed -e 's/[[:space:]]/ /g')
		$cmd
	done
	echo "---------------------------------------------------------"
	echo "Please check for errors then press enter to reboot device"
	echo "---------------------------------------------------------"
    		    read \n
	$FASTBOOT reboot
else
	echo "fastboot not found. Please ensure it is in your path."
fi
