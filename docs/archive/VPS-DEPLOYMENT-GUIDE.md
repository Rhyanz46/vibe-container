# 🚀 Complete VPS Deployment Guide

## 📋 Prerequisites: Apa yang Perlu Disiapkan di VPS

### 1. **System Requirements**
- ✅ **OS**: Ubuntu 20.04+, Debian 11+, atau distro Linux lainnya
- ✅ **RAM**: Minimum 2GB (recommended 4GB+)
- ✅ **Storage**: Minimum 20GB free space
- ✅ **CPU**: 2+ cores recommended

### 2. **Software yang Harus Install di VPS**

#### A. Docker & Docker Compose
```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group (opsional, agar tidak perlu sudo)
sudo usermod -aG docker $USER

# Verifikasi
docker --version
docker-compose --version
```

#### B. Git (untuk clone project)
```bash
sudo apt-get install -y git
```

### 3. **Docker Daemon Setup (PENTING untuk Docker CLI dalam container)**

**Kenapa penting?** Agar container bisa menjalankan `docker` command untuk manage host containers.

```bash
# 1. Buat konfigurasi Docker daemon
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://127.0.0.1:2375"]
}
EOF

# 2. Buat systemd override
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/override.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
EOF

# 3. Reload dan restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# 4. Verifikasi Docker daemon listening di port 2375
sudo ss -tlnp | grep 2375
# Output: LISTEN 0 4096 127.0.0.1:2375 ...

# 5. Test dari dalam container (nanti setelah container jalan)
docker exec claude-code-container docker ps
```

**⚠️ SECURITY**: Docker daemon hanya listening di `127.0.0.1:2375` (localhost only), TIDAK terbuka ke internet. Aman!

---

## 🚀 Step-by-Step Deployment di VPS

### Step 1: Upload Project ke VPS

#### Opsi A: Menggunakan Git (Recommended)
```bash
# Di VPS
cd ~
git clone https://github.com/YOUR_USERNAME/cloud-project.git
cd cloud-project
```

#### Opsi B: Menggunakan SCP
```bash
# Di local machine
scp -r ~/cloud-project user@your-vps-ip:/home/user/
```

#### Opsi C: Menggunakan rsync
```bash
# Di local machine
rsync -av --progress ~/cloud-project/ user@your-vps-ip:/home/user/cloud-project/
```

### Step 2: Setup File Permissions

```bash
# Pastikan user punya akses ke project
cd ~/cloud-project

# Fix permissions jika perlu
sudo chown -R $USER:$USER .
chmod +x shell.sh exec.sh
```

### Step 3: Build dan Start Container

```bash
# Build container (first time akan lama, ±15-20 menit)
docker-compose build --no-cache

# Start container
docker-compose up -d

# Cek status
docker-compose ps
```

### Step 4: Verifikasi Deployment

```bash
# Cek container running
docker ps | grep claude-code-container

# Test basic tools
docker exec claude-code-container bash -c "
  echo '=== Environment Check ==='
  go version
  node --version
  npm --version
  python3 --version
  echo '=== All Tools Ready ==='
"

# Test Docker CLI dalam container
docker exec claude-code-container docker ps
# Harus show list containers di host
```

---

## 🎯 Penggunaan Setelah Deploy

### A. Masuk ke Container

```bash
# Method 1: Direct docker exec
docker exec -it claude-code-container bash

# Method 2: Menggunakan shell script (lebih mudah)
./shell.sh
```

### B. Tools yang Langsung Available

Tanpa perlu install apa-apa, semua tools ini siap pakai:

#### ✅ Programming Languages
- **Go 1.23.5**: `go version`, `go build`, `go test`
- **Node.js v20/v22/v25**: Pre-installed via NVM
- **Python 3.12**: `python3`, `pip`
- **Rust, Flutter, Java**: Available untuk install via prompts

#### ✅ Development Tools
- **Git**: `git clone`, `git commit`, dll
- **Claude Code 2.1.x**: Siap pakai (tinggal login)
- **Docker CLI**: Untuk manage host containers
- **ripgrep (rg)**: Fast grep alternative
- **jq**: JSON processor

