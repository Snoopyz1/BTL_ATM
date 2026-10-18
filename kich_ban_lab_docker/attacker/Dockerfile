FROM kalilinux/kali-rolling

WORKDIR /root/exploits

# Cập nhật và cài đặt python3, pip, curl
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    iputils-ping \
    net-tools \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt thư viện requests
RUN pip3 install --no-cache-dir requests urllib3 --break-system-packages

# Copy các exploit script vào container
COPY exploits /root/exploits

# Giữ container chạy ngầm
CMD ["sleep", "infinity"]
