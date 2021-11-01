#!/bin/bash

# Set some sensible defaults
export CORE_CONF_fs_defaultFS=${CORE_CONF_fs_defaultFS:-hdfs://`hostname -f`:8020}

function addProperty() {
  local path=$1
  local name=$2
  local value=$3

  local entry="<property><name>$name</name><value>${value}</value></property>"
  local escapedEntry=$(echo $entry | sed 's/\//\\\//g')
  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path
}

function configure() {
    local path=$1
    local module=$2
    local envPrefix=$3

    local var
    local value
    
    echo "Configuring $module"
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
        var="${envPrefix}_${c}"
        value=${!var}
        echo " - Setting $name=$value"
        addProperty $path $name "$value"
    done
}

configure $HADOOP_CONF_DIR/core-site.xml core CORE_CONF
configure $HADOOP_CONF_DIR/hdfs-site.xml hdfs HDFS_CONF
configure $HADOOP_CONF_DIR/yarn-site.xml yarn YARN_CONF
configure $HADOOP_CONF_DIR/httpfs-site.xml httpfs HTTPFS_CONF
configure $HADOOP_CONF_DIR/kms-site.xml kms KMS_CONF
configure $HADOOP_CONF_DIR/mapred-site.xml mapred MAPRED_CONF
configure $HIVE_CONF_DIR/hive-site.xml hive HIVE_CONF
cp $HIVE_CONF_DIR/hive-site.xml $SPARK_CONF_DIR/hive-site.xml

echo "#!/bin/sh" > /etc/profile.d/hadoop.sh
chmod +x /etc/profile.d/hadoop.sh

env | grep JAVA | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh
env | grep HADOOP | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh
env | grep YARN | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh
env | grep HDFS | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh
env | grep MAPRED | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh
env | grep HIVE | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh
env | grep SPARK | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh
echo "export PATH=$PATH" >> /etc/profile.d/hadoop.sh
service ssh start

function wait_for_it()
{
    local serviceport=$1
    local service=${serviceport%%:*}
    local port=${serviceport#*:}
    local retry_seconds=5
    local max_try=100
    let i=1

    nc -z $service $port
    result=$?

    until [ $result -eq 0 ]; do
      echo "[$i/$max_try] check for ${service}:${port}..."
      echo "[$i/$max_try] ${service}:${port} is not available yet"
      if (( $i == $max_try )); then
        echo "[$i/$max_try] ${service}:${port} is still not available; giving up after ${max_try} tries. :/"
        exit 1
      fi
      
      echo "[$i/$max_try] try in ${retry_seconds}s once again ..."
      let "i++"
      sleep $retry_seconds

      nc -z $service $port
      result=$?
    done
    echo "[$i/$max_try] $service:${port} is available."
}

for i in ${SERVICE_PRECONDITION[@]}
do
    wait_for_it ${i}
done

exec $@
