#!/bin/bash

set -e

log_err() { echo "[ERROR] $@" 1>&2; }
log_info() { echo "[INFO] $@" 1>&2; }

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
    
    log_info "Configuring $module"
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
        var="${envPrefix}_${c}"
        value=${!var}
        log_info " - Setting $name=$value"
        addProperty $path $name "$value"
    done
}

function install_distr() {
    if [[ -z "$1" ]] || [[ -z "$2" ]]; then
        echo "Usage: install_distr {url} {tmp_path} [{initial_name} {final_name}]"
        return 1
    fi
    local url=$1
    local tmp_path=$2
    local initial_name=$3
    local final_name=${4:-$initial_name}
    curl -fSL "$url" -o $tmp_path \
        && curl -fSL "$url.asc" -o $tmp_path.asc \
        && gpg --verify $tmp_path.asc \
        && tar -xf $tmp_path -C /opt/ \
        && ([[ "$initial_name" = "$final_name" ]] || mv /opt/$initial_name /opt/$final_name) \
        && rm $tmp_path*
}

function import_keys() {
    if [[ -z "$1" ]]; then
        echo "Usage: import_keys {base_url}"
        return 1
    fi
    local base_url=$1
    curl -fSL $base_url/KEYS -o /tmp/hadoop_dist_KEYS \
        && gpg --import /tmp/hadoop_dist_KEYS \
        && rm /tmp/hadoop_dist_KEYS
}


if [[ "$1" = "uninstall" ]]; then
    INSTALL_COMPLETE=1
    if [[ -z "$HADOOP_HOME" ]]; then
        log_err "\$HADOOP_HOME is not set"
        INSTALL_COMPLETE=0
    fi
    if [[ -z "$HIVE_HOME" ]]; then
        log_err "\$HIVE_HOME is not set"
        INSTALL_COMPLETE=0
    fi
    if [[ -z "$SPARK_HOME" ]]; then
        log_err "\$SPARK_HOME is not set"
        INSTALL_COMPLETE=0
    fi
    if [[ ! -f /etc/profile.d/hadoop.sh ]]; then
        log_err "/etc/profile.d/hadoop.sh not found"
        INSTALL_COMPLETE=0
    fi
    if [[ ! -h /etc/hadoop ]]; then
        log_err "/etc/hadoop not found"
        INSTALL_COMPLETE=0
    fi
    if [[ ! -d /etc/hive ]]; then
        log_err "/etc/hive not found"
        INSTALL_COMPLETE=0
    fi
    if [[ ! -d /etc/spark ]]; then
        log_err "/etc/spark not found"
        INSTALL_COMPLETE=0
    fi
    if [[ "$INSTALL_COMPLETE" = "0" ]]; then
        log_err "Incomplete installation! Exiting...."
        exit 1
    fi
    rm /etc/profile.d/hadoop.sh
    rm /etc/hadoop
    rm -r /etc/hive
    rm -r /etc/spark
    rm -r $HADOOP_HOME
    rm -r $HIVE_HOME
    rm -r $SPARK_HOME
    exit 0
fi

#
# Install basic packages
#

if [[ "$1" = "reconfig" ]]; then
    INSTALL_HADOOP=0
    INSTALL_HIVE=0
    INSTALL_SPARK=0
else
    apt-get update && apt-get install -y \
        procps \
        openjdk-8-jdk \
        scala \
        net-tools \
        curl \
        netcat \
        gnupg \
        libsnappy-dev
fi

#
# Install Hadoop distr
#

HADOOP_BASE_URL=https://dist.apache.org/repos/dist/release/hadoop/common
HADOOP_VERSION=3.3.1
HADOOP_URL=$HADOOP_BASE_URL/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

INSTALL_HADOOP=${INSTALL_HADOOP:-1}
if [[ "$INSTALL_HADOOP" = "1" ]] && [[ -d "/opt/hadoop-$HADOOP_VERSION" ]]; then
    read -p "Hadoop dir already present. Reinstall? (Y/N): " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_HADOOP=0
    else
        rm -r /opt/hadoop-$HADOOP_VERSION
    fi
fi

if [[ "$INSTALL_HADOOP" = "1" ]]; then
    log_info "Importing hadoop public certificate"
    import_keys $HADOOP_BASE_URL
    log_info "Downloading hadoop dist"
    install_distr "$HADOOP_URL" /tmp/hadoop.tar.gz
fi

#
# Install Hive distr
#

HIVE_BASE_URL=https://dist.apache.org/repos/dist/release/hive
HIVE_VERSION=3.1.2
HIVE_URL=$HIVE_BASE_URL/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz

INSTALL_HIVE=${INSTALL_HIVE:-1}
if [[ "$INSTALL_HIVE" = "1" ]] && [[ -d "/opt/hive-$HIVE_VERSION" ]]; then
    read -p "Hive dir already present. Reinstall? (Y/N): " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_HIVE=0
    else
        rm -r /opt/hive-$HIVE_VERSION
    fi
