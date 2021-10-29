FROM mathtin/hadoop-base:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8

LABEL org.opencontainers.image.authors="Daniel [Mathtin] Shiko <wdaniil@mail.ru>"

HEALTHCHECK CMD curl -f http://localhost:10002/ || exit 1

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 10000
EXPOSE 10002

CMD ["/run.sh"]
