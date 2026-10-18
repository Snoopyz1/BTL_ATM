@echo off
chcp 65001 >nul
echo ========================================================
echo   KÍCH HOẠT QUY TẮC PHÒNG THỦ TRÊN TƯỜNG LỬA PFSENSE
echo ========================================================
echo [*] Đang thiết lập luật chặn xâm nhập trên pfSense...
docker exec firewall_pfsense iptables -I FORWARD 1 -p tcp -d 10.10.20.20 --dport 8080 -j DROP
echo [+] ĐÃ BẬT PHÒNG THỦ THÀNH CÔNG!
echo [+] Tường lửa pfSense hiện đang CHẶN (DROP) toàn bộ truy cập vào cổng 8080 từ WAN.
echo [+] Mọi nỗ lực khai thác lỗ hổng từ máy Kali sẽ bị chặn đứng (Connection Timeout)!
echo ========================================================
