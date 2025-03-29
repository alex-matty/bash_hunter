#!/usr/bin/env bash

# Wordlist generator

echo "Wordlist generator"
echo -n "Use single word or wordlist: "
read word

if [[ $word == "wordlist" ]]
then
	echo -n "wordlist to use: "
	read word
	listArray=()
	mapfile listArray < $word
elif [[ $word == "word" ]]
then
	echo -n "Word to use: "
	read word
	listArray=()
	listArray+=("${word[@]}")
fi

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

for x in ${listArray[@]}
do
	newWord=$(echo $x | tr [:upper:] [:lower:])
	wordArray+=("${newWord}")

	newWord=$(echo $x | tr [:lower:] [:upper:])
	wordArray+=("${newWord}")

	newWord=$(echo "${x^}")
	wordArray+=("${newWord}")
done

# If any of these characters is present in the string, switch it with the corresponding number

if [[ $leet == "yes" ]]
then
	for element in ${wordArray[@]}
	do
		if [[ $element == *"e"* ]] || [[ $element == *"E"* ]]
		then
			newWord=$(echo $element | tr eE 3)
			wordArray+=("${newWord}")

		elif [[ $element == *"s"* ]] || [[ $element == *"S"* ]]
		then
			newWord=$(echo $element | tr sS 5)
			wordArray+=("${newWord}")
		fi
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
