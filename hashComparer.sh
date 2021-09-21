#!/bin/bash

#calculate most important hash types and tell if matches. If not alert something has changed

#Check if different hashes are installed to use the software
if ! command -v md5sum 2&>/dev/null
then
	echo "MD5SUM is not installed or not in PATH but it's needed. Make sure to install it."
	exit
fi

if ! command -v sha1sum 2&>/dev/null
then
	echo "SHA1SUM is not installed or not in PATH but it's needed. Make sure to install it."
	exit
fi

if ! command -v sha256sum 2&>/dev/null
then
	echo "SHA256SUM is not installed or not in PATH but it's needed. Make sure to install it."
	exit
fi

if ! command -v sha512sum 2&>/dev/null
then
	echo "SHA512SUM is not installed or not in PATH but it's needed. Make sure to install it."
	exit
fi

#Create a help function to provide user the help menu, script usage and and syntax.
Help() {
	echo "Simple tool for file integrity checking."
	echo -e "Created by MEGANUKE\n"
	echo "There are two ways of using the tool." 
	echo "MODE A: You can check the integrity of a file by comparing the hash you have with the hash of the file. In this case you should provide the file, the hash and the hash type." 
	echo -e "MODE B: You can compare hashes between two files. In this case you just have to provide the two files and hashed will be calculated and compared. Used hashes will be MD5, SHA1, SHA256 and SHA512\n"
	echo  "Example Syntax: $0 -m a -f fileToCheck -s Hash -t Type of Hash (MD5, SHA1, SHA256 and SHA512)"
	echo -e "Example Syntax: $0 -m B -f fileToCheck1 -g fileToCheck2\n"
	echo "-m MODE (A: file and hash) (B: Compare two files)"
	echo "-f File to Check hash or 1st File to compare (Depending on the mode)"
	echo "-g 2nd file to compare (Only if mode B is selected)"
	echo "-s HASH (If mode A is selected)"
}

#Get arguments for user and map them to the corresponding variables
while getopts m:f:s:g:h flag
do
	case "${flag}" in
		m) selectedOption=${OPTARG};;
		f) file1=${OPTARG};;
		g) file2=${OPTARG};;
		s) providedHash=${OPTARG};;
		h) Help
			exit;;
	esac
done

#Uppercase needed variables to avoid any issues string comparison
selectedOption=${selectedOption^^}
typeOfHash=${typeOfHash^^}

#Count the number of characters in the hash string to try to guess the hash type

