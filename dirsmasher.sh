#!/bin/bash

# Script for directory bruteforcing
# NOTES: Find a way to make it faster

if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]
then
	echo "Simple tool for website directory bruteforcing created in bash
Created by MEGANUKE

User needs to provide a Website (either an IP or a URL), a wordlist to use and the extensions
you want to find. Tool will find 200 or 301 statuses and print out a list of either files or
directories to check out. You will get the status and the complete link to visit."

else
	#Get all the information from the user
	echo "Website directory bruteforce"
	echo -n "Website to bruteforce: "
	read website
	echo -n "Wordlist to use: "
	read wordlist
	echo -n "Extensions to use (Separated by comas): "
	read extensions

	# Create an array from the provided wordlist
	arrayWordlist=()
	mapfile arrayWordlist < $wordlist

	# Create an array from the provided extensions
	IFS="," read -a arrayExtensions <<< $extensions

	# Start appending element from wordlist and extension, if url has either 200 or 301 code echo complete URL
	startTime=$(date +%s)
	for element in ${arrayWordlist[@]}
	do
		htmlCode=$( curl --head --silent -o /dev/null --write-out '%{http_code}\n' "$website/$element" )
		if [[ $htmlCode -eq 200 ]] || [[ $htmlCode -eq 301 ]]
		then
			echo "Status: $htmlCode   $website/$element"
		fi

		for secondElement in ${arrayExtensions[@]}
		do
			htmlCode=$( curl --head --silent -o /dev/null --write-out '%{http_code}\n' "$website/$element.$secondElement" )
			if [[ $htmlCode -eq 200 ]] || [[ $htmlCode -eq 301 ]]
			then
				echo "Status: $htmlCode   $website/$element.$secondElement"
			fi
		done
	done
	endTime=$(date +%s)
	totalTime=$((endTime-startTime))
	echo "Script runtime = $totalTime seconds"
fi
