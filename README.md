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
│
├── kich_ban_lab_docker/                      <-- Môi trường thực nghiệm Docker Compose
│   ├── docker-compose.yml                    <-- Cấu hình 3 node (WAN - pfSense - LAN)
│   ├── README_DOCKER.md                      <-- Hướng dẫn chi tiết chạy và test
│   ├── firewall/                             <-- Router Firewall mô phỏng pfSense (iptables)
│   ├── attacker/                             <-- Kali Linux và các script exploit
│   └── victim/                               <-- Ubuntu Server chạy CrushFTP 10.6.0
│
└── kich_ban_lab_vmware_pfsense/              <-- Cấu hình thực nghiệm VMware pfSense
    ├── pfSense_Config_Backup_Nhom05.xml      <-- File backup cấu hình XML pfSense 2.7.2
    └── README_VMWARE_PFSENSE.md              <-- Hướng dẫn cấu hình VMware VMnet2/VMnet3
```

---

## 2. Tải tệp ảnh Docker môi trường (.tar)

Tải các gói ảnh Docker đóng gói sẵn tại mục **[Releases](https://github.com/Snoopyz1/BTL_ATM/releases)**:
* **`nhom05_atm_lab_final.tar`** (~455 MB - *Khuyên dùng*): Gồm trọn vẹn cả 3 node (Firewall pfSense, Ubuntu CrushFTP, Kali Attacker). Chạy hoàn toàn Offline không cần kết nối Internet.
* **`nhom05_atm_lab.tar`** (~448 MB): Gồm 2 node cơ bản (Ubuntu CrushFTP và Kali Attacker).

---

## 3. Hướng dẫn khởi chạy nhanh (Docker Compose)

Mở PowerShell / Terminal tại thư mục `kich_ban_lab_docker`:

### Bước 1: Nạp ảnh Docker
```powershell
docker load -i nhom05_atm_lab_final.tar
```
*(Hoặc dùng `docker load -i nhom05_atm_lab.tar` nếu tải bản 2 máy)*.

### Bước 2: Khởi động hệ thống
```powershell
docker compose up -d
```

### Bước 3: Kiểm thử và demo đối chiếu
1. **Truy cập Web giao diện máy chủ:**  
   Mở trình duyệt truy cập: `http://localhost:8080` (Tài khoản: `crushadmin` / Mật khẩu: `admin123`).

2. **Khai thác lỗ hổng CVE-2024-4040 đọc file cờ bí mật:**
   ```powershell
   docker exec -it attacker_kali python3 /root/exploits/read_file_CVE_2024_4040.py http://10.10.10.128:8080 /var/tmp/nhom05-cve4040.txt
   ```
   > Kết quả trả về cờ bí mật: `NHOM05-CVE4040-LAB-ONLY`.

3. **Khai thác lỗ hổng CVE-2025-54309 (Bypass Authentication):**
   ```powershell
   docker exec -it attacker_kali python3 /root/exploits/attack_CVE_2025_54309.py http://10.10.10.128:8080
   ```
   > Kết quả: Vượt qua xác thực và trích xuất danh sách tài khoản quản trị.

---

## 4. Dọn dẹp tài nguyên
Sau khi hoàn tất thực nghiệm:
```powershell
docker compose down
```
