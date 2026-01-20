# 🚀 Deployment ke VPS

## ✅ Ya, Langsung Jalan!

Di VPS, **semua langsung available** setelah menjalankan `docker-compose up -d`. Tidak perlu setup apa-apa lagi!

## 📋 Checklist Apa yang Sudah Tersedia

### ✅ 1. Golang 1.23.5
```bash
# Di VPS, langsung bisa pakai:
docker exec -it claude-code-container go version
# Output: go version go1.23.5 linux/amd64
```

**Yang termasuk:**
- ✅ Go compiler & toolchain
- ✅ Go workspace (`/home/claude/go`)
- ✅ Go tools: `goimports`, `gotests`, `staticcheck`
- ✅ Bash completion untuk `go` command

### ✅ 2. NVM 0.40.1 + Multiple Node.js Versions
```bash
# Di VPS, langsung ada:
docker exec -it claude-code-container bash
nvm ls
# Output:
#        v20.20.0 *
#        v22.22.0 *
# ->      v25.4.0 * (default)
```

**Yang termasuk:**
- ✅ Node.js v20.20.0 (LTS)
- ✅ Node.js v22.22.0 (LTS)
- ✅ Node.js v25.4.0 (Current, default)
- ✅ npm dengan tiap versi
- ✅ NVM command untuk switch versions
- ✅ Bash completion untuk `npm`

### ✅ 3. Claude Code 2.1.12
```bash
# Di VPS, langsung bisa pakai:
docker exec -it claude-code-container claude --version
# Output: 2.1.12 (Claude Code)
```

**Yang termasuk:**
- ✅ Claude Code binary
- ✅ MCP support
- ✅ Bash completion untuk `claude`
- ⚠️ **Perlu login pertama kali** untuk API keys

### ✅ 4. Bash Autocomplete
```bash
# Di VPS, langsung available:
docker exec -it claude-code-container bash
# Coba TAB untuk autocomplete, misal:
git che[TAB]  # Autocomplete ke: checkout
npm ru[TAB]  # Autocomplete ke: run
go bu[TAB]   # Autocomplete ke: build
```

**Yang termasuk:**
- ✅ Git completion
- ✅ Go completion
- ✅ npm completion
- ✅ Docker completion
- ✅ File & directory completion
- ✅ Command history navigation

## 🎯 Apa yang Perlu Dilakukan di VPS

### Step 1: Copy Files ke VPS
```bash
# Copy semua file ke VPS
scp -r docker-project/ user@your-vps-ip:/home/user/

# Atau dengan git
git clone <your-repo> user@your-vps-ip:/home/user/docker-project
```

### Step 2: SSH ke VPS
```bash
ssh user@your-vps-ip
cd docker-project
```

### Step 3: Start Container
```bash
# Build dan start container
docker-compose up -d --build
```

**Selesai!** Semua sudah siap.

### Step 4: Login ke Claude Code (Hanya Sekali)
```bash
# Masuk ke container
docker exec -it claude-code-container bash

# Login ke Claude Code
claude /login

# Follow instruksi di browser
```

**Setelah login:**
- ✅ API keys tersimpan di persistent volumes
- ✅ Tidak perlu login lagi
- ✅ Config tetap ada meskipun container restart

## 🔍 Verification (Setelah Deploy di VPS)

```bash
# Cek container status
docker-compose ps

# Cek semua tools
docker exec -it claude-code-container bash -c "
  echo '=== Environment Check ==='
  go version
  nvm --version
  node --version
  npm --version
  claude --version
  echo '=== All Ready! ==='
"

# Cek volumes
docker volume ls | grep claude-code

# Cek autocomplete
docker exec -it claude-code-container bash
# Tekan TAB untuk test autocomplete
```

## 💡 Perbedaan Local vs VPS

