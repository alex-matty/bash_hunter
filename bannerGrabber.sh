#!/bin/bash

#Provide an IP and grab banners for each port if open

#NOTES: add an option to analyze a range of ips with just one run.

echo -n "Provide ip to check for open ports: "
read userIp

rangeIp=()

#When user provides IP separated with commas

#When user provides a range of IPs with a dash

#When provided IP with a /24 CIDR range
if [ "$userIp" == '192.168.1.0/24' ]
then
	newUserIp=$( echo $userIp | cut -d '.' --fields=1,2,3 )
	newUserIp="$newUserIp."

	echo -e "\nChecking for alive hosts..."

	lowNumber=1
	highNumber=254

	while [ $lowNumber -le $highNumber ]
	do
		pingedIp="$newUserIp$lowNumber"
		ping -c 1 -n "$pingedIp" 2>&1 >/dev/null
		if [ $? -eq 0 ]
		then
			echo "$pingedIp is alive"
			rangeIp+=("${pingedIp}")
		fi
		let lowNumber=lowNumber+1
	done

#Single IP provided
else
	echo -e "\nChecking if host is alive..."

	ping -c 1 -n $userIp 2>&1 >/dev/null

	if [ $? -eq 0 ]
	then
		echo -e "$(tput setaf 3)\nHost is alive!\n$(tput setaf 7)"
		rangeIp+=("${userIp}")
	fi
fi

echo "Range of ports to check: "
echo -n "First port: "
read firstPort
echo -n "Last port: "
read lastPort

startTime=$(date +%s)

for element in "${rangeIp[@]}"
do
	echo -e "\nStarting Scan for $element"

	counter1=$firstPort
	counter2=$lastPort

	MacAddress=$(arp $element)
	MacAddress=$( echo $MacAddress | cut -d ' ' -f 9 )

	echo -e "MAC Address is $MacAddress\n"

	while [ $counter1 -le $counter2 ]
	do
		nc -z $element $counter1 2>/dev/null && echo "$(tput setaf 3)*** Port $counter1 is listening ***$(tput setaf 7)"
		let counter1=counter1+1
	done
done

endTime=$(date +%s)
runTime=$((endTime-startTime))

echo -e "\nScan finished in $runTime seconds"
