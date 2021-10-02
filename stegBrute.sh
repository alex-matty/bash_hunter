#!/bin/bash

#Check if steghide is installed or in PATH, if not advise user and stop execution.
if ! command -v steghide 2&>/dev/null
then
	echo "steghide is not installed or not in PATH. Make sure to install it."
	exit
fi

#Variable colors, to be able to create a more readable user interface
LCYAN='\033[1;36m'
YELLOW='\033[1;33m'
NOCOLOR='\033[0m'

#Help function to provide syntax and usage to user.
Help() 
{
	echo "Simple tool for steghide Bruteforcing!"
	echo -e "Created by MEGANUKE!\n"

	echo -e "Example Syntax: $0 -i imageFile.jpg -w wordlist.txt\n"

	echo "-i Image file"
	echo "-w Wordlist to use as bruteforce Dictionary"
}

#Map user flags to it's corresponding variables
while getopts i:w:h flag
do
	case "${flag}" in
		i) imageFile=${OPTARG};;
		w) wordlist=${OPTARG};;
		h) Help
			exit;;
	esac
done

#Main banner, just to create a pretty layout
echo -e "\n-----------------------------------------------------------------------"
echo "stegBrute.sh by MEGANUKE"
echo "-----------------------------------------------------------------------"

echo -e "\n-----------------------------------------------------------------------"
echo -e "${LCYAN}[-] Image:${NOCOLOR} $imageFile"
echo -e "${LCYAN}[-] Wordlist: ${NOCOLOR}$wordlist"
echo -e "-----------------------------------------------------------------------\n"

#Create an empty array and append every element to it
arrayWordlist=()

echo -e "${LCYAN}Preparing the Password Wordlist...${NOCOLOR}"

while read -r line
do
	if [[ line != *"#"* ]]
	then
		arrayWordlist+=("${line[@]}")
	fi
done < $wordlist

echo -e "${LCYAN}Done!!!${NOCOLOR}"

#Create the variables for the progress bar
counter=1
arrayLenght=${#arrayWordlist[@]}

echo -e "${LCYAN}Bruteforcing Steghide Passphrase${NOCOLOR}\n"

for password in ${arrayWordlist[@]}
do
	steghide extract -sf $imageFile -p $password -xf output.txt 2&>/dev/null
	echo -ne "${YELLOW}Progress = ($counter/$arrayLenght)\r"
	let counter=counter+1
done