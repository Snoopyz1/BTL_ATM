@echo off
echo [*] Dang go bo luat chan tren pfSense de test tan cong...
docker exec firewall_pfsense iptables -D FORWARD -p tcp -d 10.10.20.20 --dport 8080 -j DROP 2>nul
echo [+] Da mo lai luong ket noi kiem thu.
