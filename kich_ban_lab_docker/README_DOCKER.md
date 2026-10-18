# HƯỚNG DẪN TRIỂN KHAI VÀ THỰC NGHIỆM LAB DOCKER (MÔ HÌNH 3 NODE PFSENSE)
## BÀI TẬP LỚN: AN TOÀN MẠNG (INT1482) - HỌC VIỆN CÔNG NGHỆ BƯU CHÍNH VIỄN THÔNG (PTIT)
**Đề tài:** An toàn dịch vụ truyền nhận tệp (CrushFTP 10.6.0)  
**Nhóm thực hiện:** Nhóm 05 - Lớp: INT1482-20261-02  

---

## 1. MÔ HÌNH KIẾN TRÚC MẠNG LAB
Lab mô phỏng chính xác mô hình phân vùng mạng an ninh đa tầng với tường lửa pfSense trung tâm (Hình 10 trong báo cáo):

```
+------------------------------------+
|  VÙNG MẠNG NGOÀI (WAN): 10.10.10.0/24
|  Máy kiểm thử: attacker_kali (10.10.10.50)
+------------------------------------+
                  |
                  | [Cổng WAN: 10.10.10.128]
+------------------------------------------------------+
|  TƯỜNG LỬA TRUNG TÂM: firewall_pfsense               |
|  - Chức năng: NAT Port Forwarding (8080, 21, 22)     |
|  - Firewall Filter Rules: Chỉ cho phép cổng quy định |
|  - Cô lập Broadcast Domain & Chống nghe lén LAN      |
+------------------------------------------------------+
                  | [Cổng LAN: 10.10.20.1]
                  |
+------------------------------------+
|  VÙNG MẠNG NỘI BỘ (LAN): 10.10.20.0/24
|  Máy chủ dịch vụ: victim_server (10.10.20.20)
|  Dịch vụ: CrushFTP 10.6.0 (Web, FTPS, SFTP)
+------------------------------------+
```

---

## 2. YÊU CẦU TIÊN QUYẾT
- Máy tính đã cài đặt **Docker Desktop** (trên Windows / macOS) hoặc **Docker Engine** (trên Linux).
- Docker Desktop đang ở trạng thái **Running**.

---

## 3. CÁCH KHỞI CHẠY LAB TỨC THÌ (CHỈ VỚI 2 LỆNH)

Mở PowerShell / Terminal tại thư mục `kich_ban_lab_docker`:

### Bước 1: Nạp ảnh Docker vào hệ thống (nếu dùng file image nén)
```powershell
docker load -i nhom05_atm_lab.tar
```
*(Nếu chưa có file .tar, tải tại link Google Drive đính kèm trong phụ lục báo cáo)*.

### Bước 2: Khởi động toàn bộ hệ sinh thái (Firewall + Attacker + Victim)
```powershell
docker compose up -d
```
Docker Compose sẽ tự động khởi tạo:
1. Hai phân đoạn mạng độc lập: `wan_net` (`10.10.10.0/24`) và `lan_net` (`10.10.20.0/24`).
2. Tường lửa `firewall_pfsense` làm router trung tâm thiết lập iptables NAT/Filter.
3. Máy chủ dịch vụ `victim_server` nằm cô lập trong mạng `lan_net`.
4. Máy kiểm thử `attacker_kali` nằm ngoài mạng `wan_net`.

---

## 4. HƯỚNG DẪN KIỂM THỬ VÀ DEMO ĐỐI CHIẾU

### A. Truy cập dịch vụ từ máy thật qua cổng chuyển tiếp
- Mở trình duyệt Web trên máy thật, truy cập: `http://localhost:8080`
- Tài khoản quản trị khởi tạo sẵn:
  - **Tài khoản:** `crushadmin`
  - **Mật khẩu:** `admin123`

---

### B. Kiểm thử tấn công từ máy ngoài WAN (attacker_kali)
1. Truy cập vào terminal máy kiểm thử Kali Linux:
```powershell
docker exec -it attacker_kali bash
```

2. Kiểm tra kết nối tới IP cổng WAN của tường lửa (`10.10.10.128`):
```bash
ping 10.10.10.128 -c 2
```

3. **Demo lỗ hổng CVE-2024-4040 (SSTI / Đọc file tùy ý qua tường lửa):**
   - Quét kiểm tra trạng thái lỗ hổng:
     ```bash
     python3 /root/exploits/scan_host.py http://10.10.10.128:8080
     ```
     > **Kết quả:** In ra `Vulnerable`.
   - Khai thác đọc file cờ bí mật `/var/tmp/nhom05-cve4040.txt` trên máy chủ nội bộ:
     ```bash
     python3 /root/exploits/read_file.py http://10.10.10.128:8080 /var/tmp/nhom05-cve4040.txt
     ```
     > **Kết quả:** Đọc thành công nội dung cờ bí mật: `NHOM05-CVE4040-LAB-ONLY`.

4. **Demo lỗ hổng CVE-2025-54309 (Race Condition Authentication Bypass):**
   ```bash
   python3 /root/exploits/watchTowr-vs-CrushFTP-CVE-2025-54309.py http://10.10.10.128:8080
   ```
   > **Kết quả:** Vượt qua xác thực và trích xuất thành công danh sách người dùng quản trị (`crushadmin`, `default`, `TempAccount`).

5. Thoát khỏi container Kali:
   ```bash
   exit
   ```

---

### C. Kiểm chứng hiệu quả phân vùng của pfSense (Chống nghe lén / Sniffing)
1. Mở terminal chui vào `attacker_kali` để theo dõi lưu lượng mạng:
```powershell
docker exec -it attacker_kali tcpdump -i eth0 -n
```
2. Thực hiện truyền file hoặc trao đổi giữa máy chủ nội bộ trong mạng LAN.
3. **Kết quả:** Trên card mạng `eth0` của máy Kali ở vùng WAN hoàn toàn không bắt được bất kỳ gói tin nội bộ nào của mạng LAN `10.10.20.0/24`. Tường lửa đã cách ly hoàn toàn miền quảng bá (broadcast domain).

---

## 5. DỪNG VÀ GIẢI PHÓNG LAB
Khi kết thúc buổi demo hoặc chấm bài:
```powershell
docker compose down
```
