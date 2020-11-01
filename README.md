# docker-transmission-wireguard
Wireguard implementation on transmission container from linuxserver


# Usage
## Here are some example snippets to help you get started creating a container.

## docker-compose (recommended)
Compatible with docker-compose v2 schemas.

---
version: "2.1"
services:
  transmission:
    image: linuxserver/transmission
    container_name: transmission
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - TRANSMISSION_WEB_HOME=/combustion-release/ #optional
      - USER=username #optional
      - PASS=password #optional
      - INTERFACE=wg0

    volumes:
      - <path to data>:/config
      - <path to downloads>:/downloads
      - <path to watch folder>:/watch
    ports:
      - 9091:9091
      - 51413:51413
      - 51413:51413/udp
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv6.conf.all.disable_ipv6=0
    restart: unless-stopped

  
## docker cli
docker run -d \
  --name=transmission \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e TRANSMISSION_WEB_HOME=/combustion-release/ `#optional` \
  -e USER=username `#optional` \
  -e PASS=password `#optional` \
  -p 9091:9091 \
  -p 51413:51413 \
  -p 51413:51413/udp \
  -v <path to data>:/config \
  -v <path to downloads>:/downloads \
  -v <path to watch folder>:/watch \
  --restart unless-stopped \
  linuxserver/transmission
  
# Parameters
Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate <external>:<internal> respectively. For example, -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080 outside the container.

## Parameter	Function
-p 9091	                                      WebUI
-p 51413	                                    Torrent Port TCP
-p 51413/udp	                                Torrent Port UDP
-e PUID=1000	                                for UserID - see below for explanation
-e PGID=1000	                                for GroupID - see below for explanation
-e TZ=Europe/London	                          Specify a timezone to use EG Europe/London.
-e TRANSMISSION_WEB_HOME=/combustion-release/	Specify an alternative UI options are /combustion-release/, /transmission-web-control/, and /kettu/ .
-e USER=username	                            Specify an optional username for the interface
-e PASS=password	                            Specify an optional password for the interface
-v /config	                                  Where transmission should store config files and logs.
-v /downloads	                                Local path for downloads.
-v /watch	                                    Watch folder for torrent files.
-v /etc/wireguard                             location of wireguard config file


# Docker file
to be able to reach trasnmission from local network something simialr to the following needs to be added to wireguard config file:

PostUp = DROUTE=$(ip route | grep default | awk '{print $3}'); HOMENET=192.168.0.1/24; ip route add $HOMENET via $DROUTE;iptables -I OUTPUT -d $HOMENET -j ACCEPT;  iptables -A OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
PreDown = HOMENET=192.168.0.1/24; ip route del $HOMENET via $DROUTE; iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT; iptables -D OUTPUT -d $HOMENET -j ACCEPT

where 192.168.0.1/24 is exchanged for your LAN adress, from your router. 
