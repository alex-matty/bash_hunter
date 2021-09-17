#!/bin/bash

#Script for subdomain ennumeration

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
echo "    [+] Google"
echo "    [+] CRT.SH"
echo "    [+] Threatcrowd"
echo "    [+] sublist3r API"
echo "[-] Output Filename: $outputFilename"
echo -e "-----------------------------------------------------------------------\n"

#Start subdomain enumeration

#https://www.google.com SUBDOMAIN ENUMERATION
echo "Checking Google"
for pageStart in {0..500..10}
do
	curl -A "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0" -s "https://www.google.com/search?q=$domainName&filter=0&biw=1366&bih=605&dpr=1&start=$pageStart" | grep -ioE '<a [^>]+>' | grep -ioE 'href="[^\"]+"' | grep -ioE '(http|https)://[^/"]+' | grep -ioE ".*$domainName" >> GoogleSubdomainsInBulk.txt
done

cat GoogleSubdomainsInBulk.txt | sort | uniq >> subdomainsInBulk.txt && rm GoogleSubdomainsInBulk.txt

#https://crt.sh SUBDOMAIN ENUMERATION
echo "Checking CRT.SH"
curl -s "https://crt.sh/?q=$domainName" | grep -ioE "[^>]*\.*$domainName" | grep -ioE "[^=]*\.*$domainName" | grep -ioE "[^ ]*\.*$domainName" | sort | uniq >> subdomainsInBulk.txt

#https://www.threatcrowd.org SUBDOMAIN ENUMERATION
echo "Checking Threatcrowd"
curl -s "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=$domainName" | sed 's/,/\n/g' | grep -ioE "[^\"]*\.*$domainName" | grep -ioE "[^=]*\.*$domainName" | sort | uniq >> subdomainsInBulk.txt

#https://api.sublist3r.com SUBDOMAIN ENUMERATION
echo "Checking sublist3r api"
curl -s "https://api.sublist3r.com/search.php?domain=$domainName" | sed 's/,/\n/g' | grep -ioE "[^\"]*\.*$domainName" | sort | uniq >> subdomainsInBulk.txt

cat subdomainsInBulk.txt | sort | uniq > $outputFilename && rm subdomainsInBulk.txt

foundSubdomains=$(wc -l $outputFilename | awk '{print$1}')

echo -e "Finished! Found $foundSubdomains subdomains for $domainName"