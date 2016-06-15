#!/bin/bash
. /usr/local/lib/7dtd/common.sh
#$1 Instance, $2 Entity id, Player $3, steam ID: $4, IP: $5
#UPDATE zigs_steamcon_accounts SET `donor` = '9999999999' WHERE `steam_id` = '76561198052476626' limit 1

# Donors:
RES1=76561198123085860 #prisma -> 4/9/17 -> 1501891199
RES2=76561197975842128 #sy_price -> 11/6/16 -> 1465689599
RES4=76561198040549072 #dusty => 20/7/16 -> 1469059199
RES5=76561198047552699 #mousearian -> 19/1/18 -> 1516406399
RES6=76561197968566213 #The Lith -> 23/9/16 -> 1474675199
RES15=76561198052452582 #Twai (under fitzy) 1/8/16 -> 1470095999
RES7=76561198067992455 #Sky -> 2/7/16 -> 1467503999
RES12=76561198160076746 #Cat -> 29/6/16 -> 1467244799
RES16=76561197984640280 #rog 4/8/16 -> 1470355199
RES10=76561197960290440 #signal -> 24/9/16 -> 1474761599
RES11=76561198113068193 #Squee1 -> 24/7/16 -> 1469404799
RES13=76561198024532316 #Mui -> 30/9/16 -> 1475279999
RES9=76561198274146926 #Stoxy -> 9/7/16
RES17=76561198135272341 #falc steve

# Guests:
#RES8=76561198055041232 #zig
#RES8=76561197993965001 #Amika
#RES8=76561197998889063 #sack
#RES8=76561198011994575 #miss v
RES8=76561198002630658 #Rapha
#RES8=76561198062823690

RES3=76561198049897769 #miss
RES14=76561198052476626 #Fitzy

MAXOPEN=20 #max slots (it counts the one who just joined)
#STID=76561198299780227 #steam id of connecting user
STID=$4

#INST="7n2l" #Define instance name
INST=$1 #Define instance name

#PLY="zigstum" #Define instance name
PLY=$3

#CURSLOT=13
CURSLOT="$( telnetCommand $INST "lpi" | grep -a "^Total of" | egrep -o "[0-9]+" )"

#get datestamp
STAMP="`date`"

#echo "$CURSLOT"
#TODO: Get steam ids into an array and loop through, like php foreach

if [ $CURSLOT -ge $MAXOPEN ]; then
    if (( $STID == $RES1 || $STID == $RES2 || $STID == $RES3 || $STID == $RES4 || $STID == $RES5  || $STID == $RES6  || $STID == $RES7  || $STID == $RES8  || $STID == $RES9 || $STID == $RES10  || $STID == $RES11 || $STID == $RES12  || $STID == $RES13  || $STID == $RES14  || $STID == $RES15 || $STID == $RES16 || $STID == $RES17)); then
    	OUT="$(telnetCommand $1 "sayplayer $STID \"Welcome $PLY, you are connecting to your reserved slot, thanks for your donation :)\"")"
    	echo "$STAMP: full, res user $STID / $PLY, join." >> /root/reservelog.txt
    	# TODO: add one to maxslots here, and have a hook on playerleave that takes one from maxslots if appropriate.
    	exit 0
    fi
    OUT="$(telnetCommand $1 "kick $STID \"Sorry to be rude $PLY :/ There is no space left. See 7n2l.com for info on how to reserve a slot.\"")"
    echo "$STAMP $OUT " >> /root/reservelog.txt
    echo "Players: $CURSLOT : Kicked $STID / $PLY" >> /root/reservelog.txt
    exit 0
fi
echo "$STAMP: quota not reached, exiting..." >> /root/reservelog.txt
exit 0