hashStringCount=${#providedHash}

#Define color variables to create a prettier and easier to read output
YELLOW='\033[1;33m'
LCYAN='\033[1;36m'
NOCOLOR='\033[0m'

#Make a pretty layout to start the script and show selected options
echo -e "\n-----------------------------------------------------------------------"
echo "HASHComparer by MEGANUKE"
echo "-----------------------------------------------------------------------"

echo -e "\n-----------------------------------------------------------------------"
if [[ $selectedOption == "A" ]]
then
	echo -e "${LCYAN}[-] MODE:${NOCOLOR} $selectedOption -- Compare Hash and File Hash"
	echo -e "${LCYAN}[-] File:${NOCOLOR} $file1"
	echo -e "${LCYAN}[-] Hash:${NOCOLOR} $providedHash"
	if [[ $hashStringCount -eq 32 ]]
	then
		echo -e "${LCYAN}[-] Hash-Type:${NOCOLOR} MD5"
	elif [[ $hashStringCount -eq 40 ]]
	then
		echo -e "${LCYAN}[-] Hash-Type:${NOCOLOR} SHA1"
	elif [[ $hashStringCount -eq 64 ]]
	then
		echo -e "${LCYAN}[-] Hash-Type:${NOCOLOR} SHA256"
	elif [[ $hashStringCount -eq 128 ]]
	then
		echo -e "${LCYAN}[-] Hash-Type:${NOCOLOR} SHA512"
	fi

elif [[ $selectedOption == "B" ]]
then
	echo -e "${LCYAN}[-] MODE:${NOCOLOR} $selectedOption -- Compare two files with different hash algorithms"
	echo -e "${LCYAN}[-] File1:${NOCOLOR} $file1"
	echo -e "${LCYAN}[-] File2:${NOCOLOR} $file2"
fi
echo -e "-----------------------------------------------------------------------\n"

# Compare the website hash with the file hash
if [[ $selectedOption == "A" ]]
then

	if [[ $hashStringCount -eq 32 ]]
	then

		echo -e "${YELLOW}MD5 Hash Comparison${NOCOLOR}"
		md5file1=$(md5sum $file1 | awk '{print$1}')
		echo $md5file1
		echo $providedHash

		if [[ $md5file1 == $providedHash ]]
		then
			echo -e "${YELLOW}Everything looks normal\n${NOCOLOR}"
		else
			echo -e "${YELLOW}Something smells fishy\n${NOCOLOR}"
		fi

	elif [[ $hashStringCount -eq 40 ]]
	then

		echo -e "${YELLOW}SHA1 Hash Comparison${NOCOLOR}"
		sha1file1=$(sha1sum $file1 | awk '{print$1}')
		echo $sha1file1
		echo $providedHash

		if [[ $sha1file1 == $providedHash ]]
		then
			echo -e "${YELLOW}Everything looks normal\n${NOCOLOR}"
		else
			echo -e "${YELLOW}Something smells fishy\n${NOCOLOR}"
		fi

	elif [[ $hashStringCount -eq 64 ]]
	then

		echo -e "${YELLOW}SHA256 Hash Comparison${NOCOLOR}"
		sha256file1=$(sha256sum $file1 | awk '{print$1}')
		echo $sha256file1
		echo $providedHash

		if [[ $sha256file1 == $providedHash ]]
		then
			echo -e "${YELLOW}Everything looks normal\n${NOCOLOR}"
		else	
			echo -e "${YELLOW}Something smells fishy\n${NOCOLOR}"
		fi

	elif [[ $hashStringCount -eq 128 ]]
	then

		echo -e "${YELLOW}SHA512 Hash Comparison${NOCOLOR}"
		sha512file1=$(sha512sum $file1 | awk '{print$1}')
		echo $sha512file1
		echo $providedHash

		if [[ $sha512file1 == $providedHash ]]
		then
			echo -e "${YELLOW}Everything looks normal\n${NOCOLOR}"
		else
			echo -e "${YELLOW}Something smells fishy\n${NOCOLOR}"
		fi
	fi

# Compare hashes between two files
elif [[ $selectedOption == "B" ]]
then
	
	echo -e "Calculating and comparing hashes...\n"

	echo "${YELLOW}MD5 Hash Comparison${NOCOLOR}"

	md5file1=$(md5sum $file1 | awk '{print$1}')
	md5file2=$(md5sum $file2 | awk '{print$1}')

	echo $md5file1
	echo $md5file2

	if [[ $md5file1 == $md5file2 ]]
	then
		echo -e "${YELLOW}Everything looks normal\n${NOCOLOR}"
	else
		echo -e "${YELLOW}Something smells fishy\n${NOCOLOR}"
	fi

	echo "${YELLOW}SHA1 Hash Comparison${NOCOLOR}"

	sha1file1=$(sha1sum $file1 | awk '{print$1}')
	sha1file2=$(sha1sum $file2 | awk '{print$1}')

	echo $sha1file1
	echo $sha1file2

	if [[ $sha1file1 == $sha1file2 ]]
	then
		echo -e "${YELLOW}Everything looks normal\n${NOCOLOR}"
	else
		echo -e "${YELLOW}Something smells fishy\n${NOCOLOR}"
	fi

	echo "${YELLOW}SHA256 Hash Comparison${NOCOLOR}"

	sha256file1=$(sha256sum $file1 | awk '{print$1}')
	sha256file2=$(sha256sum $file2 | awk '{print$1}')

	echo $sha256file1
	echo $sha256file2

	if [[ $sha256file1 == $sha256file2 ]]
	then
		echo -e "${YELLOW}Everything looks normal\n${NOCOLOR}"
	else
		echo -e "${YELLOW}Something smells fishy\n${NOCOLOR}"
	fi

	echo "${YELLOW}SHA512 Hash Comparison${NOCOLOR}"

	sha512file1=$(sha512sum $file1 | awk '{print$1}')
	sha512file2=$(sha512sum $file2 | awk '{print$1}')

	echo $sha512file1
	echo $sha512file2

	if [[ $sha512file1 == $sha512file2 ]]
	then
		echo -e "${YELLOW}Everything looks normal\n${NOCOLOR}"
	else
		echo -e "${YELLOW}Something smells fishy\n${NOCOLOR}"
	fi
fi