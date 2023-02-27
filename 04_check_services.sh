#!/bin/sh

IP1=$(lxc ls elkdata1 -f csv -c 4|awk '{print $1}')
IP2=$(lxc ls elkdata2 -f csv -c 4|awk '{print $1}')
IP3=$(lxc ls elkdata3 -f csv -c 4|awk '{print $1}')

IP7=$(lxc ls elkdata4 -f csv -c 4|awk '{print $1}')
IP8=$(lxc ls elkdata5 -f csv -c 4|awk '{print $1}')

IP4=$(lxc ls elkmaster1 -f csv -c 4|awk '{print $1}')
IP7=$(lxc ls elkmaster2 -f csv -c 4|awk '{print $1}')

IP5=$(lxc ls kibana -f csv -c 4|awk '{print $1}')
IP6=$(lxc ls logstash -f csv -c 4|awk '{print $1}')

for i in elkdata1 elkdata2 elkdata3 elkdata4 elkdata5 elkmaster1 elkmaster2 kibana logstash
	do 
		echo "\e[33m Checking $i\e[39m"
		CIP=$(lxc ls $i -f csv -c 4|awk '{print $1}')
		echo "\e[32m IP Address $CIP\e[39m"
		lxc exec $i -- ss -tlpn
		echo ""
done

echo "\e[33m Current Indices :\e[39m"
curl -X GET http://${IP1}:9200/_cat/indices?v
echo ""


echo "\e[33m Current ip, role, name, http, master role, uptime\e[39m"
curl -X GET "${IP4}:9200/_cat/nodes?v=true&h=ip,role,name,http,m,uptime&pretty"
echo ""

#
echo "\e[33m Current ip, role, name, http, master role, uptime\e[39m"
curl -X GET http://${IP4}:9200/_cat/nodes?v

#########################################
### create mapping on ELK master node ###
#########################################
echo ""
echo "\e[32m#################################\e[39m"
echo "\e[32m        TO START to play\e[39m"
echo "\e[32m#################################\e[39m"
echo ""

echo "\e[32m Want to create index mappings ? \e[39m"
echo ""
QUERY="curl -v -XPUT \"${IP4}:9200/aaaa-2022.09.12?include_type_name=false\" -H 'Content-Type: application/json' -d '\
{\
  \"settings\" : {\
    \"number_of_shards\" : 3,\
    \"number_of_replicas\" : 1\
  },\
  \"mappings\": {\
    \"properties\": {\
      \"field_1\": { \"type\" : \"text\" },\
        \"field_2\": { \"type\" : \"integer\" },\
        \"field_3\": { \"type\" : \"boolean\" },\
        \"field_4\": { \"type\" : \"text\" },\
      \"created\": {\
        \"type\" : \"date\",\
        \"format\" : \"epoch_second\"\
      }\
    }\
  }\
}\
'"
echo $QUERY
###############################
### Inject data to logstash ###
###############################
echo ""
echo ""
echo "\e[32m Want to inject sample data to index ? \e[39m"
echo ""
echo "for i in {1..10};do echo $i;curl -H \"content-type: application/json\" -d '{\"field1\": \"value1\", \"field2\": \"value2\"}' ${IP6}:5000/myapp1;done"

echo "for i in {1..10};do echo $i;curl -H \"content-type: application/json\" -d '{\"field1\": \"value1\", \"field2\": \"value2\", \"field3\": \"value3\"}' ${IP6}:5000/myapp1;done"
echo "for i in {1..10};do echo $i;curl -H \"content-type: application/json\" -d '{\"field1\": \"value1\", \"field2\": \"value2\", \"field3\": \"value3\", \"field4\": \"value4\"}' ${IP6}:5000/myapp1;done"

echo "for i in {1..10};do echo $i;curl -H \"content-type: application/json\" -d '{\"field1\": \"value1\", \"field2\": \"value2\"}' ${IP6}:5001/myapp2;done"
echo "for i in {1..10};do echo $i;curl -H \"content-type: application/json\" -d '{\"field1\": \"value1\", \"field2\": \"value2\", \"field3\": \"value3\"}' ${IP6}:5001/myapp2;done"
echo "for i in {1..10};do echo $i;curl -H \"content-type: application/json\" -d '{\"field1\": \"value1\", \"field2\": \"value2\", \"field3\": \"value3\", \"field4\": \"value4\"}' ${IP6}:5001/myapp2;done"