| Aspect | Local Development | VPS Production |
|--------|------------------|-----------------|
| **Container Access** | `docker-compose exec` | `docker-compose exec` atau SSH ke VPS |
| **File Mounting** | Local dir mounted to `/workspace` | VPS dir mounted to `/workspace` |
| **Persistent Data** | Same (Docker volumes) | Same (Docker volumes) |
| **API Keys** | Same (stored in volumes) | Same (stored in volumes) |
| **Autocomplete** | Same (fully configured) | Same (fully configured) |
| **Tools Availability** | Same (all pre-installed) | Same (all pre-installed) |

## 🌐 Mengakses dari Remote

### Opsi 1: SSH + Docker Exec
```bash
# SSH ke VPS
ssh user@your-vps-ip

# Gunakan Claude Code
cd docker-project
docker exec -it claude-code-container claude
```

### Opsi 2: VSCode Remote SSH + Docker Extension
```bash
# Install VSCode Remote SSH extension
# Connect to VPS via SSH
# Open folder: /home/user/docker-project
# Attach to container: claude-code-container
```

### Opsi 3: Web-based Terminal (Optional)
```bash
# Install tmux atau byobu di VPS
ssh user@your-vps-ip
tmux new -s claude
docker exec -it claude-code-container bash
# Detach: Ctrl+B, D
# Reattach: tmux attach -t claude
```

## 🛡️ Security Recommendations untuk VPS

### 1. Firewall Setup
```bash
# Hanya buka port yang diperlukan
sudo ufw allow 22/tcp  # SSH
sudo ufw allow 80/tcp  # HTTP (jika butuh)
sudo ufw allow 443/tcp # HTTPS (jika butuh)
sudo ufw enable
```

### 2. SSH Hardening
```bash
# Edit /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no

# Restart SSH
sudo systemctl restart sshd
```

### 3. Docker Security
```bash
# Pastikan hanya user yang authorized bisa akses docker
sudo usermod -aG docker your-user

# Atau gunakan sudo untuk docker commands
```

### 4. Backup Data
```bash
# Backup volumes定期
docker run --rm \
  -v claude-code-config:/data/config \
  -v /path/to/backup:/backup \
  ubuntu tar czf /backup/claude-config-$(date +%Y%m%d).tar.gz /data
```

## 🎯 Quick Start di VPS (One-liner)

```bash
# Clone/paste ini di VPS:
git clone <your-repo> claude-code && \
cd claude-code && \
docker-compose up -d --build && \
docker exec -it claude-code-container claude /login
```

**Done!** Semua langsung jalan di VPS! 🚀

## 📊 Summary: Apa yang Langsung Available di VPS

| Component | Version | Ready to Use? |
|-----------|---------|---------------|
| **Golang** | 1.23.5 | ✅ Ya, langsung bisa `go build` |
| **NVM** | 0.40.1 | ✅ Ya, langsung bisa `nvm use 20` |
| **Node.js 20** | v20.20.0 | ✅ Ya, pre-installed |
| **Node.js 22** | v22.22.0 | ✅ Ya, pre-installed |
| **Node.js 25** | v25.4.0 | ✅ Ya, pre-installed (default) |
| **npm** | 11.7.0 | ✅ Ya, langsung bisa `npm install` |
| **Claude Code** | 2.1.12 | ✅ Ya, tinggal login sekali |
| **Git completion** | Latest | ✅ Ya, TAB untuk autocomplete |
| **Go completion** | Latest | ✅ Ya, TAB untuk autocomplete |
| **npm completion** | Latest | ✅ Ya, TAB untuk autocomplete |
| **Aliases** | ll, la, cls, .., ... | ✅ Ya, langsung bisa dipakai |
| **Colored output** | ls, grep | ✅ Ya, terminal berwarna |
| **History** | 10,000 lines | ✅ Ya, up/down arrow untuk history |

**Kesimpulan:** DI VPS, **LANGSUNG JALAN** semua! Tinggal `docker-compose up -d` dan semua tools siap digunakan. Tidak perlu setup apa-apa lagi! 🎉
