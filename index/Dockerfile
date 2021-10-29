FROM python:3.9-slim-bullseye

RUN apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      netcat \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www

COPY index.html /var/www

WORKDIR /var/www

ADD entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
