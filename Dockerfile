FROM ubuntu:20.04

RUN apt-get update && apt-get install pptp-linux iproute2 iptables -y 

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0700 /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]