#### ✅ Bash Features
- **Autocomplete**: TAB untuk git, go, npm commands
- **Aliases**: `ll`, `la`, `cls`, `..`, `...`
- **History**: 10,000 lines history
- **Colors**: ls, grep output berwarna

### C. Install Optional Tools (Interactive Prompts)

Saat pertama kali masuk container, Anda akan diminta untuk install:

```bash
./shell.sh
```

Prompts yang akan muncul:
1. **Playwright MCP**: `y` untuk install (browser automation)
2. **Flutter SDK**: `y` untuk install (mobile/web development)
3. **Rust**: `y` untuk install (systems programming)
4. **Java JDK 21**: `y` untuk install (Android/enterprise dev)
5. **Docker CLI**: `y` untuk install (manage host containers)

**⚠️ FIX VERIFIED**: Semua install ini aman dan TIDAK akan corrupt PATH lagi!

### D. Login ke Claude Code (First Time Only)

```bash
# Masuk ke container
./shell.sh

# Login
claude /login

# Follow instruksi:
# 1. Browser akan terbuka
# 2. Login ke Anthropic
# 3. Authorize device
# 4. Done!

# Verifikasi
claude /status
```

---

## 📂 Struktur Data & Persistent Storage

### Data yang Disimpan di VPS

Semua data disimpan di direktori project (`~/cloud-project/`):

```
cloud-project/
├── docker-compose.yml          # Container configuration
├── Dockerfile                   # Build instructions
├── shell.sh                     # Quick access script
├── exec.sh                      # Exec script
├── data/                        # PERSISTENT DATA
│   ├── .claude/                # Claude Code config (API keys)
│   ├── .local/                 # Claude Code local files
│   ├── .npm/                   # npm cache
│   ├── .ssh/                   # SSH keys
│   ├── go/                     # Go workspace
│   └── .cache/go-build/        # Go build cache
└── README.md                    # Documentation
```

### Volume Mounts

Lihat `docker-compose.yml` untuk complete list:

```yaml
volumes:
  # Project directory
  - .:/workspace

  # Claude Code data
  - ./data/.claude:/home/claude/.claude
  - ./data/.local:/home/claude/.local
  - ./data/.npm:/home/claude/.npm

  # SSH & Git
  - ./data/.ssh:/home/claude/.ssh

  # Go development
  - ./data/go:/home/claude/go
  - ./data/.cache/go-build:/home/claude/.cache/go-build

  # MCP servers
  - ./data/.mcp:/home/claude/.mcp
```

---

## 🔧 Troubleshooting di VPS

### Problem 1: Container tidak start

```bash
# Cek logs
docker-compose logs claude-code

# Cek status
docker-compose ps

# Restart
docker-compose restart
```

### Problem 2: Docker CLI tidak connect ke daemon

```bash
# Verifikasi Docker daemon listening di host
sudo ss -tlnp | grep 2375

# Jika tidak listening:
sudo systemctl restart docker

# Test dari dalam container
docker exec claude-code-container docker ps
```

### Problem 3: Permission denied

```bash
# Fix ownership
sudo chown -R $USER:$USER ~/cloud-project/data

# Fix SSH key permissions
chmod 600 ~/cloud-project/data/.ssh/id_ed25519
chmod 644 ~/cloud-project/data/.ssh/id_ed25519.pub
```

### Problem 4: Out of memory

```bash
# Cek resource usage
docker stats claude-code-container

# Jika perlu, limit resources di docker-compose.yml:
# deploy:
#   resources:
#     limits:
#       memory: 4G
```

---

## 🛡️ Security Best Practices untuk VPS

### 1. Firewall Setup

```bash
# Enable UFW
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP (optional)
sudo ufw allow 443/tcp   # HTTPS (optional)
sudo ufw enable
```

### 2. SSH Hardening

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Recommended settings:
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes

# Restart SSH
sudo systemctl restart sshd
```

### 3. Docker Daemon Security

✅ **Already secured**: Docker daemon hanya listening di `127.0.0.1:2375` (localhost)

❌ **JANGAN** expose ke `0.0.0.0:2375` - ini akan membuka ke internet!

### 4. Regular Updates

```bash
# Update VPS system regularly
sudo apt-get update && sudo apt-get upgrade -y

