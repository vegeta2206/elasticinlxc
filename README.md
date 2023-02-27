# elasticinlxc
Create elastic cluster in a nutshell with LXC Containers

- 3 ELK Data nodes
- 2 ELK Master nodes
- 1 Kibana web front
- 1 Logstash ingester

# Fully tested on Ubuntu Server 22.04 with no problems at all.

Everything is checked such sysctl variables to ensure no trouble.

AA_delete_cluster.sh
- delete previously created Elastic cluster

00_buildCluster.sh
- create a complete elastic cluster from scratch
