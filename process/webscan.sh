#!/bin/bash

if [ $# -ne 4 ]; then
    echo "[!] Usage: webScan.sh <url:[port]> <port#> <#/threads> <scanType>"
    echo "ScanTypes: [1]-Directory Scanning   [2]-Directory Scanning, Nikto & Cewl   [3]-Just Nikto   [4]-WFuzz Attack Scan   [5]-Cewl"
    exit 1
fi

target=$1
port=$2
threads=$3
scanType=$4
targetIP=$(echo "${target}"|cut -d"/" -f3|cut -d":" -f1)

cd ~/Labs/"${targetIP}"/01-recon

doScanning(){
	echo '[+] GoBuster SecLists common scan'
	gobuster -t "${threads}" -u "${target}" -w /usr/share/seclists/Discovery/Web_Content/common.txt -s "200,204,301,302,307,403,500" -l |& tee "gobuster-${port}-seclists_common.txt"
	echo '[*] SecLists common list scan completed'

	# linebreak

	echo '[+] GoBuster SecLists big scan'
	gobuster -t "${threads}" -u "${target}" -w /usr/share/seclists/Discovery/Web_Content/big.txt -s "200,204,301,302,307,403,500" -l |& tee "gobuster-${port}-seclists_big.txt"
	echo '[*] SecLists big list scan completed'

	# linebreak

	echo '[+] GoBuster SecLists CGI scan'
	gobuster -t "${threads}" -u "${target}" -w /usr/share/seclists/Discovery/Web_Content/cgis.txt -s "200,204,301,302,307,403,500" -l |& tee "gobuster-${port}-CGIs.txt"
	echo '[*] SecLists big list scan completed'

	# endTool

	# startTool 'DIRSEARCH'

	echo '[+] dirsearch default scan'
	python3 /opt/dirsearch/dirsearch.py -t "${threads}" -e php,asp,pl,py,cgi,html,htm,ini,conf -F -u "${target}" --plain-text-report="dirsearch-${port}-default.txt"
	echo '[*] dirsearch default scan completed'

	# endTool 
}

doNikto() {
	nikto -h "${target}" -o nikto_"${port}".txt 
}

doWfuzzAttack(){
	echo '[+] wfuzz Attack Scan scan'
	read -r -p "WFuzz Attack URI (/index.php?ip=FUZZ&day=fri), or type skip to skip: " URI
	if [ "${URI}" == "skip" ]; then
		#skip
		echo 'skipping WFUZZ Attack'
	else
		# wfuzz -t "${threads}" -c -z file,/usr/share/wfuzz/wordlist/Injections/All_attack.txt --hc 404 "${target}${URI}/FUZZ" -f "wfuzz-${port}-attack.txt",default
		wfuzz -f wfuzz-"${port}"-attack.txt,default -c -t "${threads}" -p 127.0.0.1:8080 --hc 404 -z file,/usr/share/wfuzz/wordlist/Injections/All_attack.txt "${target}${URI}"
	fi
	echo '[*] Wfuzz Attack Scan Completed'
	# endTool
}

doCewl(){
	echo "[+] Starting Cewl Scan/Scrape"
	mkdir cewl_"${port}"
	cewl -w cewl_"${port}"/cewl.txt -a --meta_file cewl_"${port}"/meta.txt -e --email_file cewl_"${port}"/email.txt -d 3 "${target}"
	echo "[*]Cewl Completed"
	if [ -s "cewl_${port}/cewl.txt" ];then
		echo "[+] Starting pplfinder"
		pplfinder cewl_"${port}"/cewl.txt "${port}"
		echo "[*] pplfinder complete."
	else
		echo "Cewl file is empty, not running pplfinder."
	fi
}

if [ "${scanType}" == "1" ];then
	doScanning
elif [ "${scanType}" == "2" ];then
	doScanning
	doNikto
	doCewl
elif [ "${scanType}" == "3" ];then
	doNikto
elif [ "${scanType}" == "4" ];then
	doWfuzzAttack
elif [ "${scanType}" == "5" ];then
	doCewl
else
	echo "Invalid ScanType. Restart"
fi

echo "[*] All Web Scans Complete."