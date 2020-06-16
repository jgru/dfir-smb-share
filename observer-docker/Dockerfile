FROM debian:buster-slim

## Dockerfile author
MAINTAINER J4n 6ru <j4n6ru@gmail.com>

## Install packages
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y openssl curl inotify-tools libdigest-sha-perl


COPY observe.sh /
RUN chmod +x /observe.sh

## Mapping volumes
RUN mkdir /watchdir
VOLUME ["/watchdir"]

RUN mkdir /workdir
VOLUME ["/workdir"]

ENV hash="md5sum"

CMD ["sh", "-c", "./observe.sh /watchdir /workdir ${hash}"]  # sh -c is neccessary to access env vars
