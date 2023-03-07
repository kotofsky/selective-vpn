# PPTP-Linux for Jackett, Radarr and any torrent client
[![Docker Pulls](https://img.shields.io/docker/pulls/markinas/pptp-client-iptables)](https://hub.docker.com/repository/docker/markinas/pptp-client-iptables)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/markinas/pptp-client-iptables/latest)](https://hub.docker.com/repository/docker/markinas/pptp-client-iptables)

Docker container which runs pure Ubuntu with seldom packages such as 'pptp-linux', 'iptables', 'iproute'. With some 'magic' in iptables rules it will help you to run Radarr and Jackett containers through VPN. In the same time other containers on your machine will ignore the vpn tunnel.

## Docker Features
* Base: Ubuntu 20.04
* Selectively enable or disable PPTP support

# Run container from Docker registry
To run the container use this command, with additional parameters, please refer to the Variables section:

```
$ docker run --privileged  -d \
             --net=host \
              -e "CUSTOM_SUBNET=172.16.240.1/24" \
              -e "RADARR_IP=172.16.240.10" \
              -e "RADARR_PORT=7878" \
              -e "VPN_USERNAME=username" \
              -e "VPN_SERVER=server" \
              -e "VPN_PSWD=password" \
              -e "JACKETT_IP=172.16.240.9" \
              -e "JACKETT_PORT=9117" \
              --restart unless-stopped \
              markinas/pptp-client-iptables
```

# Variables
## Environment Variables
| Variable | Required | Function | Example
|----------|----------|----------|----------|
|`CUSTOM_SUBNET`| Yes | Your custom docker network |`CUSTOM_SUBNET=172.16.240.1/24`
|`RADARR_IP`| Yes | Ip address of your radarr container in custom network |`RADARR_IP=172.16.240.10`
|`RADARR_PORT`| Yes | Port that radarr container expose |`RADARR_PORT=7878`|
|`JACKETT_IP`| Yes | Ip address of your jackett container in custom network |`JACKETT_IP=172.16.240.9`|
|`JACKETT_PORT`| Yes | Port that jackett container expose |`JACKETT_PORT=9117`|
|`TORRENT_IP`| Yes | Ip address of your torrent client container in custom network |`TORRENT_IP=172.16.240.11`|
|`TORRENT_PORT_TCP`| Yes | Port that torrent client container expose |`TORRENT_PORT_TCP=8080`|
|`TORRENT_PORT_UDP`| Yes | Port that torrent client container expose |`TORRENT_PORT_UDP=6881`|
|`VPN_SERVER`| Yes | Address of pptp vpn server |`VPN_SERVER=pptpserver.net`|
|`VPN_USERNAME`| Yes | Username for vpn server |`VPN_USERNAME=username`
|`VPN_PSWD`| Yes | Password for vpn server |`VPN_PSWD=password`

# How it works

First, you should create your custom network with static IP address.   

For example:
```
custom_network:
    name: vpn_custom
    ipam:
      driver: default
      config:
        - subnet: "172.16.240.0/24"
```

After that you should customize network settings for your containers.  

Example:
```
 radarr:
        container_name: radarr
        image: linuxserver/radarr:latest
        restart: unless-stopped
        networks:
                custom_network:
                        ipv4_address: 172.16.240.10
        ports:
                - 0.0.0.0:7878:7878
        environment:
                - PUID=${UID}
                - PGID=${GID}
                - TZ=${TZ} 
        volumes:
                - /etc/localtime:/etc/localtime:ro
                - ${DATA}/radarr:/config # config files
                - ${MERGERFS}/Video:/movies # movies folder
                - ${MERGERFS}/processed:/downloads
```

And that's it. 


# Issues
If you are having issues with this container please submit an issue on GitHub.
Please provide logs, Docker version and other information that can simplify reproducing the issue.
If possible, always use the most up to date version of Docker, you operating system, kernel and the container itself. Support is always a best-effort basis.