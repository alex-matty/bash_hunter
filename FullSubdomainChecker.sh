#!/bin/bash

#Check if all software is installed and ready to use, if something is missing, advice user and ask for installation

if ! command -v sublist3r 2&>/dev/null
then
	echo "sublist3r is not installed or not in PATH but it's needed. Make sure to install it"
	exit
fi

if ! command -v httprobe 2&>/dev/null
then
	echo "HTTProbe is not installed or not in PATH but it's needed. Make sure to install it"
fi 

#Starts by getting a Domain Name and the output desired name to create it.
#1st argument Domain Name
#2nd argument Output File Name.
#3rd argument Out Of Scope items

#Help function

Help()
{
	echo -e "Provide a domain name and a out-of scope wordlist, and get three files | in-scope subdomains | subdomains with an HTTP ot HTTPS server | APIs\n"
	echo -e "Example Syntax: $0 -d google.com -s newfile.txt -o no-nolist.txt\n"
	echo "-d Domain to check"
	echo "-s Filename to save new found subdomains"
	echo "-o out-of-scope elements provided in a file. element per line"
	echo "-h Print this help"

}

#Create a help function and flags to get arguments:

while getopts d:s:o:h flag
do
	case "${flag}" in
		d) domainName=${OPTARG};;
		s) FoundSubdomainsFile=${OPTARG};;
		o) outOfScopeWordlist=${OPTARG};;
		h) Help
			exit;;
	esac
done



#Use sublist3r to check for subdomains and store the output on a created name

#sublist3r -d $domainName -v -o $FoundSubdomainsFile

#Compare found subdomains with the out-of-scope wordlist and create an in-scope wordlist 
#Create empty arrays as containers for the wordlists

arraySubdomains=()
arrayOutOfScope=()
arrayInScope=()

#Map the Subdomains and Out-of-Scope as an array
mapfile arraySubdomains < $FoundSubdomainsFile
mapfile arrayOutOfScope < $outOfScopeWordlist


#Check every subdomainElement of the subdomain list to verify whether it is or isn't in the Out-of-Scope items

for subdomainElement in ${arraySubdomains[@]}
do

	#Count the number of elements in the out-of-scope list and create a variable with the value
	#This will be the value to stop the for loop and go to next element
	
	numberOfOutOfScopeItems=$(wc -l $outOfScopeWordlist | awk '{print$1}')

	#Create a variable counter with value 0

	counter=0
	y=$numberOfOutOfScopeItems

	for outOfScopeElement in ${arrayOutOfScope[@]}
	do
		if [[ "$subdomainElement" != "$outOfScopeElement" ]]
		then
			let counter=counter+1
		elif [[ "$subdomainElement" == "$outOfScopeElement" ]]
		then
			let counter=y+1	
		fi
	done

	if [[ $counter -eq $numberOfOutOfScopeItems ]]
	then
		arrayInScope+=("${subdomainElement}")
	fi
done

#Create a new text file containing only In Scope items.
for item in ${arrayInScope[@]}
do
	echo "$item" >> SubdomainsInScope.txt
done

#Check which subdomains have a working web server either with HTTP or HTTPS
cat SubdomainsInScope.txt | httprobe | cat > ActiveWebServerInScope.txt

#NOTE: Find a way to check if a domain resolves to another domain to verify if it is actually in-scope

#Script to get all API URLs

WebURLs=ActiveWebServerInScope.txt

#Create an empty array to contain the elements of the wordlist
arrayURLs=()
arrayAPIs=()

#Map the file to the array
mapfile arrayURLs < $WebURLs

#Check for the API pattern contained in the URL, if it matches append it to
#the array, if not discard it
#NOTE: Depending on the API Pattern, change it accordingly to what you need
for URL in ${arrayURLs[@]}
do
	if [[ $URL == *"api"* ]]
	then
		arrayAPIs+=("${URL}")
	fi
done

#Create a txt file containing the API URLs
for element in ${arrayAPIs[@]}
do
	echo "$element" >> WebAPIs.txt
done

echo "All done!!! Happy hunting!!"