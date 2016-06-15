#!/bin/bash
. /usr/local/lib/7dtd/common.sh
INST="dev"
STID=$1
MSG="$2";
RET=$(telnetCommand $INST "kick $STID \"$MSG\"")
exit 0;