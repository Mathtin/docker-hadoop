#!/usr/bin/env bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This file is sourced when running various Spark programs.
# Copy it as spark-env.sh and edit that to configure Spark for your site.

# Options read when launching programs locally with
# ./bin/run-example or ./bin/spark-submit
# - HADOOP_CONF_DIR, to point Spark towards Hadoop configuration files
# - SPARK_LOCAL_IP, to set the IP address Spark binds to on this node
# - SPARK_PUBLIC_DNS, to set the public dns name of the driver program

# Options read by executors and drivers running inside the cluster
# - SPARK_LOCAL_IP, to set the IP address Spark binds to on this node
# - SPARK_PUBLIC_DNS, to set the public DNS name of the driver program
# - SPARK_LOCAL_DIRS, storage directories to use on this node for shuffle and RDD data
# - MESOS_NATIVE_JAVA_LIBRARY, to point to your libmesos.so if you use Mesos

export SPARK_VERSION=${SPARK_VERSION:-3.2.0}
export SPARK_HOME=${SPARK_HOME:-/opt/spark-$SPARK_VERSION}
export SPARK_LOG_DIR=${SPARK_LOG_DIR:-/opt/spark-$SPARK_VERSION/logs}

#export CLASSPATH="$CLASSPATH:$HADOOP_HOME/*:$HADOOP_COMMON_HOME/*:$HADOOP_HDFS_HOME/*:$HADOOP_YARN_HOME/*:$HADOOP_MAPRED_HOME/*"

export SPARK_LIBRARY_PATH=${SPARK_LIBRARY_PATH:-$SPARK_HOME/lib}
export SCALA_LIBRARY_PATH=${SCALA_LIBRARY_PATH:-$SPARK_HOME/lib}

export SPARK_LIBRARY_PATH=$SPARK_LIBRARY_PATH:$HADOOP_HOME/lib/native
export SPARK_DIST_CLASSPATH=$(hadoop classpath)