#!/bin/sh

for ((i=0; i<10000; i++))
do
	mdate=`date +'%d/%m/%Y %H:%M:%S'`
	mem=`free -g | grep Mem | awk '{print $2, $3, $4, $5, $6, $7}'`
	swap=`free -g | grep Swap | awk '{print $2, $3, $4}'`
	cpu=`uptime | grep -oP '(?<=average:).*' | tr -d ','`
	echo "$mdate | $mem | $swap | $cpu" >> systemLog.csv
	fileSize=$(du -m systemLog.csv | cut -f1)
	if [[ $fileSize -gt 100 ]]; then
			rm systemLog.csv
	fi
	sleep 120
done
