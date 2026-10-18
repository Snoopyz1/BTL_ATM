FROM eclipse-temurin:11-jre

# Cài đặt curl, net-tools, procps, ping, iproute2
RUN apt-get update && apt-get install -y procps curl net-tools iputils-ping iproute2 && rm -rf /var/lib/apt/lists/*

WORKDIR /var/opt/CrushFTP10

# Copy mã nguồn CrushFTP vào container
COPY CrushFTP10 /var/opt/CrushFTP10

# Tạo sẵn file cờ test CVE-2024-4040 theo đúng báo cáo BTL Nhóm 5
RUN echo "NHOM05-CVE4040-LAB-ONLY" > /var/tmp/nhom05-cve4040.txt && \
    chmod 644 /var/tmp/nhom05-cve4040.txt

# Khởi tạo thư mục và tệp thử nghiệm theo báo cáo BTL
RUN mkdir -p /var/opt/CrushFTP10/ftp-lab && \
    echo "Noi dung tep mau - Nhom 5" > /var/opt/CrushFTP10/ftp-lab/mau.txt

# Tạo sẵn tài khoản quản trị crushadmin để test CVE-2025-54309
RUN java -jar CrushFTP.jar -a crushadmin admin123 || true

# Mở các cổng Web (8080) và FTP (21)
EXPOSE 8080 21

# Khởi chạy CrushFTP ở chế độ console/daemon
CMD ["java", "-Ddir=/var/opt/CrushFTP10", "-jar", "CrushFTP.jar", "-d"]
