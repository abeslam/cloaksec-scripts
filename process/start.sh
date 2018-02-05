#!/bin/bash

buildFolders(){
	recon_folder="01-recon"
	exploit_folder="02-exploitation"
	enumeration_folder="03-enumeration"
	loot_folder="04-loot"
	
	mkdir -p ~/Labs/"${1}"
	cd ~/Labs/"${1}"
	mkdir "${recon_folder}" "${exploit_folder}" "${enumeration_folder}" "${loot_folder}"

	terminator -T "${1}" -e "/opt/cloaksec-utils/portscan.sh ${1}; bash" > /dev/null 2>&1

}

for target in $(cat ~/Labs/Targets.txt);do
		buildFolders $target &
done

#Start the other scans now

