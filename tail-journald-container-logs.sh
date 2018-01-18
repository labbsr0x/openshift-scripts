#!/bin/bash

journalctl -o verbose -f | grep --line-buffered -E CONTAINER_NAME=.*\|MESSAGE=.* | grep -v CONTAINER_NAME=origin- | awk 'BEGIN{RS="    CONTAINER_NAME=";FS="    MESSAGE="}{print "[" $1 "] " $2"%"}' | tr -d '\n' | awk 'BEGIN{RS="%";ORS="\n"}{print}'