# Update Docker
sudo apt-get install --only-upgrade docker-ce docker-ce-cli containerd.io
```

### 5. Backup Strategy

```bash
# Backup script
cat > ~/backup-claude.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/home/user/backups"
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup data directory
tar czf "$BACKUP_DIR/claude-data-$DATE.tar.gz" ~/cloud-project/data

# Backup docker volumes (optional)
docker run --rm \
  -v ~/cloud-project/data:/data \
  -v "$BACKUP_DIR":/backup \
  ubuntu tar czf "/backup/claude-volumes-$DATE.tar.gz" /data

# Keep last 7 days
find "$BACKUP_DIR" -name "claude-*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

chmod +x ~/backup-claude.sh

# Add to crontab (daily backup at 2 AM)
crontab -e
# Add line: 0 2 * * * /home/user/backup-claude.sh
```

---

## 📊 Quick Reference: VPS vs Local

| Aspect | Local Development | VPS Deployment |
|--------|------------------|----------------|
| **Access** | `./shell.sh` | SSH ke VPS, then `./shell.sh` |
| **File Sync** | Instant | Copy files ke VPS dulu |
| **Network** | Localhost only | Public IP (perlu firewall) |
| **Persistence** | Local disk | VPS disk |
| **Docker CLI** | Akses host Docker | Akses VPS Docker |
| **Cost** | Free | Bayar VPS (DigitalOcean, AWS, dll) |
| **Performance** | Tergantung machine lokal | Tergantung VPS specs |

---

## 🎯 One-Line Deployment (Copy-Paste ini di VPS)

```bash
# Complete setup dalam satu command
git clone <YOUR_REPO_URL> ~/cloud-project && \
cd ~/cloud-project && \
docker-compose up -d --build && \
sleep 5 && \
docker exec -it claude-code-container bash -c "
  echo '✅ Deployment Complete!'
  echo 'Tools available:'
  go version
  node --version
  python3 --version
  echo ''
  echo 'Next steps:'
  echo '1. Run: ./shell.sh'
  echo '2. Login: claude /login'
  echo '3. Start coding!'
"
```

---

## ✅ Verification Checklist

Setelah deploy di VPS, verify ini semua:

- [ ] Container running: `docker ps | grep claude-code`
- [ ] Docker daemon listening: `sudo ss -tlnp | grep 2375`
- [ ] Docker CLI works: `docker exec claude-code-container docker ps`
- [ ] All tools available: `./shell.sh` then `go version`, `node --version`
- [ ] SSH keys generated: `ls -la data/.ssh/`
- [ ] Can access workspace: `docker exec claude-code-container ls /workspace`
- [ ] Claude Code login: `./shell.sh` → `claude /login`

---

## 🚀 Next Steps

Setelah deploy berhasil:

1. **Setup SSH keys** untuk GitHub/GitLab
   ```bash
   ./shell.sh
   cat ~/.ssh/id_ed25519.pub
   # Copy ke GitHub/GitLab settings
   ```

2. **Install optional tools** (Flutter, Rust, Java, etc.)
   ```bash
   ./shell.sh
   # Follow prompts
   ```

3. **Start development**
   ```bash
   cd /workspace
   # Clone your projects
   # Start coding!
   ```

4. **Setup remote access** (optional)
   - VSCode Remote SSH
   - tmux/screen untuk persistent sessions
   - Web-based terminal (ttyd, gotty, dll)

---

## 📞 Support

Jika ada masalah:

1. Cek logs: `docker-compose logs -f`
2. Cek status: `docker-compose ps`
3. Verify setup: `sudo ss -tlnp | grep 2375`
4. Read documentation: `README.md`, `DOCKER_DAEMON_SETUP.md`, `PATH_CORRUPTION_FIX.md`

---

**Summary**: Di VPS baru, yang perlu disiapkan HANYA:
1. ✅ Docker & Docker Compose
2. ✅ Docker daemon TCP setup (`127.0.0.1:2375`)
3. ✅ Git (untuk clone project)
4. ✅ Upload/deploy project

Setelah itu, **SEMUA LANGSUNG JALAN** - Go, Node.js, Python, Claude Code, semuanya ready! 🎉
