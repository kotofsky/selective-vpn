#!/bin/sh

cat > /etc/ppp/peers/VPN <<_EOF_
pty "pptp ${VPN_SERVER} --nolaunchpppd"
name "${VPN_USERNAME}"
password "${VPN_PSWD}"
remotename PPTP
persist
require-mppe-128
file /etc/ppp/options.pptp
_EOF_

cat > /etc/iproute2/rt_tables <<_EOF_
#
# reserved values
#
255     local
254     main
253     default
0       unspec
#
# local
#
#1      inr.ruhep
200 vpn.table
300 nonvpn.table
_EOF_


iname=$(ip route list ${CUSTOM_SUBNET} | awk '{print $3}')

maingateway_iface=$(ip -o -4 route show to default | awk '{print $5}')

cat > /etc/ppp/ip-up <<_EOF_
#!/bin/sh

#radarr rules
iptables -A PREROUTING -i "$iname" -t mangle -s "${RADARR_IP}" -j MARK --set-mark 2
iptables -A PREROUTING -i "$iname" -t mangle -p udp -s "${RADARR_IP}" --dport 53 -j MARK --set-mark 5
iptables -A PREROUTING -i "$iname" -t mangle -p tcp -s "${RADARR_IP}" --sport "${RADARR_PORT}" -j MARK --set-mark 5

#jackett rules
iptables -A PREROUTING -i "$iname" -t mangle -s "${JACKETT_IP}" -j MARK --set-mark 2
iptables -A PREROUTING -i "$iname" -t mangle -p udp -s "${JACKETT_IP}" --dport 53 -j MARK --set-mark 5
iptables -A PREROUTING -i "$iname" -t mangle -p tcp -s "${JACKETT_IP}" --sport "${JACKETT_PORT}" -j MARK --set-mark 5

ip rule add fwmark 5 table nonvpn.table 
ip rule add fwmark 2 table vpn.table

ip route add default scope global dev ppp0 table vpn.table
ip route add default scope global dev "$maingateway_iface" table nonvpn.table
_EOF_


#cleanup after terminating ppd
cat > /etc/ppp/ip-down <<_EOF_
#!/bin/sh

#radarr rules
iptables -D PREROUTING -i "$iname" -t mangle -s "${RADARR_IP}" -j MARK --set-mark 2
iptables -D PREROUTING -i "$iname" -t mangle -p udp -s "${RADARR_IP}" --dport 53 -j MARK --set-mark 5
iptables -D PREROUTING -i "$iname" -t mangle -p tcp -s "${RADARR_IP}" --sport "${RADARR_PORT}" -j MARK --set-mark 5

#jackett rules
iptables -D PREROUTING -i "$iname" -t mangle -s "${JACKETT_IP}" -j MARK --set-mark 2
iptables -D PREROUTING -i "$iname" -t mangle -p udp -s "${JACKETT_IP}" --dport 53 -j MARK --set-mark 5
iptables -D PREROUTING -i "$iname" -t mangle -p tcp -s "${JACKETT_IP}" --sport "${JACKETT_PORT}" -j MARK --set-mark 5

ip rule delete fwmark 5 table nonvpn.table 
ip rule delete fwmark 2 table vpn.table

ip route delete default scope global dev ppp0 table vpn.table
ip route delete default scope global dev "$maingateway_iface" table nonvpn.table
_EOF_

exec pon VPN nodetach "$@"