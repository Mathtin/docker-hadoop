FROM debian:11-slim

LABEL org.opencontainers.image.authors="Daniel [Mathtin] Shiko <wdaniil@mail.ru>"

#
# Install basic packages
#

RUN apt-get update && apt-get install software-properties-common -y --no-install-recommends && \
      apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main' && \
      apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      procps \
      openjdk-8-jdk \
      scala \
      net-tools \
      curl \
      netcat \
      gnupg \
      libsnappy-dev \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/


#
# Install Hadoop distr
#

ENV HADOOP_BASE_URL https://dist.apache.org/repos/dist/release/hadoop/common
ENV HADOOP_VERSION 3.3.1
ENV HADOOP_URL $HADOOP_BASE_URL/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

RUN curl -O $HADOOP_BASE_URL/KEYS
RUN gpg --import KEYS
RUN rm KEYS

RUN set -x \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && curl -fSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc \
    && gpg --verify /tmp/hadoop.tar.gz.asc \
    && tar -xvf /tmp/hadoop.tar.gz -C /opt/ \
    && rm /tmp/hadoop.tar.gz*

#
# Install Hive distr
#

ENV HIVE_BASE_URL https://dist.apache.org/repos/dist/release/hive
ENV HIVE_VERSION 3.1.2
ENV HIVE_URL $HIVE_BASE_URL/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz

RUN curl -O $HIVE_BASE_URL/KEYS
RUN gpg --import KEYS
RUN rm KEYS

RUN set -x \
    && curl -fSL "$HIVE_URL" -o /tmp/hive.tar.gz \
    && curl -fSL "$HIVE_URL.asc" -o /tmp/hive.tar.gz.asc \
    && gpg --verify /tmp/hive.tar.gz.asc \
    && tar -xvf /tmp/hive.tar.gz -C /opt/ \
    && mv /opt/apache-hive-$HIVE_VERSION-bin /opt/hive-$HIVE_VERSION \
    && rm /tmp/hive.tar.gz*


#
# Install Spark distr
#

ENV SPARK_BASE_URL https://dist.apache.org/repos/dist/release/spark
ENV SPARK_VERSION 3.2.0
ENV SPARK_BINS_VERSION hadoop3.2-scala2.13
ENV SPARK_URL $SPARK_BASE_URL/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-$SPARK_BINS_VERSION.tgz

RUN curl -O $SPARK_BASE_URL/KEYS
RUN gpg --import KEYS
RUN rm KEYS

RUN set -x \
    && curl -fSL "$SPARK_URL" -o /tmp/spark.tar.gz \
    && curl -fSL "$SPARK_URL.asc" -o /tmp/spark.tar.gz.asc \
    && gpg --verify /tmp/spark.tar.gz.asc \
    && tar -xvf /tmp/spark.tar.gz -C /opt/ \
    && mv /opt/spark-$SPARK_VERSION-bin-$SPARK_BINS_VERSION /opt/spark-$SPARK_VERSION \
    && rm /tmp/spark.tar.gz*

#
# Setup enviroment
#

RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
#COPY hadoop-env.sh /etc/hadoop/
RUN mkdir /opt/hadoop-$HADOOP_VERSION/logs
RUN mkdir /hadoop-data

RUN mkdir -p /etc/hive
RUN ln -s /opt/hive-$HIVE_VERSION/conf /etc/hive/conf
COPY hive-site.xml /etc/hive/conf/
COPY beeline-log4j2.properties /etc/hive/conf
COPY hive-env.sh /etc/hive/conf
COPY hive-exec-log4j2.properties /etc/hive/conf
COPY hive-log4j2.properties /etc/hive/conf
COPY ivysettings.xml /etc/hive/conf
COPY llap-daemon-log4j2.properties /etc/hive/conf
RUN mkdir /opt/hive-$HIVE_VERSION/logs
RUN mkdir /hive-data

RUN mkdir -p /etc/spark
RUN ln -s /opt/spark-$SPARK_VERSION/conf /etc/spark/conf
COPY spark-defaults.conf /etc/spark/conf/
#COPY spark-env.sh /etc/spark/conf/
COPY spark-log4j.properties /etc/spark/conf/log4j.properties
RUN mkdir /opt/spark-$SPARK_VERSION/logs
RUN mkdir /spark-data

ENV HDP_VERSION=$HADOOP_VERSION
ENV HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV YARN_CONF_DIR=$HADOOP_CONF_DIR

ENV HIVE_HOME=/opt/hive-$HIVE_VERSION
ENV HIVE_CONF_DIR=/etc/hive/conf/

ENV SPARK_HOME=/opt/spark-$SPARK_VERSION
ENV SPARK_CONF_DIR=/etc/spark/conf/

ENV MULTIHOMED_NETWORK=0
ENV USER=root
ENV PATH $SPARK_HOME/bin:$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH

ADD entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
