FROM debian:buster-slim

## Dockerfile author
MAINTAINER j4n6ru <j4n6ru@gmail.com>

## Install packages
RUN apt-get update \
    && apt-get upgrade \
    && apt-get -y install dnsmasq \
    && echo "conf-dir=/etc/dnsmasq,*.conf" > /etc/dnsmasq.conf
COPY dnsmasq.conf /etc/dnsmasq/dnsmasq.conf

EXPOSE 67/udp 547/udp

## Mapping volumes
VOLUME ["/etc/dnsmasq"]

ENTRYPOINT ["dnsmasq"]
CMD ["-p0","-d"]
