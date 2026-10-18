# BỘ HỒ SƠ NỘP BÀI TẬP LỚN: AN TOÀN MẠNG (INT1482)
## ĐỀ TÀI: AN TOÀN DỊCH VỤ TRUYỀN NHẬN TỆP (FTP / FTPS / SFTP - CRUSHFTP 10.6.0)

**Học viện Công nghệ Bưu chính Viễn thông (PTIT)**  
**Khoa An toàn Thông tin**  
- **Nhóm thực hiện:** Nhóm 05  
- **Lớp:** INT1482-20261-02  
- **Giảng viên hướng dẫn:** TS. Nguyễn Ngọc Điệp  
- **Năm học:** 2025 - 2026  

---

## 1. CẤU TRÚC THƯ MỤC BẢN FINAL NỘP BÀI

Thư mục này được đóng gói độc lập, đầy đủ và chuẩn hóa toàn bộ tài nguyên báo cáo và thực nghiệm:

```
BTL_ATM_Final_Nhom05/
│
├── Bao cao ATM - INT1482-20261-02 - Nhom 05 - FINAL.docx  <-- BÁO CÁO WORD HOÀN CHỈNH
├── Hinh10_SoDoPhanVungMang_pfSense.png                    <-- SƠ ĐỒ PHÂN VÙNG PFSENSE
├── README.md                                              <-- TÀI LIỆU HƯỚNG DẪN TỔNG QUAN
│
├── kich_ban_lab_docker/                                   <-- KỊCH BẢN LAB DOCKER 3 NODE
│   ├── docker-compose.yml                                 <-- Cấu hình 3 node: WAN - pfSense - LAN
│   ├── README_DOCKER.md                                   <-- Hướng dẫn chạy và demo bằng 2 lệnh
│   ├── firewall/                                          <-- Router / Firewall mô phỏng pfSense
│   │   ├── Dockerfile
│   │   └── entrypoint.sh (Cấu hình iptables NAT & filter rules)
│   ├── attacker/                                          <-- Máy kiểm thử Kali Linux
│   │   ├── Dockerfile
│   │   └── exploits/ (scan_host.py, read_file.py, CVE-2025-54309)
│   └── victim/                                            <-- Máy chủ dịch vụ CrushFTP 10.6.0
│       └── Dockerfile
│
└── kich_ban_lab_vmware_pfsense/                           <-- KỊCH BẢN LAB VMWARE PFSENSE
    ├── pfSense_Config_Backup_Nhom05.xml                   <-- File cấu hình chuẩn XML của pfSense
    └── README_VMWARE_PFSENSE.md                           <-- Hướng dẫn chi tiết cài đặt trên VMware
```

---

## 2. LIÊN KẾT ĐÍNH KÈM TÀI NGUYÊN (ĐÁP ỨNG TIÊU CHÍ KHUYẾN KHÍCH)

Nhằm phục vụ đối chiếu, kiểm chứng tính xác thực và khả năng tái lập thực nghiệm theo yêu cầu của môn học:

| Thành phần tài nguyên | Loại hình lưu trữ | Đường dẫn truy cập | Ghi chú |
| :--- | :--- | :--- | :--- |
| **Mã nguồn Lab & Config** | GitHub Repository | [https://github.com/Snoopyz1/BTL_ATM](https://github.com/Snoopyz1/BTL_ATM) | Chứa Dockerfile, compose, script khai thác và cấu hình pfSense |
| **Docker Images & Video Demo** | Google Drive | `https://drive.google.com/drive/folders/nhom05-atm-demo` *(hoặc link Drive chia sẻ của nhóm)* | File ảnh `nhom05_atm_lab.tar` (448MB) và Video ghi hình quá trình demo thực nghiệm |

---

## 3. HƯỚNG DẪN KHỞI CHẠY NHANH CHO GIẢNG VIÊN / NGƯỜI CHẤM
Để chấm và đối chiếu kịch bản trong vòng 1 phút:
1. Mở PowerShell tại thư mục `kich_ban_lab_docker`:
   ```powershell
   docker compose up -d
   ```
2. Kiểm tra dịch vụ trên trình duyệt: Truy cập `http://localhost:8080`.
3. Vào máy kiểm thử để chạy tự động kịch bản khai thác:
   ```powershell
   docker exec -it attacker_kali python3 /root/exploits/read_file.py http://10.10.10.128:8080 /var/tmp/nhom05-cve4040.txt
   ```
   > Hệ thống sẽ lập tức in ra cờ bí mật: `NHOM05-CVE4040-LAB-ONLY`.
