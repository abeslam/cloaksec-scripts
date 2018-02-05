#!/bin/bash
target=$1
cd ~/Labs/"${target}"/01-recon
echo "Starting Nmap TCP Scan on ${1}..."
nmap -sS -Pn -f -e tap0 --script default,safe,vulscan/vulscan.nse -g 53 -A -data-length 200 -p0- -oA nmap_tcp_1 -vvv --webxml "${target}"
echo "Nmap TCP Scan Complete."
echo "Let's review the HTTP Ports."

IFS=$'\n'
for webPort in $(cat nmap_tcp_1.nmap |grep "open\|filtered" |grep -v "Not"|awk '{print $1,$2,$3}'|grep "http\|https\|ssl\|soap\|http-proxy\|http-alt");do
	echo "======="
	echo "|${webPort}"
	echo "======="
	echo "Would you like to start a webscan for the above service?"
	echo "[0] - Skip for now"
	echo "[1] - Just DirScanning"
	echo "[2] - DirScanning, Nikto & Cewl"
	read -p "> " webScanChoice
	if [ "${webScanChoice}" -ne "0" ];then
		portNum=$(echo $webPort|cut -d"/" -f1)
		if [ "$(echo $webPort|awk '{print $3}')" == "https" ] || [ "$(echo $webPort|awk '{print $3}')" == "ssl" ];then
			terminator -T "${1} - Webscan Port ${portNum}" -e "/opt/cloaksec-utils/webscan.sh https://${1}:${portNum} ${portNum} 50 ${webScanChoice}; bash" > /dev/null 2>&1
		else
			terminator -T "${1} - Webscan Port ${portNum}" -e "/opt/cloaksec-utils/webscan.sh http://${1}:${portNum} ${portNum} 50 ${webScanChoice}; bash" > /dev/null 2>&1
		fi
	else
		echo "Skipping Webscan for now."
	fi
done
unset IFS

#UDP Scan Now
echo "Starting Unicorn UDP Scan on ${1}..."
uniFileName="uni_udp_1.txt"
unicornscan -i tap0 -mU ${target}:a -l ${uniFileName}
echo "[*] UDP UnicornScan complete"
if [ -s $uniFileName ];then
	echo "Now Nmaping the open UDP ports"
	for openUDP in $(cat uni_udp_1.txt|grep open |cut -d"]" -f1|rev |cut -d" " -f1|rev);do
		echo -n "${openUDP}," >> tmpUDP
	done
	updPorts=$(cat tmpUDP)
	nmap -sU -Pn -f -e tap0 --script default,safe,vulscan/vulscan.nse -g 53 -A -data-length 200 -pU:"${updPorts}" -oA nmap_udp_1 -vvv --webxml "${target}"
	# rm tmpUDP
	#cat unitest.txt |grep open |cut -d"]" -f1|rev |cut -d" " -f1|rev
fi
echo "First 2 scans are finished."

#Now VulnScans?