#!/bin/sh

echo "\e[33mDeleting elkdata1 node\e[39m" 
lxc delete --force elkdata1 2>/dev/null

echo "\e[33mDeleting elkdata2 node\e[39m"
lxc delete --force elkdata2 2>/dev/null

echo "\e[33mDeleting elkdata3 node\e[39m"
lxc delete --force elkdata3 2>/dev/null

echo "\e[33mDeleting elkdata4 node\e[39m"
lxc delete --force elkdata4 2>/dev/null

echo "\e[33mDeleting elkdata5 node\e[39m"
lxc delete --force elkdata5 2>/dev/null

echo "\e[33mDeleting elkmaster1 node\e[39m"
lxc delete --force elkmaster1 2>/dev/null

echo "\e[33mDeleting elkmaster2 node\e[39m"
lxc delete --force elkmaster2 2>/dev/null

echo "\e[33mDeleting kibana\e[39m"
lxc delete --force kibana 2>/dev/null

echo "\e[33mDeleting logstash\e[39m"
lxc delete --force logstash 2>/dev/null

echo "\e[33mDeleting append*.yml files\e[39m"
rm -f append*.yml 2>/dev/null
