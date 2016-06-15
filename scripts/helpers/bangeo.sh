#!/bin/bash
. /usr/local/lib/7dtd/common.sh
INST="dev"
STID=$1
DUR="1 Year"
RET=$(telnetCommand $INST "ban add $STID $DUR \"Sorry, but your geolocation is not allowed on this server.\"")
exit 0;