fi

if [[ "$INSTALL_HIVE" = "1" ]]; then
    log_info "Importing hive public certificate"
    import_keys $HIVE_BASE_URL
    log_info "Downloading hive dist"
    install_distr "$HIVE_URL" /tmp/hive.tar.gz apache-hive-$HIVE_VERSION-bin hive-$HIVE_VERSION
fi


#
# Install Spark distr
#

SPARK_BASE_URL=https://dist.apache.org/repos/dist/release/spark
SPARK_VERSION=3.2.0
SPARK_BINS_VERSION=hadoop3.2-scala2.13
SPARK_URL=$SPARK_BASE_URL/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-$SPARK_BINS_VERSION.tgz

INSTALL_SPARK=${INSTALL_SPARK:-1}
if [[ "$INSTALL_SPARK" = "1" ]] && [[ -d "/opt/spark-$SPARK_VERSION" ]]; then
    read -p "Spark dir already present. Reinstall? (Y/N): " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_SPARK=0
    else
        rm -r /opt/spark-$SPARK_VERSION
    fi
fi

if [[ "$INSTALL_SPARK" = "1" ]]; then
    log_info "Importing spark public certificate"
    import_keys $SPARK_BASE_URL
    log_info "Downloading spark dist"
    install_distr "$SPARK_URL" /tmp/spark.tar.gz spark-$SPARK_VERSION-bin-$SPARK_BINS_VERSION spark-$SPARK_VERSION
fi

#
# Setup enviroment
#

log_info "Removing old config dir links"
rm /etc/profile.d/hadoop.sh 2> /dev/null || true
rm /etc/hadoop 2> /dev/null || true
rm -r /etc/hive 2> /dev/null || true
rm -r /etc/spark 2> /dev/null || true

log_info "Linking config dirs"
ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
mkdir -p /etc/hive
ln -s /opt/hive-$HIVE_VERSION/conf /etc/hive/conf
mkdir -p /etc/spark
ln -s /opt/spark-$SPARK_VERSION/conf /etc/spark/conf

log_info "Copying config files"
cp base/config/hive-site.xml /etc/hive/conf/
cp base/config/beeline-log4j2.properties /etc/hive/conf
cp base/config/hive-env.sh /etc/hive/conf
cp base/config/hive-exec-log4j2.properties /etc/hive/conf
cp base/config/hive-log4j2.properties /etc/hive/conf
cp base/config/ivysettings.xml /etc/hive/conf
cp base/config/llap-daemon-log4j2.properties /etc/hive/conf
cp base/config/spark-defaults.conf /etc/spark/conf/
cp base/config/spark-log4j.properties /etc/spark/conf/log4j.properties

log_info "Building /etc/profile.d/hadoop.sh"
echo "#!/bin/sh" > /etc/profile.d/hadoop.sh
chmod +x /etc/profile.d/hadoop.sh

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
printenv | grep ^JAVA | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh

export HDP_VERSION=$HADOOP_VERSION
printenv | grep ^HDP | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh

export HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION
export HADOOP_CONF_DIR=/etc/hadoop
printenv | grep ^HADOOP | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh

export YARN_HOME=$HADOOP_HOME
export YARN_CONF_DIR=$HADOOP_CONF_DIR
printenv | grep ^YARN | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh

export HIVE_HOME=/opt/hive-$HIVE_VERSION
export HIVE_CONF_DIR=/etc/hive/conf/
printenv | grep ^HIVE | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh

export SPARK_HOME=/opt/spark-$SPARK_VERSION
export SPARK_CONF_DIR=/etc/spark/conf/
printenv | grep ^SPARK | sed 's/^/export /g' >> /etc/profile.d/hadoop.sh

export PATH=$SPARK_HOME/bin:$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH
echo "export PATH=$SPARK_HOME/bin:$HIVE_HOME/bin:$HADOOP_HOME/bin:\$PATH" >> /etc/profile.d/hadoop.sh

export $(grep -v '^#' ./hadoop.env | xargs) 
configure $HADOOP_CONF_DIR/core-site.xml core CORE_CONF
configure $HADOOP_CONF_DIR/hdfs-site.xml hdfs HDFS_CONF
configure $HADOOP_CONF_DIR/yarn-site.xml yarn YARN_CONF
configure $HADOOP_CONF_DIR/httpfs-site.xml httpfs HTTPFS_CONF
configure $HADOOP_CONF_DIR/kms-site.xml kms KMS_CONF
configure $HADOOP_CONF_DIR/mapred-site.xml mapred MAPRED_CONF
configure $HIVE_CONF_DIR/hive-site.xml hive HIVE_CONF
cp $HIVE_CONF_DIR/hive-site.xml $SPARK_CONF_DIR/hive-site.xml

log_info "Hadoop+Spark+Hive successfully installed. Relogin or 'source /etc/profile.d/hadoop.sh'"
