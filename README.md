# elasticinlxc
Create elastic cluster in a nutshell with LXC Containers

- 5 ELK Data nodes
- 2 ELK Master nodes
- 1 Kibana web front
- 1 Logstash ingester

  | elkdata1   | RUNNING | IPV4                  | IPV6 | TYPE      | SNAPSHOTS |
  | ---------- | ------- | --------------------- | ---- | --------- | --------- |
  | elkdata2   | RUNNING | 10.221.227.127 (eth0) |      | CONTAINER | 0         |
  | elkdata3   | RUNNING | 10.221.227.128 (eth0) |      | CONTAINER | 0         |
  | elkdata4   | RUNNING | 10.221.227.129 (eth0) |      | CONTAINER | 0         |
  | elkdata5   | RUNNING | 10.221.227.130 (eth0) |      | CONTAINER | 0         |
  | elkmaster1 | RUNNING | 10.221.227.131 (eth0) |      | CONTAINER | 0         |
  | elkmaster2 | RUNNING | 10.221.227.132 (eth0) |      | CONTAINER | 0         |
  | kibana     | RUNNING | 10.221.227.133 (eth0) |      | CONTAINER | 0         |
  | logstash   | RUNNING | 10.221.227.134 (eth0) |      | CONTAINER | 0         |

  

## Fully tested on Ubuntu Server 22.04 with no problems at all.

### Everything is checked such sysctl variables to ensure no trouble.

#### AA_delete_cluster.sh

- delete previously created Elastic cluster

#### 00_buildCluster.sh

- #### create a complete elastic cluster from scratch

#### 04_check_services.sh

- print all LXC containers linked to elastic cluster (listen port/ip, elk indexes, nodes roles

## WARNING : If your LXD/LXC server use NAT mode, simply add a proxy device in LXC with 
```
$ lxc config device add kibana mykibanaport proxy listen=tcp:0.0.0.0:5601 connect=tcp:10.221.227.133:5601
```
Your Kibana will be joinable through your server. Like mine http://192.168.1.99:5601/
