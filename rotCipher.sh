#!/bin/bash

#rot(1-13) cipher and decipher

abc=abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz

echo "The rot cipher"

echo -n "Enter word or phrase to cipher or decipher: "
read userString
echo -n "Enter number of characters to rotate: "
read rotCipher
echo -n "Encode or Decode: "
read code

if [ $code == "encode" ]
then
	newphrase=$(echo $userString | tr "${abc:0:26}" "${abc:${rotCipher}:26}")
	echo $newphrase
else
	newRot=$(expr 26 - $rotCipher)
	newphrase=$(echo $userString | tr "${abc:0:26}" "${abc:${newRot}:26}")
	echo $newphrase
fi
