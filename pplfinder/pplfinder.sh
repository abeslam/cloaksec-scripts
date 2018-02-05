#!/bin/bash
#using parallel because SPEED. Shell-level speed.

if [ $# -ne 2 ]; then
    echo "[!] Usage: pplfinder <cewl.txt> <targetIP>"
    exit 1
fi

inDir=$(pwd)
cewlFile=$1
target=$2
uniqueFile=$(cat $cewlFile|sort|uniq)
for i in $(echo "${uniqueFile}");do
	( for ii in $(cat /opt/cloaksec-scripts/pplfinder/mf_names.txt); do
		if [ "${i,,}" == "${ii,,}" ]; then
			echo "[+] [${i}] > ${inDir}/firstnames_${target}.txt"
			echo "======================="
			echo "${i}" >> "${inDir}/firstnames_${target}.txt"
		fi
	done ) &
done

wait
echo 'Search finished. If no results above, no matches found.
Otherwise, take note of these names to see if they are mentioned on other machines.'
