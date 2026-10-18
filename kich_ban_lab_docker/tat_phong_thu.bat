@echo off
chcp 65001 >nul
echo [*] Đang gỡ bỏ luật chặn để kiểm thử tấn công...
docker exec firewall_pfsense iptables -D FORWARD -p tcp -d 10.10.20.20 --dport 8080 -j DROP 2>nul
echo [+] Đã mở lại luồng kết nối kiểm thử.
