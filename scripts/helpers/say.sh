#!/bin/bash
. /usr/local/lib/7dtd/common.sh
INST="dev"
MSG="$1";
RET=$(telnetCommand $INST "say \"$MSG\"")
exit 0;