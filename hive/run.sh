#!/bin/bash

function hdfs_in_safe_mode() {
  hdfs dfsadmin -safemode get | grep ON > /dev/null
}

if [ $1 = "metastore" ]; then
    echo "Waiting for HDFS to leave safe mode"
    while hdfs_in_safe_mode; do
        sleep 1;
    done
    echo "Starting metastore"
    schematool -dbType postgres -initSchema
    hive --service metastore
    exit 0
fi

hadoop fs -mkdir       /tmp
hadoop fs -mkdir -p    /apps/hive/warehouse
hadoop fs -chmod g+w   /tmp
hadoop fs -chmod g+w   /apps/hive/warehouse

cd $HIVE_HOME/bin
./hiveserver2 --hiveconf hive.server2.enable.doAs=false
