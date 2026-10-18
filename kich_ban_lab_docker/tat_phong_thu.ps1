Write-Host "[*] Đang gỡ bỏ luật chặn trên pfSense để kiểm thử tấn công..."
docker exec firewall_pfsense iptables -D FORWARD -p tcp -d 10.10.20.20 --dport 8080 -j DROP 2>$null
Write-Host "[+] Đã mở lại luồng kết nối kiểm thử." -ForegroundColor Green
