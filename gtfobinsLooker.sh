#!/bin/bash

# Check if user has cURL installed if not advise user and end script

if ! command -v curl 2&>/dev/null
then
	echo "cURL is not installed or not in PATH but it's needed. Make sure to install it"
    exit
fi

# Help function to provide usage and syntax 
Help()
{
    echo "$0 search GTFObins from the command line"
    echo -e "User can search for a binary and privilege escalation options provided in GTFObins.com\n"

    echo -e "Example Syntax: $0 -b bash -m SUID\n"

    echo "-b BINARY"
    echo "-m Method"
}

# Get the argument from the user and map the help file if needed
while getopts b:m:h flag
do
    case "${flag}" in
        b) binary=${OPTARG};;
        m) method=${OPTARG};;
        h) Help
            exit;;
    esac
done

if [[ -n $method ]]
then
    curl -s https://gtfobins.github.io/gtfobins/$binary/ | sed '/^$/d' | sed '/^[[:space:]]*$/d' | sed 's/^ *//' | sed 's/ *$//' | sed -n -e "/<h2 id=\".*\" class=\"function-name\">$method<\/h2>/,/<h2 id=\".*\" class=\"function-name\">.*<\/h2>/p" | sed -e 's/<[^>]*>//g' | sed -n '/\/\/ add permalink on headings/q;p' | sed '$d'
else
    curl -s https://gtfobins.github.io/gtfobins/$binary/ | sed '/^$/d' | sed '/^[[:space:]]*$/d' | sed 's/^ *//' | sed 's/ *$//' | sed -n -e "/<h2 id=\".*\" class=\"function-name\">.*\/h2>/,/\/\/ add permalink on headings/p" | sed -e 's/<[^>]*>//g' | sed '$d'
fi