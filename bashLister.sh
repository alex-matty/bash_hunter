#!/bin/bash

# Wordlist generator

echo "Wordlist generator"

echo -n "Base word to generate wordlist: "
read word
echo -n "Want to append numbers: "
read appendNumbers

if [[ $appendNumbers == "yes" ]]
then
	echo -n "First Number to append: "
	read firstNumber
	echo -n "Last Number to append: "
	read lastNumber
fi

echo -n "133t iterations: "
read leet
echo -n "Filename to generate: "
read fileName
fileName="$fileName"".txt"

newWord=$(echo $word | tr [:upper:] [:lower:])
wordArray+=("${newWord}")

newWord=$(echo $word | tr [:lower:] [:upper:])
wordArray+=("${newWord}")

newWord=$(echo "${word^}")
wordArray+=("${newWord}")

# If any of these characters is present in the string, switch it with the corresponding number

if [[ $leet == "yes" ]]
then
	for element in ${wordArray[@]}
	do
		if [[ $element == *"e"* ]] || [[ $element == *"E"* ]]
		then
			newWord=$(echo $element | tr eE 3)
			wordArray+=("${newWord}")
		fi

		for element in ${wordArray[@]}
		do
			if [[ $element == *"s"* ]] || [[ $element == *"S"* ]]
			then
				newWord=$(echo $element | tr sS 5)
				wordArray+=("${newWord}")
			fi
		done
	done
fi

# If number append is set

for i in ${wordArray[@]}
do
	echo $i >> $fileName

	if [[ $appendNumbers == "yes" ]]
	then
		newFirst=$firstNumber
		while [[ $firstNumber -le $lastNumber ]]
		do
			echo "$i$firstNumber" >> $fileName
			let firstNumber=firstNumber+1
		done
		firstNumber=$newFirst
	fi
done
