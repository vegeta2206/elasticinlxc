#!/bin/bash

CONTAINER="logstash"

echo -e "\e[31mCreating new Virtual Machine : ${CONTAINER}\e[39m"
lxc init images:ubuntu/20.04/amd64 $CONTAINER

echo -e "\e[31mAllow limits.memory : 4GB\e[39m"
lxc config set $CONTAINER limits.memory 4096MB

echo -e "\e[31mAllow limits.cpu : 4\e[39m"
lxc config set $CONTAINER limits.cpu 4

echo -e "\e[31mStarting VM ...\e[39m"
lxc start $CONTAINER

echo -e "\e[31mPlease wait 30 sec to allow VM starts\e[39m"
sleep 30

echo -e "\e[31mConfiguring apt repository...\e[39m"
lxc file push aptproxy.params $CONTAINER/etc/apt/apt.conf.d/00proxy

echo -e "\e[31mInstalling packages...\e[39m"
lxc exec $CONTAINER -- apt-get -qq install apt-transport-https ca-certificates gnupg2 default-jre wget curl -y

echo -e "\e[31mConfiguring WGET proxy...\e[39m"
lxc file push wgetrc.params $CONTAINER/root/.wgetrc

echo -e "\e[31mInstalling packages...\e[39m"
lxc exec $CONTAINER -- sh -c 'wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -'
lxc exec $CONTAINER -- sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
lxc exec $CONTAINER -- apt update
lxc exec $CONTAINER -- sh -c 'echo "JAVA_HOME=\"/usr/lib/jvm/java-11-openjdk-amd64\"" |tee -a /etc/environment'
lxc exec $CONTAINER -- apt-get -qq install logstash -y
lxc exec $CONTAINER -- service logstash status
lxc file delete ${CONTAINER}/etc/logstash/logstash.yml
lxc file push ${CONTAINER}.yml ${CONTAINER}/etc/logstash/logstash.yml

IP1=$(lxc ls elkdata1 -f csv -c 4|awk '{print $1}')
IP2=$(lxc ls elkdata2 -f csv -c 4|awk '{print $1}')
IP3=$(lxc ls elkdata3 -f csv -c 4|awk '{print $1}')

IP7=$(lxc ls elkdata4 -f csv -c 4|awk '{print $1}')
IP8=$(lxc ls elkdata5 -f csv -c 4|awk '{print $1}')

IP4=$(lxc ls elkmaster1 -f csv -c 4|awk '{print $1}')
IP7=$(lxc ls elkmaster2 -f csv -c 4|awk '{print $1}')
IP5=$(lxc ls kibana -f csv -c 4|awk '{print $1}')
IP6=$(lxc ls logstash -f csv -c 4|awk '{print $1}')

########################################
### configure data nodes in logstash ###
########################################
LINE1="    hosts => [\"${IP1}\",\"${IP2}\",\"${IP3}\",\"${IP7}\",\"${IP8}\"]"
LINE2="  }"
LINE3="}"

### create default http_inputs.conf ###
cp input_template.conf http_inputs.conf

### complete http_inputs.conf with IP Addresses ###
echo $LINE1 |tee -a http_inputs.conf
echo $LINE2 |tee -a http_inputs.conf
echo $LINE3 |tee -a http_inputs.conf

### Copying files
lxc file push http_inputs.conf $CONTAINER/etc/logstash/conf.d/

### Apply rights
lxc exec $CONTAINER -- chown root:logstash /etc/logstash/logstash.yml
lxc exec $CONTAINER -- chown root:logstash /etc/logstash/conf.d/http_inputs.conf
lxc exec $CONTAINER -- sysctl -w vm.max_map_count=262144

### reload daemon, start & enable
lxc exec $CONTAINER -- systemctl daemon-reload
lxc exec $CONTAINER -- systemctl enable logstash.service
lxc exec $CONTAINER -- systemctl start logstash.service

rm http_inputs.conf

