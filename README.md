# Docker Hadoop Cluster

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Hadoop cluster named "lake" for testing and ETL development. Extended with flink, spark and hive

## Java version

OpenJDK 8

Scala 2.13

## Hadoop Version

Apache Hadoop 3.3.1

Apache Hive 3.1.2

Spark 3.2.0

Flink 1.13.2

## Quick Start

To deploy an example HDFS cluster, run:
```
  docker-compose up
```

To deploy in swarm:
```
docker stack deploy -c docker-compose-v3.yml hadoop
```

OpenVPN profile 'hadoop-cluster.ovpn' will appear in data directory

Access services with links provided by Hadoop Index on [10.10.10.10](http://10.10.10.10)

`docker-compose` creates a docker network that can be found by running `docker network list`, e.g. `dockerhadoop_default`.

Run `docker network inspect` on the network (e.g. `dockerhadoop_default`) to find the IP the hadoop interfaces are published on.

## Configure Environment Variables

The configuration parameters can be specified in the hadoop.env file or as environmental variables for specific services (e.g. namenode, datanode etc.):
```
  CORE_CONF_fs_defaultFS=hdfs://namenode:8020
```

CORE_CONF corresponds to core-site.xml. fs_defaultFS=hdfs://namenode:8020 will be transformed into:
```
  <property><name>fs.defaultFS</name><value>hdfs://namenode:8020</value></property>
```
To define dash inside a configuration parameter, use triple underscore, such as YARN_CONF_yarn_log___aggregation___enable=true (yarn-site.xml):
```
  <property><name>yarn.log-aggregation-enable</name><value>true</value></property>
```

The available configurations are:
* /etc/hadoop/core-site.xml CORE_CONF
* /etc/hadoop/hdfs-site.xml HDFS_CONF
* /etc/hadoop/yarn-site.xml YARN_CONF
* /etc/hadoop/httpfs-site.xml HTTPFS_CONF
* /etc/hadoop/kms-site.xml KMS_CONF
* /etc/hadoop/mapred-site.xml  MAPRED_CONF
* /etc/hive/conf/hive-site.xml  HIVE_CONF

If you need to extend some other configuration file, refer to base/entrypoint.sh bash script.
