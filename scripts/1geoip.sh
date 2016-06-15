#!/bin/bash

. /usr/local/lib/7dtd/common.sh

#CONT="`wget -qO- http://62.138.3.36/telnet/geoip.php?ip=$5`"
CONT=$(php -r "echo geoip_continent_code_by_name('$5');")
STAMP="`date`"
if [ "$CONT" == "AS" ]; then
	#echo "Player $3 with steam ID: $4, IP: $5 and contcode: "$CONT" joined the game" >> /root/banlog.txt
	#telnetCommand $1 "say \"Player $3 with steam ID: $4, IP: $5 and continent code: "$CONT" joined the game\""
	#echo "Player $3 with steam ID: $4, IP: $5 and contcode: "$CONT" joined the game" >> /root/banlog.txt
	telnetCommand $1 "ban add $4 1 year \"geo:AS\""
	echo "$STAMP: Player $3 was banned with steam ID: $4 and IP: $5" >> /root/banlog.txt
fi
