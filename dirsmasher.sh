#!/bin/bash

# Script for directory bruteforcing
# NOTES: Find a way to make it faster

#Check if curl is installed or in PATH in the machine, if not stop and advise customer to install it

if ! command -v curl 2&>/dev/null
then
	echo "cURL is not installed or not in PATH but it's needed. Make sure to install it"
	exit
fi

#Help Function to provide use of the tool and syntax

Help()
{
	echo -e "Simple tool for website directory bruteforcing created in bash. Created by MEGANUKE\n"

	echo "User needs to provide a Website (either an IP or a URL), a wordlist to use and the extensions"
	echo "you want to find. Tool will find 200 or 301 statuses and print out a list of either files or"
	echo -e "directories to check out. You will get the status and the complete link to visit.\n"

	echo -e "NOTE: You have to provide the protocol either with IPs or URLs"

	echo -e "Example Syntax: $0 -u http://google.com -w wordlist.txt -x php,html,txt\n"

	echo "-u URL or IP (provide protocol, \"http\" or \"https\")"
	echo "-w Wordlist to use"
	echo "-x Extensions to use (separated by commas)"
	echo "-o Output filename (Optional)"
}

#Get the arguments for the user and the help function, depending on what the user provides

while getopts u:w:x:o:h flag
do
	case "${flag}" in
		u) website=${OPTARG};;
		w) wordlist=${OPTARG};;
		x) extensions=${OPTARG};;
		o) fileOutput=${OPTARG};;
		h) Help
			exit;;
	esac
done

# Create an array from the provided wordlist
arrayWordlist=()

while read -r line
do
	if [[ $line != *"#"* ]]
	then
		arrayWordlist+=("${line[@]}")
	fi
done < $wordlist

# Create an array from the provided extensions
IFS="," read -a arrayExtensions <<< $extensions

# Start appending element from wordlist and extension, if url has either 200 or 301 code echo complete URL
startTime=$(date +%s)



#Bruteforce function, the one that makes the searching line by line
bruteforcing()
{
	progressStart=0
	progressEnd=${#arrayWordlist[@]}

	for element in ${arrayWordlist[@]}
	do
		htmlCode=$( curl --head -k --silent -o /dev/null --write-out '%{http_code}\n' "$website/$element" )
	
		if [[ $htmlCode -eq 200 ]] || [[ $htmlCode -eq 301 ]]
		then
			echo "Status: $htmlCode   $website/$element"
		fi

		for secondElement in ${arrayExtensions[@]}
		do
			htmlCode=$( curl --head -k --silent -o /dev/null --write-out '%{http_code}\n' "$website/$element.$secondElement" )
			if [[ $htmlCode -eq 200 ]] || [[ $htmlCode -eq 301 ]]
			then
				echo "Status: $htmlCode   $website/$element.$secondElement"
			fi
		done

		let progressStart=progressStart+1
		echo -ne "progress ($progressStart/$progressEnd)\r"
	done
}

#Main banner, just to create a pretty layout
echo -e "\n-----------------------------------------------------------------------"
echo "DIRSmasher by MEGANUKE"
echo "-----------------------------------------------------------------------"

echo -e "\n-----------------------------------------------------------------------"
echo "[-] URL: $website"
echo "[-] Wordlist: $wordlist"
echo "[-] Extensions: $extensions"
if [[ -n $fileOutput ]]
then
	echo "[-] Output File: $fileOutput"
fi
echo -e "-----------------------------------------------------------------------\n"

#do the logic and if an output file is provided create a file with the name, otherwise don't create it
bruteforcing | tee $fileOutput

endTime=$(date +%s)
totalTime=$((endTime-startTime))
echo "Script runtime = $totalTime seconds"