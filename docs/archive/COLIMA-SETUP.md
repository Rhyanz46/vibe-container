# Colima Setup Guide for Docker CLI Access

Guide lengkap untuk setup Colima dengan Docker daemon exposure via TCP, agar Docker CLI di dalam container bisa connect ke host Docker engine **tanpa socket mount**.

## Kenapa Ini Pendekatan Lebih Baik?

✅ **Keuntungan:**
- Tidak perlu mount `/var/run/docker.sock` → lebih secure
- Gunakan `DOCKER_HOST` environment variable → cleaner configuration
- Follow Docker best practices → proper context management
- Lebih mudah debug dan troubleshoot
- Bisa switch antar Docker contexts dengan mudah

⚠️ **Perlu Diperhatikan:**
- Docker daemon exposed via TCP (hanya untuk localhost, aman untuk development)
- Pastikan firewall mengizinkan koneksi localhost:2375
- JANGAN expose Docker daemon ke public network!

---

## Langkah 1: Install Colima

```bash
# Install via Homebrew
brew install colima docker docker-compose

# Verify installation
colima version
docker --version
```

---

## Langkah 2: Start Colima dengan Docker Daemon Exposed

**Opsi A: Untuk Development (Recommended)**

```bash
# Start Colima dengan Docker daemon exposed via TCP
colima start \
  --vm-type=vz \
  --vz-rosetta \
  --network host \
  --cpu 4 \
  --memory 8 \
  --engine-flags="--host=tcp://0.0.0.0:2375"
```

**Penjelasan flags:**
- `--vm-type=vz` - Gunakan Virtualization framework Apple (lebih cepat)
- `--vz-rosetta` - Enable Rosetta untuk ARM apps di Apple Silicon
- `--network host` - Host networking (container bisa akses localhost Docker daemon)
- `--cpu 4 --memory 8` - Resources allocation
- `--engine-flags="--host=tcp://0.0.0.0:2375"` - **Expose Docker daemon via TCP**

**Opsi B: Untuk Performance (Lebih Banyak Resources)**

```bash
colima start \
  --vm-type=vz \
  --vz-rosetta \
  --network host \
  --cpu 6 \
  --memory 12 \
  --disk 100 \
  --engine-flags="--host=tcp://0.0.0.0:2375"
```

---

## Langkah 3: Verify Docker Daemon Exposed

```bash
# Cek apakah Docker daemon listening di port 2375
lsof -i :2375

# Atau dengan netstat
netstat -an | grep 2375

# Test koneksi via TCP
docker -H tcp://localhost:2375 ps
```

Expected output:
```
COMMAND   PID USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
docker-a 12345 user   12u  IPv4 0x1234      0t0  TCP *:2375 (LISTEN)
```

---

## Langkah 4: Start Container

```bash
# Clone dan masuk ke directory project
git clone git@github.com:Rhyanz46/vibe-container.git
cd vibe-container

# Build dan start container
docker-compose up -d --build

# Masuk ke container
docker exec -it claude-code-container bash
```

---

## Langkah 5: Verify Docker CLI di Container

```bash
# Di dalam container, test Docker CLI
docker ps
docker info
docker images

# Harusnya bisa list containers/images di host!
```

Expected output:
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    NAMES
claude-code-container   claude-code:2026.1   "/home/claude/entry..."   5 min ago   Up 5 min   claude-code-container
```

---

## Troubleshooting

### Docker CLI tidak bisa connect

**Error:**
```
Cannot connect to the Docker daemon at tcp://localhost:2375
```

**Solusi:**
```bash
# 1. Cek Colima status
colima status

# 2. Cek apakah Docker daemon exposed
colima ssh
# Di dalam Colima VM:
ps aux | grep dockerd
# Harusnya ada: dockerd --host=tcp://0.0.0.0:2375 ...

# 3. Restart Colima dengan proper flags
colima stop
colima start --engine-flags="--host=tcp://0.0.0.0:2375" --network host
```

### Port 2375 tidak listening

**Cek:**
```bash
# Di host macOS
lsof -i :2375

# Jika kosong, berarti Docker daemon belum exposed
```

**Solusi:**
```bash
# Stop Colima
colima stop

# Start ulang dengan engine flags
colima start --engine-flags="--host=tcp://0.0.0.0:2375" --network host

