#!/bin/bash
. /usr/local/lib/7dtd/common.sh

# @param string $1
#   Input string.
# @param int $2
#   Cut an amount of characters from left side of string.
# @param int [$3]
#   Leave an amount of characters in the truncated string.
substr()
{
    local length=${3}

    if [ -z "${length}" ]; then
        length=$((${#1} - ${2}))
    fi

    local str=${1:${2}:${length}}

    if [ "${#str}" -eq "${#1}" ]; then
        echo "${1}"
    else
        echo "${str}"
    fi
}

# @param string $1
#   Input string.
# @param string $2
#   String that will be searched in input string.
# @param int [$3]
#   Offset of an input string.
strpos()
{
    local str=${1}
    local offset=${3}

    if [ -n "${offset}" ]; then
        str=`substr "${str}" ${offset}`
    else
        offset=0
    fi

    str=${str/${2}*/}

    if [ "${#str}" -eq "${#1}" ]; then
        return 0
    fi

    echo $((${#str}+${offset}))
}



###check for args, exit if none
sDBPath="/home/sdtd/instances/7n2l/testing/log.txt"
#echo $(date) >> /home/sdtd/instances/7n2l/testing/log.txt
echo $(date) >> $sDBPath
echo $(whoami) >> $sDBPath
echo $(ulimit -n) >> $sDBPath
echo "\$1: $1 \$2: $2 \$3: $3" >> $sDBPath
echo "----------" >> $sDBPath
echo "" >> $sDBPath
sPLY=$2
sSTR=$3
echo ${strpos "${sSTR}" "/bot"} >> $sDBPath	
exit 0

if [ strpos "${sSTR}" "/bot" ] then;
	echo "$2 you rang?" >> $sDBPath	
	#telnetCommand $1 say "$2 you rang?"
fi
#if [ strpos "${sSTR}" "/bot you" -gt 0 ] then;
#	sRESP=substr "${3}" 10 ${#$sSTR}
#	telnetCommand $1 say "NO! $2 YOU $sRESP !!!"
#fi




















