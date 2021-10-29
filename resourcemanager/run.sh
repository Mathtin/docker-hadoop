#!/bin/bash

function hdfs_in_safe_mode() {
  hdfs dfsadmin -safemode get | grep ON > /dev/null
}

echo "Archieving spark libs"

tar -czf /tmp/spark-jars.tar.gz $SPARK_HOME/jars/* || (echo "FAILED TO START RESOURCE MANAGER"; sleep 4; false) || exit 1

echo "Waiting for HDFS to leave safe mode"

while hdfs_in_safe_mode; do
  sleep 1;
done

hdfs dfs -mkdir -p /apps/spark

echo "Uploading spark libs to HDFS"

hadoop fs -put -f /tmp/spark-jars.tar.gz /apps/spark || (echo "FAILED TO START RESOURCE MANAGER"; sleep 4; false) || exit 1
rm /tmp/spark-jars.tar.gz

echo "Starting resourcemanager"

$HADOOP_HOME/bin/yarn --config $HADOOP_CONF_DIR resourcemanager || (echo "FAILED TO START RESOURCE MANAGER"; sleep 4; false) || exit 1
