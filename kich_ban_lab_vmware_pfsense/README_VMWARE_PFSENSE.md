# HƯỚNG DẪN THIẾT LẬP MÔ HÌNH LAB PFSENSE TRÊN VMWARE WORKSTATION
## BÀI TẬP LỚN: AN TOÀN MẠNG (INT1482) - NHÓM 05

Tài liệu này hướng dẫn chi tiết cách dựng môi trường thực nghiệm hoàn chỉnh trên **VMware Workstation** đúng chuẩn kiến trúc phân vùng an ninh 3 vùng mạng theo Báo cáo BTL.

---

## 1. THIẾT LẬP MẠNG ẢO TRÊN VMWARE (VIRTUAL NETWORK EDITOR)
Mở VMware Workstation -> Chọn `Edit` -> `Virtual Network Editor`:
1. **VMnet2 (Vùng mạng ngoài WAN):**
   - Loại mạng: `Host-only` (hoặc Custom).
   - Subnet IP: `10.10.10.0`
   - Subnet Mask: `255.255.255.0`
   - Bỏ tích "Use local DHCP service" (sử dụng IP tĩnh).
2. **VMnet3 (Vùng mạng nội bộ LAN):**
   - Loại mạng: `Host-only` (Custom).
   - Subnet IP: `10.10.20.0`
   - Subnet Mask: `255.255.255.0`
   - Bỏ tích DHCP.

---

## 2. GÁN CARD MẠNG CHO 3 MÁY ẢO

### A. Máy ảo pfSense (FreeBSD 64-bit / pfSense 2.7.2):
Cấu hình **2 Card mạng (Network Adapters)**:
- **Network Adapter 1 (em0 - WAN):** Chọn `Custom: Specific virtual network` -> Chọn `VMnet2`.
- **Network Adapter 2 (em1 - LAN):** Chọn `Custom: Specific virtual network` -> Chọn `VMnet3`.

### B. Máy kiểm thử (Kali Linux 2026.2):
- **Network Adapter 1:** Chọn `Custom` -> `VMnet2`.
- Thiết lập IP tĩnh trên Kali:
  - IP Address: `10.10.10.50/24`
  - Default Gateway: `10.10.10.128` (IP cổng WAN của pfSense).

### C. Máy chủ nạn nhân (Ubuntu Server 24.04 - CrushFTP):
- **Network Adapter 1:** Chọn `Custom` -> `VMnet3`.
- Thiết lập IP tĩnh trên Ubuntu Server:
  - IP Address: `10.10.20.20/24`
  - Default Gateway: `10.10.20.1` (IP cổng LAN của pfSense).

---

## 3. CẤU HÌNH PFSENSE BẰNG FILE XML IMPORT (NHANH NHẤT)
1. Sau khi cài đặt pfSense, truy cập giao diện quản trị WebGUI của pfSense từ trình duyệt:  
   `https://10.10.20.1` (hoặc qua máy chủ LAN).
2. Đăng nhập bằng tài khoản: `admin` / mật khẩu mặc định: `pfsense`.
3. Vào menu: **Diagnostics** -> **Backup & Restore**.
4. Tại mục **Restore Configuration**:
   - Chọn **Choose File** và tải lên file `pfSense_Config_Backup_Nhom05.xml` (có sẵn trong thư mục này).
   - Nhấn **Restore Configuration**.
5. pfSense sẽ tự động khởi động lại và áp dụng toàn bộ:
   - IP WAN: `10.10.10.128/24`, IP LAN: `10.10.20.1/24`.
   - Các luật NAT Port Forwarding: `WAN:8080 -> 10.10.20.20:8080`, `WAN:21 -> 10.10.20.20:21`, `WAN:22 -> 10.10.20.20:22`.
   - Các luật Firewall Rules chặn toàn bộ xâm nhập trái phép vào vùng LAN.

---

## 4. KIỂM THỬ ĐỐI CHIẾU
1. **Kiểm tra thông tuyến:** Từ Kali Linux (`10.10.10.50`), gõ lệnh:
   ```bash
   ping 10.10.10.128 -c 2
   curl -I http://10.10.10.128:8080/WebInterface/
   ```
2. **Khai thác lỗ hổng qua tường lửa:**
   ```bash
   python3 scan_host.py http://10.10.10.128:8080
   python3 read_file.py http://10.10.10.128:8080 /var/tmp/nhom05-cve4040.txt
   ```
3. **Bắt gói tin kiểm chứng hiệu quả phân vùng:**
   - Mở Wireshark trên Kali Linux (`10.10.10.50`), lắng nghe trên interface `eth0`.
   - Thực hiện truyền nhận tệp giữa các máy trong mạng LAN `10.10.20.0/24`.
   - Quan sát kết quả: Wireshark trên Kali **hoàn toàn không ghi nhận được bất kỳ luồng gói tin FTP nội bộ nào** của mạng LAN, chứng minh khả năng cách ly miền quảng bá của pfSense.
