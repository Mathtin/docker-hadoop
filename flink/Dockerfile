FROM flink:1.13.2-scala_2.11

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
    
RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
RUN mkdir /opt/hadoop-$HADOOP_VERSION/logs
RUN mkdir /hadoop-data

ENV HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
ENV HADOOP_CLASSPATH=/etc/hadoop:/opt/hadoop-3.3.1/share/hadoop/common/lib/*:/opt/hadoop-3.3.1/share/hadoop/common/*:/opt/hadoop-3.3.1/share/hadoop/hdfs:/opt/hadoop-3.3.1/share/hadoop/hdfs/lib/*:/opt/hadoop-3.3.1/share/hadoop/hdfs/*:/opt/hadoop-3.3.1/share/hadoop/mapreduce/*:/opt/hadoop-3.3.1/share/hadoop/yarn:/opt/hadoop-3.3.1/share/hadoop/yarn/lib/*:/opt/hadoop-3.3.1/share/hadoop/yarn/*
