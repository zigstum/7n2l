#!/bin/bash
. /usr/local/lib/7dtd/common.sh

exit 0 

# Need to set a wait, and recheck player is still online.
# or it will continue to TP and spam messages when player is not even there.

#ID=76561198055041232 #zig
#ID=76561198052476626 #fitz
#ID=76561197984640280 #rog
#ID=76561198123085860 #Prisma
#1. zigstum, id=208, steamid=76561198055041232, online=False, ip=94.192.40.254, playtime=1033 m, seen=2016-06-10 17:24
#Total of 520 known

TS=$(date)		# get time for log stamp
STID=$4			# get steam id from args
PLY=$3			# get playername "   "

# Send 'LKP playername' and store result
LKP=$( telnetCommand $1 "lkp \"$3\"")

# Echo and grep out the playtime number only.
PLTME="$( echo $LKP | grep -a "1. $3" | egrep -o "[0-9]+ m," | egrep -o "[0-9]+")"

# Test for zero playtime
if [ $PLTME -eq 0 ]; then 
	sleep 3
	$(telnetCommand $1 "tele $4 685 123 1324")
	sleep 3
	$(telnetCommand $1 "sayplayer $STID \"[FFD700]Welcome $PLY. This is a safe house for new players.\"")
	sleep 1
	$(telnetCommand $1 "sayplayer $STID \"[FFD700]If you have any questions, ask for help in global chat. (T)\"")
	sleep 1
	$(telnetCommand $1 "sayplayer $STID \"[FFD700]Once you leave this building, you will NOT be able to come back in.\"")
	sleep 1
	$(telnetCommand $1 "sayplayer $STID \"[FFD700]Be safe Traveller $PLY, and prosper![-]\"")
	# $(telnetCommand $1 "say \"[FFD700]We have a new traveller: $PLY  -  Fitzy, prepare a room![-]\"")
	echo "$TS: TELEPORTED @Player: $3 - $4 - time: $PLTME" >> /home/sdtd/instances/7n2l/testing/tpsh.txt
	exit 0
	# echo for now, wehn live TP new player or exit.
	# echo "$TS: New player: $3 - $4" >> /home/sdtd/instances/7n2l/testing/tpsh.txt
	# exit 0
fi
echo "$TS: NO ACTION @Player: $3 - $4 - time: $PLTME" >> /home/sdtd/instances/7n2l/testing/tpsh.txt
exit 0
