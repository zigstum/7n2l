#!/bin/bash
. /usr/local/lib/7dtd/common.sh
INST="dev"
STID=$1
MSG="$2";
echo "$MSG" >> /home/sdtd/instances/dev/hooks/scripts/msg.txt
RET=$(telnetCommand $INST "sayplayer $STID \"$MSG\"")
exit 0;
