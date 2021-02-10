#!/bin/bash

#Compare hashes between two files and check integrity. Provide the files as two command line arguments

echo "The hash comparer"

echo "Select the option you would like to use"
echo "A: Compare hashes between a file and a provided hash"
echo "B: Compare hashes between two files"
echo -n "Choose option (A or B): "
read selectedOption

# Compare the website hash with the file hash

if [ $selectedOption == "A" ]
then
	echo "Compare hashes between a file and a provided hash"
	echo -n "Select file to check: "
	read chosenFile
	echo -n "Provide hash to compare: "
	read providedHash
	echo -n "Hash algorithm used: "
	read typeOfHash

	if [ $typeOfHash == "MD5" ]
	then
		md5file1=$(md5sum $chosenFile | cut -d ' ' -f 1)
		echo $md5file1
		echo $providedHash

		if [ $md5file1 == $providedHash ]
		then
			echo -e "Everything looks normal\n"
		else
			echo -e "SOmething smells fishy\n"
		fi
	elif [ $typeOfHash == "SHA1" ]
	then
		sha1file1=$(sha1sum $chosenFile | cut -d ' ' -f 1)
		echo $sha1file1
		echo $providedHash

		if [ $sha1file1 == $providedHash ]
		then
			echo -e "Everything looks normal\n"
		else
			echo -e "SOmething smells fishy\n"
		fi
	elif [ $typeOfHash == "SHA256" ]
	then
		sha256file1=$(sha256sum $chosenFile | cut -d ' ' -f 1)
		echo $sha256file1
		echo $providedHash

		if [ $sha256file1 == $providedHash ]
		then
			echo -e "Everything looks normal\n"
		else
			echo -e "Something smells fishy\n"
		fi
	fi

# Compare hashes between two files

elif [ $selectedOption == "B" ]
then
	echo "Provided files to compare"
	echo -n "File 1 name or route: "
	read file1
	echo -n "File 2 name or route: "
	read file2

	echo -e "\nCalculating and comparing hashes...\n"

	echo "MD5 Hash comparison"

	md5file1=$(md5sum $file1 | cut -d ' ' -f 1)
	md5file2=$(md5sum $file2 | cut -d ' ' -f 1)

	echo $md5file1
	echo $md5file2

	if [ $md5file1 == $md5file2 ]
	then
		echo -e "Everything looks normal\n"
	else
		echo -e "Something smells fishy here\n"
	fi

	echo "SHA1 Hash comparison"

	sha1file1=$(sha1sum $file1 | cut -d ' ' -f 1)
	sha1file2=$(sha1sum $file2 | cut -d ' ' -f 1)

	echo $sha1file1
	echo $sha1file2

	if [ $sha1file1 == $sha1file2 ]
	then
		echo -e "Everything looks normal\n"
	else
		echo -e "Something smells fishy here\n"
	fi

	echo "SHA256 Hash comparison"

	sha256file1=$(sha256sum $file1 | cut -d ' ' -f 1)
	sha256file2=$(sha256sum $file2 | cut -d ' ' -f 1)

	echo $sha256file1
	echo $sha256file2

	if [ $sha256file1 == $sha256file2 ]
	then
		echo -e "Everything looks normal\n"
	else
		echo -e "Something smells fishy here\n"
	fi
fi
