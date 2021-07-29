#!/bin/bash

#Remove out of scope items from a list of subdomains.

echo "Subdomain cleaner!!!"
echo -e "By MEGANUKE\n"

#Get a list of subdomains and a list of Out of Scope items from the user
echo -n "First Subdomain list: "
read subdomains
echo -n "Out of scope items: "
read outOfScope

#Create empty arrays as containers for the wordlists
arraySubdomains=()
arrayOutOfScope=()
arrayInScope=()

#Map the Subdomains and Out of Scope as an array
mapfile arraySubdomains < $subdomains
mapfile arrayOutOfScope < $outOfScope

#Check every subdomainElement of the subdomain list to verify whether it is or isn't in the Out of Scope items
for subdomainElement in ${arraySubdomains[@]}
do

	# x is the counter 'y' is the total amount of elements in the out of scope wordlist
	#NOTE: Change the Value of "y" according to the number of elements in the Out of Scope list
	x=0
	y=12

	for outOfScopeElement in ${arrayOutOfScope[@]}
	do
		if [[ "$subdomainElement" != "$outOfScopeElement" ]]
		then
			let x=x+1
		elif [[ "$subdomainElement" == "$outOfScopeElement" ]]
		then
			let x=13 #Change this value to be bigger than the amount of elements in the out of scope list
		fi
	done

	if [[ $x -eq 12 ]]
	then
		arrayInScope+=("${subdomainElement}")
	fi
done

#Create a new text file containing only In Scope items.
for item in ${arrayInScope[@]}
do
	echo "$item" >> InScope.txt
done

#Check which subdomains have a working web server either with HTTP or HTTPS
cat InScope.txt | httprobe | tee WebScope.txt

#Check every subdomain, if it has content get it if not discard it

#Create an empty array
arraySubdomains=()
goodSubdomains=()
subdomainList=WebScope.txt

#Transform the wordlist into an array
mapfile arraySubdomains < $subdomainList

#Check every subdomain for content, if it has content append the subdomain to a new list
for subdomain in ${arraySubdomains[@]}
do
	contentSize=$(curl -so /dev/null $subdomain -w '%{size_download}')
	if [[ $contentSize -gt 0 ]]
	then
		goodSubdomains+=("$subdomain")
	fi
done

#Create a text file with subdomains with content
for item in ${goodSubdomains[@]}
do
	echo "$item" >> SubdomainsToCheck.txt
done

#Cat file into the terminal
cat SubdomainsToCheck.txt

#Script to get all API URLs

WebURLs=WebScope.txt

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
	if [[ $URL == *"api-"* ]]
	then
		arrayAPIs+=("${URL}")
	fi
done

#Create a txt file containing the API URLs
for element in ${arrayAPIs[@]}
do
	echo "$element" >> WebAPIs.txt
done

cat WebAPIs.txt