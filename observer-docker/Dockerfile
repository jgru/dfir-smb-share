FROM debian:buster-slim

## Dockerfile author
MAINTAINER J4n 6ru <j4n6ru@gmail.com>

## Install packages
RUN apt-get update \
    && apt-get upgrade \
    && apt-get -y install openssl curl inotify-tools libdigest-sha-perl


COPY artifact-observer.sh /
RUN chmod +x /artifact-observer.sh

## Mapping volumes
RUN mkdir /watchdir
VOLUME ["/watchdir"]

CMD ["./artifact-observer.sh", "/watchdir"]
