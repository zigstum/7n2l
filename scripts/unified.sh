#!/bin/bash

# $1 Instance, $2 Entity id, Player $3, steam ID: $4, IP: $5 ownerstid: $6(?)
# Scripts / actions that need to be run on every join, in order of importance:
    #################################################################################
    # 1. GeoIP check - calls php -r "echo geoip_continent_code_by_name('$5');
    #    no calls to telnet
    #   #############
    # 2. Reserve slots - get total number of players.
    #    CURSLOT="$( telnetCommand $INST "lpi" | grep -a "^Total of" | egrep -o "[0-9]+" )"
    #    
    #   Notes: 
    #       Uses LPI to get total players.
    #       Calls DB to get reserved expiration date.
    #       Latest version = phpres.sh
    #   ##############
    # 3. Greeting - Needs to detect new players, give different message.
    #   Notes:
    #       For new player, TP, welcome, give info, inform server.
    #       For existing player, just give standard info (add res expiration later)
    ################################################################################

# Source Allocs common functions
. /usr/local/lib/7dtd/common.sh

# Assign this joiner's data:
STID=$4; PLNME=$3; INST=$1; IP=$5;  
echo "$1 - $2 - $3 - $4 - $5 - $6" >> /root/banlog.txt; exit 0
#Hard code variables for testing:

#STID="76561197968566213"; PLNME="[THE]Lith" #donor
#STID="76561198055041232" PLNME="zigstum"  #admni
#STID="76561198123085860"; PLNME="Prisma501"   #donor
#STID="76561198022492308"  PLNME="randomname" #random

#INST="7n2l"
#IP="94.192.40.254" #EU
#IP="219.238.102.102" #AS


# Make date for logging:
STAMP=$(date)

####################################
# Geo Ip screening Section.
####################################

# Get Continent code of connect user:
CONT=$(php -r "echo geoip_continent_code_by_name('$IP');")
#echo $CONT; exit 0

# If banned continent code:
if [ "$CONT" == "AS" ]; then
#    echo "user banned - AS"; exit 0 ## REMOVE IN PRODUCTION
	telnetCommand $INST "ban add $STID 1 year \"geo:AS\"" # Send command
    # Log it:
	echo "$STAMP: Player $PLNME was banned with steam ID: $STID and IP: $IP" >> /root/banlog.txt
    # Exit, no player to work with.
    exit 0
fi

####################################
# Reserved Slot Section.
####################################
 # Notes:
 #  But First check CURSLOT against MAXSLOT
 #      if not full, continue.
 #      if full, send IP to a separate script (phpres.php)
 #      and get a return to deal with.

# Define Current slots, first LPI
LPI="$(telnetCommand $INST "lpi")"

#echo $LPI; exit 0
# Get current slots:
CURSLOT="$(echo "$LPI" | grep -a "^Total of" | egrep -o "[0-9]+")"
# echo $CURSLOT; exit 0
#CURSLOT=20 # Remove after testing.
# Get max Slot:
MAXSLOT=19 # Need to make this dynamic, too fiddly for now.

# Are we full?
if [ $CURSLOT -ge $MAXSLOT ]; then
    # Define script path
    SRC="/home/sdtd/instances/$INST/hooks/scripts/phpres.php"
    # Send the IP and get result.
    # $RES variables: 5=reserved; 6=admin; 7=not reserved.
    RES="$(php "$SRC" "$STID")"
    # echo $RES; exit 0
    # Do the thing...
    if [ $RES -eq 7 ]; then # not reserved, kick
#        echo "non donor kicked."; exit 0 ## REMOVE IN PRODUCTION
        OUT="$(telnetCommand $INST "kick $STID \"Sorry to be rude $PLNME :/ There is no space left. See 7n2l.com to reserve a slot.\"")"
        echo "$STAMP $OUT" >> /root/banlog.txt

    #else a donor?
    elif [ $RES -eq "5" ]; then #reserved or admin?
#        echo "donor, allow."; ## REMOVE IN PRODUCTION
        OUT="$(telnetCommand $INST "sayplayer $STID \"Welcome $PLNME, you are connected to your reserved slot, thanks for your donation :)\"")"
        echo "$STAMP $OUT" >> /root/banlog.txt

    #else its an admin
    else
#        echo "admin, allow.";  ## REMOVE IN PRODUCTION
        OUT="$(telnetCommand $INST "sayplayer $STID \"Welcome $PLNME, you are connected to your admin slot\"")"
        echo "$STAMP $OUT" >> /root/banlog.txt
    fi
    # exit 0 # exit we're done.
fi # not full up, carry on...
echo "not full, continue..." >> /root/banlog.txt
####################################
# Greeting Section.
####################################
 # Notes:
 #  Two scenarios
 #      Player is known, send welcome message.
 #      Player not known, TP to safe house and send messages.
####################################

# Is Player known? Send 'LKP playername' and store result
# Escape the search pattern or grep will fail on '\ $ [ ] ( ) { } | ^ . ? + *'
# http://stackoverflow.com/questions/11856054/bash-easy-way-to-pass-a-raw-string-to-grep
ere_quote() {
    sed 's/[][\.|$(){}?+*^]/\\&/g' <<< "$*"
}
ESCNAME="1. $(ere_quote "$PLNME")"
#echo $ESCNAME; exit 0
PLTME="$(telnetCommand $INST "lkp \"$PLNME\"" | grep -a "$ESCNAME, " | egrep -o "[0-9]+ m," | egrep -o "[0-9]+")";
# Test for zero playtime
#echo "$PLTME"; exit 0
# expand pattern and check for empty string which grep returns for "0" above, for some reason
if [[ -z "${PLTME// }" ]]; then 
#    echo "zero playtime, TP, send msgs."; exit 0 ## REMOVE IN PRODUCTION
	sleep 3
	telnetCommand $INST "tele $PLNME 685 123 1324"	
    sleep 3
	telnetCommand $INST "sayplayer $STID \"[FFD700]Welcome $PLNME. This is a safe house for new players.\""
	sleep 1
	telnetCommand $INST "sayplayer $STID \"[FFD700]If you have any questions, ask for help in main chat. (T)\""
	sleep 1
	telnetCommand $INST "sayplayer $STID \"[FFD700]Once you leave this building, you will NOT be able to come back in.\""
	sleep 1	
    telnetCommand $INST "sayplayer $STID \"[FFD700]If you spawn with no items, ask an admin for help in main chat.\""
	sleep 1
	telnetCommand $INST "sayplayer $STID \"[FFD700]Be safe Traveller $PLNME, and prosper![-]\""
	telnetCommand $1 "say \"[FFD700]We have a new player! $PLY Please make them welcome :D[-]\""
	echo "$STAMP: TELEPORTED @Player: $PLNME - $STID - time: $PLTME" >> /root/banlog.txt
	exit 0
else # Normal player, send welcome messages.
    echo "has playtime, send welcome msgs."; >> /root/banlog.txt ## REMOVE IN PRODUCTION
    telnetCommand $INST "sayplayer $STID \"[FFD700]Welcome to 7N2L $PLNME, a PVE ONLY server. MINIBIKES ARE BANNED! Check 7n2l.com for Teamspeak3/Webmap/Forums[-]\""
    telnetCommand $INST "sayplayer $STID \"[FFD700]Your playtime this wipe is: $PLTME mins[-]\""
    exit 0
fi

echo "$STAMP shouldnt reach here, problems." >> /root/banlog.txt
exit 1