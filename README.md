# BÀI TẬP LỚN: AN TOÀN MẠNG (INT1482)
## Đề tài: An toàn dịch vụ truyền nhận tệp (CrushFTP 10.6.0)

**Học viện Công nghệ Bưu chính Viễn thông (PTIT)**  
**Khoa An toàn Thông tin**  
* **Nhóm thực hiện:** Nhóm 05  
* **Lớp:** INT1482-20261-02  
* **Giảng viên hướng dẫn:** TS. Nguyễn Ngọc Điệp  

---

## 1. Cấu trúc kho lưu trữ

```
BTL_ATM/
│
├── README.md                                 <-- Hướng dẫn tổng quan
├── Demo_lab.mp4                              <-- Video ghi hình quá trình demo thực nghiệm
│
├── kich_ban_lab_docker/                      <-- Môi trường thực nghiệm Docker Compose
│   ├── docker-compose.yml                    <-- Cấu hình 3 node (WAN - pfSense - LAN)
│   ├── bat_phong_thu.bat / .ps1              <-- Kích hoạt luật chặn trên tường lửa pfSense
│   ├── tat_phong_thu.bat / .ps1              <-- Mở lại luồng kết nối để kiểm thử tấn công
│   ├── README_DOCKER.md                      <-- Hướng dẫn chi tiết chạy và demo lab
│   ├── firewall/                             <-- Router Firewall mô phỏng pfSense (iptables)
│   │   ├── Dockerfile
│   │   └── entrypoint.sh                     <-- Cấu hình NAT Port Forward & Filter Rules
│   ├── attacker/                             <-- Máy kiểm thử Kali Linux
│   │   ├── Dockerfile
│   │   └── exploits/
│   │       ├── read_file_CVE_2024_4040.py    <-- Script khai thác SSTI đọc file cờ bí mật
│   │       ├── attack_CVE_2025_54309.py      <-- Script khai thác Race Condition chiếm user
│   │       ├── scan_host.py                  <-- Script dò quét trạng thái lỗ hổng
│   │       └── scan_logs.py                  <-- Script rà soát log máy chủ
│   └── victim/                               <-- Máy chủ dịch vụ CrushFTP 10.6.0
│       └── Dockerfile
│
└── kich_ban_lab_vmware_pfsense/              <-- Cấu hình thực nghiệm VMware pfSense
    ├── pfSense_Config_Backup_Nhom05.xml      <-- File backup cấu hình XML pfSense 2.7.2
    └── README_VMWARE_PFSENSE.md              <-- Hướng dẫn cấu hình VMware VMnet2/VMnet3
```

---

## 2. Tải tệp ảnh Docker môi trường (.tar)

Tải các gói ảnh Docker đóng gói sẵn tại mục **[Releases](https://github.com/Snoopyz1/BTL_ATM/releases)**:
* **`nhom05_atm_lab_final.tar`** (~434 MB - *Khuyên dùng*): Gồm trọn vẹn cả 3 node (Firewall pfSense, Ubuntu CrushFTP, Kali Attacker có sẵn các script exploit). Chạy hoàn toàn Offline không cần kết nối Internet.
* **`nhom05_atm_lab.tar`** (~448 MB): Gồm 2 node cơ bản (Ubuntu CrushFTP và Kali Attacker).

---

## 3. Hướng dẫn khởi chạy và kịch bản demo đối chiếu

Mở PowerShell / Terminal tại thư mục `kich_ban_lab_docker`:

### Bước 1: Nạp ảnh Docker (chỉ cần làm 1 lần)
```powershell
docker load -i nhom05_atm_lab_final.tar
```
*(Hoặc dùng `docker load -i nhom05_atm_lab.tar` nếu tải bản 2 máy)*.

### Bước 2: Khởi động hệ thống
```powershell
docker compose up -d
```
* Mở trình duyệt kiểm tra máy chủ: `http://localhost:8080` (Tài khoản: `crushadmin` / Mật khẩu: `admin123`).

---

### Bước 3: Giai đoạn 1 — Khi chưa bật phòng thủ (Tấn công thành công)

1. **Khai thác CVE-2024-4040 đọc file cờ bí mật:**
   ```powershell
   docker exec -it attacker_kali python3 /root/exploits/read_file_CVE_2024_4040.py http://10.10.10.128:8080 /var/tmp/nhom05-cve4040.txt
   ```
   > **Kết quả:** Đọc thành công cờ bí mật: `NHOM05-CVE4040-LAB-ONLY`.

2. **Khai thác CVE-2025-54309 chiếm danh sách tài khoản:**
   ```powershell
   docker exec -it attacker_kali python3 /root/exploits/attack_CVE_2025_54309.py http://10.10.10.128:8080
   ```
   > **Kết quả:** Trích xuất thành công 3 người dùng: `crushadmin, default, TempAccount`.

---

### Bước 4: Giai đoạn 2 — Kích hoạt phòng thủ pfSense (Tấn công bị chặn hoàn toàn)

1. **Bật quy tắc tường lửa pfSense chặn truy cập cổng 8080 từ WAN:**
   ```powershell
   .\bat_phong_thu.bat
   ```
   *(Hoặc chạy `.\bat_phong_thu.ps1` nếu dùng PowerShell)*.

2. **Kẻ tấn công thực thi lại CVE-2024-4040:**
   ```powershell
   docker exec -it attacker_kali python3 /root/exploits/read_file_CVE_2024_4040.py http://10.10.10.128:8080 /var/tmp/nhom05-cve4040.txt
   ```
   > **Kết quả:** Quá thời gian chờ (10 giây) $\rightarrow$ Báo lỗi `ConnectTimeout`. pfSense đã DROP toàn bộ gói tin, kẻ tấn công **hoàn toàn KHÔNG THỂ lấy cờ bí mật**.

3. **Kẻ tấn công thực thi lại CVE-2025-54309:**
   ```powershell
   docker exec -it attacker_kali python3 /root/exploits/attack_CVE_2025_54309.py http://10.10.10.128:8080
   ```
   > **Kết quả:** Quá thời gian chờ (10 giây) $\rightarrow$ Báo lỗi `ConnectTimeout`. Cuộc tấn công bị chặn đứng hoàn toàn.

4. **Kiểm chứng chống nghe lén (Sniffing) qua phân vùng:**
   ```powershell
   docker exec -it attacker_kali tcpdump -i eth0 -n -c 5
   ```
   > **Kết quả:** Trên card mạng ngoài WAN hoàn toàn không bắt được bất kỳ gói tin trao đổi nội bộ nào của mạng LAN.

---

## 4. Dọn dẹp tài nguyên
* Muốn mở lại để thử nghiệm tấn công: Chạy `.\tat_phong_thu.bat`.
* Khi kết thúc buổi thực nghiệm:
  ```powershell
  docker compose down
  ```
