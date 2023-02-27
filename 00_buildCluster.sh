#!/bin/sh

STARTTIME=$(date +%s)
SCRIPT=$(basename "$0" |cut -d'.' -f1 )
ts1=$(date +%Y%m%d_%H%M%S)

logMsg() {
        MSG=$1
        shift
        NOW=$(date +%Y%m%d_%H%M%S)
        EPOCH=$(date +%s)

        echo "\e[36munixtime=${EPOCH} elapsed=$(( EPOCH - STARTTIME )) sec currenttime=${NOW} $MSG\e[39m"
        echo "unixtime=${EPOCH} elapsed=$(( EPOCH - STARTTIME )) sec currenttime=${NOW} $MSG" >> "./${SCRIPT}_${ts1}.log"
}

if [ -f appendelk.yml ]; then 
	echo "\e[33mDeleting appendelk.yml\e[39m"
	logMsg "Deleting appendelk.yml"
	rm -f appendelk.yml
fi

if [ -f appendkibana.yml ]; then
	echo "\e[33mDeleting appendkibana.yml\e[39m"
	logMsf "Deleting appendkibana.yml"
        rm -f appendkibana.yml
fi

if [ -f appendhost.yml ]; then
	echo "\e[33mDeleting appendhost.yml\e[39m"
	logMsg "Deleting appendhost.yml"
        rm -f appendhost.yml
fi

logMsg "Creating ELKDATA 1"
sh -c "./01_create_elk.sh elkdata1"
logMsg "Finished creation 1"

logMsg "Creating ELKDATA 2"
sh -c "./01_create_elk.sh elkdata2"
logMsg "Finished creation 2"

logMsg "Creating ELKDATA 3"
sh -c "./01_create_elk.sh elkdata3"
logMsg "Finished creation 3"

logMsg "Creating ELKDATA 4"
sh -c "./01_create_elk.sh elkdata4"
logMsg "Finished creation 4"

logMsg "Creating ELKDATA 5"
sh -c "./01_create_elk.sh elkdata5"
logMsg "Finished creation 5"

logMsg "Creating ELKDATA MASTER 1"
sh -c "./01_create_elk.sh elkmaster1"
logMsg "Finished MASTER creation "

logMsg "Creating ELKDATA MASTER 2"
sh -c "./01_create_elk.sh elkmaster2"
logMsg "Finished MASTER 2 creation "

IP1=$(lxc ls elkdata1 -f csv -c 4|awk '{print $1}')
IP2=$(lxc ls elkdata2 -f csv -c 4|awk '{print $1}')
IP3=$(lxc ls elkdata3 -f csv -c 4|awk '{print $1}')
IP4=$(lxc ls elkdata4 -f csv -c 4|awk '{print $1}')
IP5=$(lxc ls elkdata5 -f csv -c 4|awk '{print $1}')
IP6=$(lxc ls elkmaster1 -f csv -c 4|awk '{print $1}')
IP7=$(lxc ls elkmaster2 -f csv -c 4|awk '{print $1}')

LINE1="discovery.seed_hosts: [\"${IP1}\", \"${IP2}\",\"${IP3}\", \"${IP4}\", \"${IP5}\", \"${IP6}\", \"${IP7}\"]"
LINE2="cluster.initial_master_nodes: [\"${IP6}\", \"${IP7}\"]"
echo $LINE1 |tee appendelk.yml
echo $LINE2 |tee -a appendelk.yml

for i in elkdata1 elkdata2 elkdata3 elkdata4 elkdata5 elkmaster1 elkmaster2;
do
	logMsg "Configuring Elastic Node..."
	lxc file push appendelk.yml $i/tmp/
	lxc exec $i -- sh -c 'cat /tmp/appendelk.yml |tee -a /etc/elasticsearch/elasticsearch.yml'
	lxc exec $i -- chown root:elasticsearch /etc/elasticsearch/elasticsearch.yml

	# only applicable on VirtualMachine
	lxc exec $i -- sysctl -w vm.max_map_count=262144

	lxc exec $i -- systemctl daemon-reload
	lxc exec $i -- systemctl enable elasticsearch.service
	lxc exec $i -- systemctl start elasticsearch.service
	logMsg "Finished node configuration..."
done

logMsg "Creating KIBANA instance"
sh -c "./02_create_kibana.sh kibana"
logMsg "KIBANA ready !"

logMsg "Creating LOGSTASH instance"
sh -c "./03_create_logstash.sh logstash"
logMsg "LOGSTASH ready !"

IP8=$(lxc ls kibana -f csv -c 4|awk '{print $1}')
IP9=$(lxc ls logstash -f csv -c 4|awk '{print $1}')

lxc config device add kibana myport80 proxy listen=tcp:0.0.0.0:80 connect=tcp:${IP8}:5601

echo "KIBANA Url : http://${IP8}/"

