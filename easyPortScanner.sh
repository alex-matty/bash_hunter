#!/bin/bash

#Provide an IP or IP range and check for open ports

#Help function to provide usage and syntax help
Help()
{
	echo "$0 is a simple port scanner in which you can provide a single IP, separated by commas IPs or a range of IPs separated by a dash or with CIDR range"
	echo "Script will tell you if IP is online by sending a ping, if it has open ports and if possible MAC Address"
	echo -e "Created by MEGANUKE\n"
	echo -e "Example Syntax: $0 -i 192.168.1.1 -p 1-65535 -o filename.txt\n"
	echo "-i IP"
	echo "-p Single port, range of ports (dash separated) or specific ports (comma separated)"
	echo "-o Output File Name (Optional)"
}

#Accept and map arguments
while getopts i:p:o:h flag
do
	case "${flag}" in
		i) userIp=${OPTARG};;
		p) portRange=${OPTARG};;
		o) fileOutput=${OPTARG};;
		h) Help
			exit;;
	esac
done

#Create empty arrays to save IPs and Ports
rangeIp=()
arrayPorts=()

#Main banner, just to create a pretty layout
echo -e "\n-----------------------------------------------------------------------"
echo "EasyPortScanner by MEGANUKE"
echo "-----------------------------------------------------------------------"

echo -e "\n-----------------------------------------------------------------------"
echo "[-] URL: $userIp"
echo "[-] Port(s) to scan: $portRange"
if [[ -n $fileOutput ]]
then
	# Remove all info if file exist, this to avoid rewriting the same file
	echo -ne "\r" > $fileOutput
	echo "[-] Output File: $fileOutput"
fi
echo "-----------------------------------------------------------------------"

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

#If a Single IP provided
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

# If no IP responds to a ping request, treat every host as offline and finish the program
if [[ ${#rangeIp[@]} -eq 0 ]]
then
	echo "No alive hosts"

# If there are ping responses check for open ports in the alive hosts
else
	# If a port range is specified with a dash create a sequence with both values
	if [[ $portRange == *"-"* ]]
	then
		IFS="-"	read -a arrayPorts <<< $portRange

		for element in "${rangeIp[@]}"
		do
			if [[ -n $fileOutput ]]
			then
				echo -e "\nStarting Scan for $element" | tee -a $fileOutput

				MacAddress=$(arp $element)
				MacAddress=$( echo $MacAddress | cut -d ' ' -f 9 )

				echo -e "MAC Address is $MacAddress\n" | tee -a $fileOutput

				firsPort=${arrayPorts[0]}
				lastPort=${arrayPorts[1]}
				for port in $(seq $firsPort $lastPort)
				do
					nc -z $element $port 2>/dev/null && echo "$(tput setaf 3)*** Port $port is listening ***$(tput setaf 7)" | tee -a $fileOutput
				done

			else
				echo -e "\nStarting Scan for $element"

				MacAddress=$(arp $element)
				MacAddress=$( echo $MacAddress | cut -d ' ' -f 9 )

				echo -e "MAC Address is $MacAddress\n"

				firsPort=${arrayPorts[0]}
				lastPort=${arrayPorts[1]}
				for port in $(seq $firsPort $lastPort)
				do
					nc -z $element $port 2>/dev/null && echo "$(tput setaf 3)*** Port $port is listening ***$(tput setaf 7)"
				done
			fi
		done

	# If individual ports are specified, create an array indexing each port as a single value
	elif [[ $portRange == *","* ]]
	then
		IFS="," read -a arrayPorts <<< $portRange

		for element in "${rangeIp[@]}"
		do

			if [[ -n $fileOutput ]]
			then
				echo -e "\nStarting Scan for $element" | tee -a $fileOutput

				MacAddress=$(arp $element)
				MacAddress=$( echo $MacAddress | cut -d ' ' -f 9 )

				echo -e "MAC Address is $MacAddress\n" | tee -a $fileOutput

				for port in "${arrayPorts[@]}"
				do
					nc -z $element $port 2>/dev/null && echo "$(tput setaf 3)*** Port $port is listening ***$(tput setaf 7)" | tee -a $fileOutput
				done

			else
				echo -e "\nStarting Scan for $element"

				MacAddress=$(arp $element)
				MacAddress=$( echo $MacAddress | cut -d ' ' -f 9 )

				echo -e "MAC Address is $MacAddress\n"

				for port in "${arrayPorts[@]}"
				do
					nc -z $element $port 2>/dev/null && echo "$(tput setaf 3)*** Port $port is listening ***$(tput setaf 7)"
				done
			fi
		done

	# If just one port is specified, scan that port in every IP of the array
	else
		for element in "${rangeIp[@]}"
		do
			if [[ -n $fileOutput ]]
			then
				echo -e "\nStarting Scan for $element" | tee -a $fileOutput

				MacAddress=$(arp $element)
				MacAddress=$( echo $MacAddress | cut -d ' ' -f 9 )

				echo -e "MAC Address is $MacAddress\n" | tee -a $fileOutput

				nc -z $element $portRange 2>/dev/null && echo "$(tput setaf 3)*** Port $portRange is listening ***$(tput setaf 7)" | tee -a $fileOutput

			else
				echo -e "\nStarting Scan for $element"

				MacAddress=$(arp $element)
				MacAddress=$( echo $MacAddress | cut -d ' ' -f 9 )

				echo -e "MAC Address is $MacAddress\n"

				nc -z $element $portRange 2>/dev/null && echo "$(tput setaf 3)*** Port $portRange is listening ***$(tput setaf 7)"
			fi
		done

	fi

	endTime=$(date +%s)
	runTime=$((endTime-startTime))

	echo -e "\nScan finished in $runTime seconds"
fi