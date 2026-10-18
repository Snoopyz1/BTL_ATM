#!/bin/bash
set -e

echo "=========================================================="
echo "    KHOI DONG TUONG LUA PFSENSE ROUTER (NHOM 05)         "
echo "=========================================================="

# 1. Kich hoat tinh nang chuyen tiep goi tin IPv4
sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1 || true

# 2. Xoa sach cac quy tac cu
iptables -F
iptables -t nat -F
iptables -X

# 3. Thiet lap chinh sach mac dinh (Default Policy)
iptables -P INPUT ACCEPT
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# 4. NAT / Port Forwarding tu WAN (10.10.10.128) vao May chu LAN (10.10.20.20)
# Port 8080: CrushFTP Web Interface
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 10.10.20.20:8080
# Port 21: FTPS / FTP Command Port
iptables -t nat -A PREROUTING -p tcp --dport 21 -j DNAT --to-destination 10.10.20.20:21
# Port 22: SFTP / SSH Port
iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to-destination 10.10.20.20:22

# 5. IP Masquerade cho chieu phan hoi tu LAN ve WAN
iptables -t nat -A POSTROUTING -j MASQUERADE

# 6. Bo quy tac loc goi (Firewall Filter Rules)
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p icmp -j ACCEPT
iptables -A FORWARD -p tcp -d 10.10.20.20 --dport 8080 -j ACCEPT
iptables -A FORWARD -p tcp -d 10.10.20.20 --dport 21 -j ACCEPT
iptables -A FORWARD -p tcp -d 10.10.20.20 --dport 22 -j ACCEPT

# Ngan chan tuyet doi moi traffic con lai de co lap mang LAN
iptables -A FORWARD -j DROP

echo "[+] pfSense Firewall rules da duoc thiet lap hoan tat!"
echo "[+] Cong WAN: 10.10.10.128 (Mapping 8080, 21, 22 -> 10.10.20.20)"
echo "[+] Cong LAN: 10.10.20.1 (Gateway cho Server noi bo)"
echo "[+] Luong goi tin ngoai le bi DROP hoan toan boi Firewall."
echo "=========================================================="

exec sleep infinity