# Verify
lsof -i :2375
```

### Docker daemon only exposed to Colima internal network

**Problem:** Docker daemon listening di `172.18.0.1:2375` (Colima internal), bukan `localhost:2375`

**Solusi:**
```bash
# Pastikan gunakan --network host
colima stop
colima start --network host --engine-flags="--host=tcp://0.0.0.0:2375"
```

### Container tidak bisa resolve tcp://localhost:2375

**Solusi:**
```bash
# Gunakan IP address Colima
colima ip  # Misal: 192.168.5.2

# Update docker-compose.yml
DOCKER_HOST=tcp://192.168.5.2:2375

# Atau gunakan host.docker.internal (Colima specific)
DOCKER_HOST=tcp://host.docker.internal:2375
```

---

## Advanced Configuration

### Set Default Colima Configuration

```bash
# Edit Colima config
colima default edit

# Tambahkan:
engine:
  flags:
    - "--host=tcp://0.0.0.0:2375"

# Save dan restart
colima restart
```

### Create Docker Context untuk Colima

```bash
# Create Docker context
docker context create colima-tcp --docker "host=tcp://localhost:2375"

# Gunakan context
docker context use colima-tcp

# Verify
docker context ls
docker ps
```

### Expose Docker dengan TLS (Secure untuk Production)

⚠️ **Hanya untuk production/trusted networks!**

```bash
# Generate TLS certificates
openssl genrsa -aes256 -out ca-key.pem 4096
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
# ... (lanjutkan generate server dan client certs)

# Start Colima dengan TLS
colima start \
  --engine-flags="--host=tcp://0.0.0.0:2376 --tlsverify --tlscacert=ca.pem --tlscert=server-cert.pem --tlskey=server-key.pem"

# Update docker-compose.yml
DOCKER_HOST=tcp://localhost:2376
DOCKER_TLS_VERIFY=1
DOCKER_CERT_PATH=/path/to/certs
```

---

## Security Best Practices

✅ **AMAN untuk Development (Current Setup):**
- Docker daemon exposed ke `0.0.0.0:2375` tapi hanya accessible via `localhost` karena Colima network isolation
- Container menggunakan `network_mode: host` jadi bisa akses `localhost:2375`
- Tidak ada akses dari luar Colima VM

❌ **JANGAN untuk Production:**
- JANGAN expose Docker daemon ke public network (0.0.0.0) tanpa firewall
- JANGAN gunakan di shared environment
- Gunakan TLS kalau perlu remote access

---

## Quick Start Script

Buat file `start.sh`:

```bash
#!/bin/bash

# Start Colima dengan proper configuration
echo "🚀 Starting Colima with Docker daemon exposed..."

colima start \
  --vm-type=vz \
  --vz-rosetta \
  --network host \
  --cpu 4 \
  --memory 8 \
  --engine-flags="--host=tcp://0.0.0.0:2375" || \
  colima start \
  --vm-type=vz \
  --vz-rosetta \
  --network host \
  --cpu 4 \
  --memory 8 \
  --engine-flags="--host=tcp://0.0.0.0:2375"

# Wait for Docker daemon to be ready
echo "⏳ Waiting for Docker daemon..."
sleep 5

# Verify
echo "✅ Checking Docker daemon..."
docker -H tcp://localhost:2375 ps > /dev/null 2>&1 && \
  echo "✅ Docker daemon exposed successfully!" || \
  echo "❌ Docker daemon not accessible. Check Colima status."

# Start container
echo "🐳 Starting Claude Code container..."
cd "$(dirname "$0")"
docker-compose up -d --build

echo ""
echo "✅ Setup complete!"
echo "📝 Next steps:"
echo "   1. docker exec -it claude-code-container bash"
echo "   2. docker ps  # Should work from inside container!"
```

Jadikan executable:
```bash
chmod +x start.sh
./start.sh
```

---

## Summary

**Setup Command:**
```bash
colima start --vm-type=vz --vz-rosetta --network host --cpu 4 --memory 8 --engine-flags="--host=tcp://0.0.0.0:2375"
```

**Verify:**
```bash
lsof -i :2375  # Should show docker-a listening
docker -H tcp://localhost:2375 ps  # Should list containers
```

**Use:**
```bash
docker-compose up -d
docker exec -it claude-code-container bash
docker ps  # Works from inside container!
```

**Keuntungan:**
- ✅ Tidak perlu socket mount
- ✅ Lebih clean dan secure
- ✅ Docker best practices
- ✅ Automatic di container startup

---

**Last Updated:** January 2026
**For:** Claude Code Development Container on macOS with Colima
