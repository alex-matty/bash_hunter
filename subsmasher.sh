#!/bin/bash

# Script for subdomain ennumeration

#Check if cURL is installed, if not advise user and end script
if ! command -v curl 2&>/dev/null
then
	echo "cURL is not installed or not in PATH but it's needed. Make sure to install it"
	exit
fi

# Help function to provide use of tool and syntax
Help() {
	echo "Subdomain enumeration tool"
	echo -e "Created by MEGANUKE\n"
	echo -e "User needs to provide a domain and tool will search in different places for subdomain enumeration\n"
	echo -e "Example Syntax: $0 -d google.com -o filename.txt\n"
	echo "-d Domain Name"
	echo "-o Output Filename"
}

#Get the arguments for the user or the help menu, depending on what the user provides
while getopts d:o:h flag
do
	case "${flag}" in
		d) domainName=${OPTARG};;
		o) outputFilename=${OPTARG};;
		h) Help
			exit;;
	esac
done

#Main banner, just to create a pretty layout
echo -e "\n-----------------------------------------------------------------------"
echo "SUBSmasher by MEGANUKE"
echo "-----------------------------------------------------------------------"

echo -e "\n-----------------------------------------------------------------------"
echo "[-] Domain Name: $domainName"
echo "[-] Checking in:"
echo "    [+] CRT.SH"
echo "    [+] Threatcrowd"
echo "    [+] sublist3r API"
echo -e "-----------------------------------------------------------------------\n"

#Start subdomain enumeration

#https://crt.sh SUBDOMAIN ENUMERATION
echo "Checking CRT.SH"
curl "https://crt.sh/?q=$domainName" | grep -ioE "[^>]*\.*$domainName" | grep -ioE "[^=]*\.*$domainName" | grep -ioE "[^ ]*\.*$domainName" | sort | uniq >> subdomainBulk.txt

#https://www.threatcrowd.org SUBDOMAIN ENUMERATION
echo "Checking Threatcrowd"
curl "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$domainName" | sed 's/,/\n/g' | grep -ioE "[^\"]*\.*$domainName" | grep -ioE "[^=]*\.*$domainName" | sort | uniq >> subdomainBulk.txt

#https://api.sublist3r.com SUBDOMAIN ENUMERATION
echo "Checking sublist3r api"
curl "https://api.sublist3r.com/search.php?domain=$domainName" | sed 's/,/\n/g' | grep -ioE "[^\"]*\.*$domainName" | sort | uniq >> subdomainBulk.txt

cat subdomainBulk.txt | sort | uniq > $outputFilename && rm subdomainBulk.txt

foundSubdomains=$(wc -l $outputFilename | awk '{print$1}')

echo -e "Finished! Found $foundSubdomains subdomains for $domainName"