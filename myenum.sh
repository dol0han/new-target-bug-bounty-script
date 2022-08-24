#!/usr/bin/zsh

# Go get sub-domains!
# TODO LATER ask user "Would you like to Brute-Force sub-domains as well? Y/N? <wordlist>" 
# like: Y "/home/user/wordlists/subdomain-top-1-mil.txt"

amass enum -d $1 -oA amsssenumsublist
sleep 10
subfinder -d $1 -o sfresults.txt

# Combine lists of sub-domains.
# TODO Turn the lists into VAR

for i in $(ls | grep ".txt"); 
do 
	cat $i | sort amsssenumsublist.txt sfresults.txt | uniq > sorted.txt; 
done


while read line;
do
	host "$line";
done<"sorted.txt" | grep "has add" | cut -d" " -f4 > sortedips.txt;


FILE="sortedips.txt"
if test -f "$FILE"; 
then
	sort "$FILE" | uniq -u > ips4nmap.txt;
fi

nmap -A -p- -iL ips4nmap.txt -oS nmapres
cat sorted.txt | httpx > urls.txt
sleep 10
 echo "man you gotta finish me up"