#!/bin/bash

CONTAINER=$1

#############################################
### check optimal sysctl.conf key
### vm.max_map_count=262144 RECOMMANDED
###
checkSysctlParam ()
{
        MYPARAM=$1
        MYVALUE=$2
        TEST=$(sysctl -n ${MYPARAM} 2>&1)
        if [ $? -ne 255 ]; then
                if [ $TEST -eq ${MYVALUE} ]; then
                        echo -e "\e[32m${MYPARAM} = $TEST sounds GOOD\e[39m"
                else
                        echo -e "\e[33m${MYPARAM} = $TEST is NOT RECOMMANDED value !\e[39m"
                fi
        else
                echo -e "\e[31m${MYPARAM} sysctl setting MISSING\e[39m"
                echo -e "\e[31msysctl -w ${MYPARAM}=${MYVALUE}\e[39m"
                echo -e ""
        fi
}

###
### Recommanded settings
###
checkSysctlParam vm.max_map_count 262144
checkSysctlParam net.ipv6.conf.all.disable_ipv6 1
checkSysctlParam net.ipv6.conf.default.disable_ipv6 1
checkSysctlParam net.ipv6.conf.lo.disable_ipv6 1


#############################################

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
lxc exec $CONTAINER -- apt-get -qq install apt-transport-https ca-certificates gnupg2 default-jre wget -y

echo -e "\e[31mConfiguring WGET proxy...\e[39m"
lxc file push wgetrc.params $CONTAINER/root/.wgetrc

echo -e "\e[31mGet GPG Elastic Repository...\e[39m"
lxc exec $CONTAINER -- sh -c 'wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -'

echo -e "\e[31mCreating Elastic Repository APT config file...\e[39m"
lxc exec $CONTAINER -- sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'

echo -e "\e[31mUpdating packages...\e[39m"
lxc exec $CONTAINER -- apt update

echo -e "\e[31mSetting JAVA_HOME environment...\e[39m"
lxc exec $CONTAINER -- sh -c 'echo "JAVA_HOME=\"/usr/lib/jvm/java-11-openjdk-amd64\"" |tee -a /etc/environment'

echo -e "\e[31mInstalling ELASTICSEARCH ...\e[39m"
lxc exec $CONTAINER -- apt-get -qq install elasticsearch -y

echo -e "\e[31mChecking ELASTICSEARCH Status...\e[39m"
lxc exec $CONTAINER -- service elasticsearch status

echo -e "\e[31mDeleting default ELASTICSEARCH.YML...\e[39m"
lxc file delete ${CONTAINER}/etc/elasticsearch/elasticsearch.yml

echo -e "\e[31mCopying ELASTICSEARCH.YML...\e[39m"
lxc file push ${CONTAINER}.yml ${CONTAINER}/etc/elasticsearch/elasticsearch.yml

echo -e "\e[31m ####################### FINISHED #######################\e[39m"

