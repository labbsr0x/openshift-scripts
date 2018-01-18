#!/bin/bash

#journalctl -o verbose --output-fields=CONTAINER_NAME,MESSAGE -f CONTAINER_NAME=k8s_market-trader_market-trader-2-tjvzm_bitstock-prod_661d20c6-f713-11e7-95fa-92119a5ae80e_0 | awk 'BEGIN{RS="    CONTAINER_NAME=";FS="    MESSAGE="}{print "[" $1 "] " $2"%"}' | tr -d '\n' | awk 'BEGIN{RS="%";ORS="\n"}{print}'

journalctl -o verbose -f | grep --line-buffered -E CONTAINER_NAME=.*\|MESSAGE=.* | awk 'BEGIN{RS="    CONTAINER_NAME=";FS="    MESSAGE="}{print "[" $1 "] " $2"%"}' | tr -d '\n' | awk 'BEGIN{RS="%";ORS="\n"}{print}'



