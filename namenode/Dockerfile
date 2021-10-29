FROM mathtin/hadoop-base:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8

LABEL org.opencontainers.image.authors="Daniel [Mathtin] Shiko <wdaniil@mail.ru>"

HEALTHCHECK CMD curl -f http://localhost:9870/ || exit 1

ENV HDFS_CONF_dfs_namenode_name_dir=file:///hadoop/dfs/name
RUN mkdir -p /hadoop/dfs/name
VOLUME /hadoop/dfs/name

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 9870

CMD ["/run.sh"]
