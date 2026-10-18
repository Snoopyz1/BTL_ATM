Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  KÍCH HOẠT QUY TẮC PHÒNG THỦ TRÊN TƯỜNG LỬA PFSENSE    " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "[*] Đang thiết lập luật chặn xâm nhập trên pfSense..."
docker exec firewall_pfsense iptables -I FORWARD 1 -p tcp -d 10.10.20.20 --dport 8080 -j DROP
Write-Host "[+] ĐÃ BẬT PHÒNG THỦ THÀNH CÔNG!" -ForegroundColor Green
Write-Host "[+] Tường lửa pfSense hiện đang CHẶN (DROP) toàn bộ truy cập cổng 8080 từ WAN."
Write-Host "[+] Máy Kali sẽ bị chặn đứng hoàn toàn (Connection Timeout)!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
