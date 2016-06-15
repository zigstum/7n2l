#!/bin/bash
. /usr/local/lib/7dtd/common.sh

telnetCommand $1 "sayplayer $4 \"[FFD700]Welcome to 7N2L $3, a PVE ONLY server. MINIBIKES ARE BANNED! If you spawn with no items, ask an admin for assistance in main chat.[-]\""

#Is it the resident streamer?
#if [ $3 == 76561198047552699 ]; then
#telnetCommand $1 "say \"[FFD700]Sweep your path and cut your grass - Mouse is in the House![-]\""
