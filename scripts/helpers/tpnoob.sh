#!/bin/bash
. /usr/local/lib/7dtd/common.sh
INST="dev"
STID=$1
COORD=$2
RET=$(telnetCommand $INST "tele $STID 521 130 3474")
sleep 5
exit 0;
