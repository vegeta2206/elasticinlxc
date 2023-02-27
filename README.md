# elasticinlxc
Create elastic cluster in a nutshell with LXC Containers

- 5 ELK Data nodes
- 2 ELK Master nodes
- 1 Kibana web front
- 1 Logstash ingester
+------------------+---------+-----------------------+------+-----------+-----------+
|       NAME       |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+------------------+---------+-----------------------+------+-----------+-----------+
| elkdata1         | RUNNING | 10.221.227.127 (eth0) |      | CONTAINER | 0         |
+------------------+---------+-----------------------+------+-----------+-----------+
| elkdata2         | RUNNING | 10.221.227.134 (eth0) |      | CONTAINER | 0         |
+------------------+---------+-----------------------+------+-----------+-----------+
| elkdata3         | RUNNING | 10.221.227.57 (eth0)  |      | CONTAINER | 0         |
+------------------+---------+-----------------------+------+-----------+-----------+
| elkdata4         | RUNNING | 10.221.227.52 (eth0)  |      | CONTAINER | 0         |
+------------------+---------+-----------------------+------+-----------+-----------+
| elkdata5         | RUNNING | 10.221.227.100 (eth0) |      | CONTAINER | 0         |
+------------------+---------+-----------------------+------+-----------+-----------+
| elkmaster1       | RUNNING | 10.221.227.113 (eth0) |      | CONTAINER | 0         |
+------------------+---------+-----------------------+------+-----------+-----------+
| elkmaster2       | RUNNING | 10.221.227.129 (eth0) |      | CONTAINER | 0         |
+------------------+---------+-----------------------+------+-----------+-----------+
| kibana           | RUNNING | 10.221.227.122 (eth0) |      | CONTAINER | 0         |
+------------------+---------+-----------------------+------+-----------+-----------+
| logstash         | RUNNING | 10.221.227.3 (eth0)   |      | CONTAINER | 0         |
+------------------+---------+-----------------------+------+-----------+-----------+

# Fully tested on Ubuntu Server 22.04 with no problems at all.

Everything is checked such sysctl variables to ensure no trouble.

AA_delete_cluster.sh
- delete previously created Elastic cluster

00_buildCluster.sh
- create a complete elastic cluster from scratch

04_check_services.sh
- print all LXC containers linked to elastic cluster (listen port/ip, elk indexes, nodes roles
