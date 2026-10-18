@echo off
echo ========================================================
echo   KICH HOAT QUY TAC PHONG THU TREN TUONG LUA PFSENSE
echo ========================================================
echo [*] Dang thiet lap luat chan tren pfSense...
docker exec firewall_pfsense iptables -I FORWARD 1 -p tcp -d 10.10.20.20 --dport 8080 -j DROP
echo [+] DA BAT PHONG THU THANH CONG!
echo [+] pfSense da chan (DROP) toan bo truy cap cong 8080 tu WAN.
echo [+] May Kali se bi chan dung hoan toan (Connection Timeout)!
echo ========================================================
