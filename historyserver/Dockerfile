FROM mathtin/hadoop-base:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8

LABEL org.opencontainers.image.authors="Daniel [Mathtin] Shiko <wdaniil@mail.ru>"

HEALTHCHECK CMD curl -f http://localhost:8188/ || exit 1

ENV YARN_CONF_yarn_timeline___service_leveldb___timeline___store_path=/hadoop/yarn/timeline
RUN mkdir -p /hadoop/yarn/timeline
VOLUME /hadoop/yarn/timeline

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 8188

CMD ["/run.sh"]
