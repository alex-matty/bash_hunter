#!/bin/bash

#Provide an IP and grab banners for each port if open

#NOTES:

echo -n "Provide ip (Single, separated with commas, CIDR Range or range with a dash) to check for open ports: "
read userIp

rangeIp=()

#When user provides IP separated with commas
if [[ "$userIp" == *","* ]]
then
	startTime=$(date +%s)
	IFS="," read -a arrayIp <<< $userIp
	for element in ${arrayIp[@]}
	do
		ping -c 1 -n "$element" 2>&1 >/dev/null
		if [[ $? -eq 0 ]]
		then
			echo "$element is alive"
			rangeIp+=("$element")
		fi
	done

#When user provides a range of IPs with a dash
elif [[ "$userIp" == *"-"* ]]
then
	startTime=$(date +%s)
	Ip=$( echo $userIp | cut -d '-' --fields=1 )
	firstIp=$( echo $Ip | cut -d '.' --fields=1,2,3 )
	firstIp="$firstIp."
	firstNumber=$( echo $Ip | cut -d '.' --fields=4)
	secondNumber=$( echo $userIp | cut -d '-' --fields=2 )
	echo -e "\nChecking for alive hosts..."

	while [[ $firstNumber -le $secondNumber ]]
	do
		pingedIp="$firstIp$firstNumber"
		ping -c 1 -n "$pingedIp" 2>&1 >/dev/null
		if [[ $? -eq 0 ]]
		then
			echo "$pingedIp is alive"
			rangeIp+=("${pingedIp}")
		fi
		let firstNumber=firstNumber+1
	done

#When provided IP with a /24 CIDR range
elif [[ "$userIp" == *"/24"* ]]
then
	startTime=$(date +%s)
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
	startTime=$(date +%s)
	echo -e "\nChecking if host is alive..."

	ping -c 1 -n $userIp 2>&1 >/dev/null

	if [ $? -eq 0 ]
	then
		echo -e "$(tput setaf 3)\nHost is alive!\n$(tput setaf 7)"
		rangeIp+=("${userIp}")
	fi
fi


if [[ ${#rangeIp[@]} -eq 0 ]]
then
	echo "No alive hosts"
else
	echo "Range of ports to check: "
	echo -n "First port: "
	read firstPort
	echo -n "Last port: "
	read lastPort

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
fi
