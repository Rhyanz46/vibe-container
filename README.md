# Claude Code Docker Container

Docker container berbasis Ubuntu 24.04 LTS (2026) untuk menjalankan Claude Code dalam environment yang terisolasi.

## Fitur

- Ubuntu 24.04 LTS (Noble Numbat) - Terbaru dan lebih stabil
- Claude Code terinstall secara native (latest version)
- **Golang 1.23.5** - Latest Go version dengan development tools
- **NVM 0.40.1** - Node Version Manager untuk multi-version Node.js
- **Node.js 20, 22, 25** - Multiple LTS dan current versions pre-installed
- **npm** - Package manager untuk Node.js
- **Go tools** - goimports, gotests, gomock, staticcheck
- **Bash completion** - Autocomplete untuk git, go, npm, docker, etc.
- ripgrep untuk search functionality
- Non-root user untuk security
- Persistent volumes untuk config dan cache
- Build tools dan development utilities lengkap
- Optimasi untuk Docker dengan containerd 2.0 support
- **Docker CLI** - Docker client untuk manage containers di host
- **Host Network Mode** - Semua port otomatis ke-expose ke host (perfect untuk development!)

## Persyaratan

- Docker (version 24.0+ atau Docker Desktop terbaru)
- Docker Compose (version 2.0+)
- Minimal 4GB RAM yang tersedia untuk Docker (8GB+ recommended)
- Koneksi internet untuk download dependencies dan Claude Code authentication
- Supported OS: Linux, macOS, atau Windows dengan WSL2

## Apa yang Baru di 2026

- **Ubuntu 24.04 LTS** - Lebih stabil dengan containerd 2.0 support
- **Golang 1.23.5** - Latest Go dengan development tools lengkap
- **NVM 0.40.1** - Node Version Manager untuk switch Node versions dengan mudah
- **Node.js Multi-Version** - v20.20.0 (LTS), v22.22.0 (LTS), v25.4.0 (Current) pre-installed
- **Bash Completion** - Full autocomplete support untuk semua command
- **Go Development Tools** - goimports, gotests, gomock, staticcheck pre-installed
- **Security improvements** - Non-root user dengan sudo access
- **Better tooling** - wget, jq, unzip untuk enhanced functionality
- **Optimized layers** - Lebih kecil image size dan faster build times
- **Docker CLI** - Docker client untuk manage containers di host/VPS
- **Host Network Mode** - Automatic port exposure untuk development apps

## Cara Build dan Run

### Start Container

```bash
# Build dan start container
docker-compose up -d --build

# Masuk ke dalam container
docker exec -it claude-code-container bash

# Login ke Claude Code (hanya perlu sekali)
claude /login

# Setelah login, jalankan Claude Code
claude
```

**Data Storage:**
Semua data disimpan di directory `./data/` (sejajar dengan docker-compose.yml):
- `./data/.claude/` - Konfigurasi dan API keys
- `./data/.local/` - Claude Code binary dan local files
- `./data/.local/share/claude/` - Conversations dan cache
- `./data/.mcp/` - MCP server configurations
- `./data/.npm/` - npm package cache
- `./data/go/` - Go workspace dan packages
- `./data/.cache/go-build/` - Go build cache

✅ **Keuntungan:**
- Semua data di satu tempat (next to docker-compose.yml)
- Mudah di-backup (c整个 folder `./data/`)
- Mudah di-inspect dan di-edit
- Transparent dan predictable

### Menggunakan Docker CLI (Manual)

```bash
# Build image
docker build -t claude-code:latest .

# Run container dengan directory mounts
docker run -it --name claude-code-container \
  --network host \
  -v $(pwd):/workspace \
  -v $(pwd)/data/.claude:/home/claude/.claude \
  -v $(pwd)/data/.local:/home/claude/.local \
  -v $(pwd)/data/.local/share/claude:/home/claude/.local/share/claude \
  -v $(pwd)/data/.mcp:/home/claude/.mcp \
  -v $(pwd)/data/.npm:/home/claude/.npm \
  -v $(pwd)/data/go:/home/claude/go \
  -v $(pwd)/data/.cache/go-build:/home/claude/.cache/go-build \
  -v /var/run/docker.sock:/var/run/docker.sock \
  claude-code:latest
```

## Authentication & Setup

### Langkah 1: Login ke Claude Code

Setelah container running, login hanya perlu dilakukan **sekali**:

```bash
# Masuk ke container
docker exec -it claude-code-container bash

# Login ke Claude Code
claude /login

# Follow instruksi di browser untuk authenticate
```

### Langkah 2: Verifikasi Login

```bash
# Cek apakah sudah login
claude --print "Hello, Claude!"

# Jika berhasil, Claude akan merespon
```

### Langkah 3: Gunakan Claude Code

```bash
# Mode interactive
docker exec -it claude-code-container claude

# Atau langsung dengan prompt
docker exec claude-code-container claude --print "your prompt here"
```

### Authentication Options

Ada beberapa cara untuk authenticate Claude Code:

**1. Claude Pro/Max Account (Recommended)**
- Login dengan Claude.ai account
- Satu subscription untuk web dan CLI
- Management terpadu

**2. Claude Console with API Key**
```bash
# Set API key directly
echo "ANTHROPIC_API_KEY=your_key_here" >> .env
docker-compose up -d
```

**3. Cloud Provider**
- Amazon Bedrock
- Google Vertex AI
- Microsoft Foundry

## Persistent Storage Details

### Data Storage Structure

Semua data Claude Code dan development tools disimpan di directory `./data/`:

| Host Path | Container Path | Isi |
|-----------|---------------|-----|
| `./data/.claude/` | `/home/claude/.claude` | Config & API keys |
| `./data/.local/` | `/home/claude/.local` | Binary & local files |
| `./data/.local/share/claude/` | `/home/claude/.local/share/claude` | Cache & conversations |
| `./data/.mcp/` | `/home/claude/.mcp` | MCP configs |
| `./data/.npm/` | `/home/claude/.npm` | npm cache |
| `./data/go/` | `/home/claude/go` | Go workspace & packages |
| `./data/.cache/go-build/` | `/home/claude/.cache/go-build` | Go build cache |

**Backup:**
```bash
# Backup semua data (satu command untuk semua!)
tar czf claude-code-backup.tar.gz data/

# Restore
tar xzf claude-code-backup.tar.gz

# Atau dengan rsync
rsync -av data/ /backup/location/
```

**Keuntungan:**
- Semua data di satu directory
- Direct access dari host
- Easy backup dengan satu command
- Transparent dan mudah di-inspect

## Development Environment

### Golang 1.23.5

Container sudah terinstall dengan Go 1.23.5 dan development tools:

```bash
# Cek Go version
docker exec claude-code-container go version

# Go environment
# GOPATH: /home/claude/go
# GOROOT: /usr/local/go
```

**Pre-installed Go Tools:**
- `goimports` - Auto import management
- `gotests` - Automatically generate Go tests
- `gomock` - Go mocking framework
- `staticcheck` - Go static analysis

**Go Development Commands:**
```bash
# Initialize Go module
docker exec claude-code-container go mod init github.com/user/project

# Build Go project
docker exec claude-code-container go build ./...

# Run Go tests
docker exec claude-code-container go test ./...

# Install Go package
docker exec claude-code-container go get github.com/pkg/package

# Format Go code
docker exec claude-code-container gofmt -w .

# Run goimports
docker exec claude-code-container goimports -w .
```

### Node.js dengan NVM (Node Version Manager)

Container menggunakan NVM untuk manage multiple Node.js versions:

**Pre-installed Versions:**
- Node.js **v20.20.0** - LTS (Iron)
- Node.js **v22.22.0** - LTS (Jod)
- Node.js **v25.4.0** - Current (Default)

**NVM Commands:**
```bash
# List installed versions
nvm ls

# Switch Node version
nvm use 20      # Switch to Node 20
nvm use 22      # Switch to Node 22
nvm use 25      # Switch to Node 25 (default)

# Install new version
nvm install 18              # Install Node 18
nvm install --lts           # Install latest LTS

# Set default version
nvm alias default 20        # Set Node 20 as default

# Check current version
node --version
nvm current

# Check NVM version
nvm --version
```

**Examples:**
```bash
# Use Node 20 for legacy project
docker exec -it claude-code-container bash
nvm use 20
node --version  # v20.20.0

# Use Node 25 for latest features
nvm use 25
node --version  # v25.4.0

# Install and use Node 18
nvm install 18
nvm use 18
node --version  # v18.20.8

# Check available versions
nvm ls
```

**Project-specific Node versions:**
```bash
# Create .nvmrc file in project directory
echo "20" > /workspace/project/.nvmrc

# NVM will auto-switch to that version
cd /workspace/project
nvm use
```

### Multi-Language Development

Container mendukung development dengan Go dan Node.js secara bersamaan:

```bash
# Contoh: Fullstack project dengan Go backend dan Node.js frontend
workspace/
├── backend/          # Go API
│   ├── main.go
│   └── go.mod
└── frontend/         # Node.js/React app
    ├── package.json
    └── src/
```

**Commands:**
```bash
# Development
docker exec -it claude-code-container bash
cd /workspace/backend && go run main.go
cd /workspace/frontend && npm run dev

# Testing
docker exec claude-code-container bash -c "cd backend && go test ./..."
docker exec claude-code-container bash -c "cd frontend && npm test"

# Building
docker exec claude-code-container bash -c "cd backend && go build -o api"
docker exec claude-code-container bash -c "cd frontend && npm run build"
```

## Tips Penggunaan

### Menjalankan command langsung dari host

```bash
docker-compose exec claude-code claude --version
```

### Auto-mount current directory

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  claude-code:latest \
  claude
```

### Update Claude Code di dalam container

```bash
docker-compose exec claude-code claude update
```

## Troubleshooting

### Claude Code tidak ditemukan

Pastikan PATH sudah benar:
```bash
export PATH="/home/claude/.local/bin:${PATH}"
```

### Permission issues

```bash
docker-compose exec claude-code bash
# Inside container
sudo chown -R claude:claude /workspace
```

### Container tidak bisa start

Cek logs:
```bash
docker-compose logs claude-code
```

### Remove dan rebuild dari awal

```bash
docker-compose down -v
docker-compose up -d --build
```

## Environment Variables

- `DISABLE_AUTOUPDATER=1` - Disable auto-update (recommended untuk containers)
- `DISPLAY` - Untuk X11 forwarding (jika butuh GUI apps)

## Network & Port Exposure

### Host Network Mode

Container menggunakan **host network mode**, yang berarti:

✅ **Keuntungan:**
- **Semua port otomatis ke-expose** ke host tanpa perlu port mapping
- Perfect untuk development - tidak perlu config `-p` untuk setiap port
- App di container bisa langsung diakses via `localhost:PORT` di host
- Lebih simpel untuk develop banyak aplikasi sekaligus

**Contoh:**
```bash
# Di dalam container, jalankan Node.js app di port 3000
docker exec -it claude-code-container bash
cd /workspace/my-app
npm run dev  # Listening on port 3000

# Langsung accessible di host:
# http://localhost:3000
# Tanpa perlu port mapping!
```

**Contoh Multiple Apps:**
```bash
# App 1 - Node.js di port 3000
cd /workspace/app1 && npm run dev  # → http://localhost:3000

# App 2 - Go di port 8080
cd /workspace/app2 && go run main.go  # → http://localhost:8080

# App 3 - Python di port 5000
cd /workspace/app3 && python app.py  # → http://localhost:5000

# Semua langsung accessible tanpa config tambahan!
```

⚠️ **Perhatian:**
- Hanya gunakan untuk development
- Tidak disarankan untuk production (security & isolation concerns)
- Pastikan tidak ada port conflict antar aplikasi

## Docker CLI Integration

Container dilengkapi dengan **Docker CLI** untuk manage containers di host/VPS:

**Fitur:**
- Docker client terinstall (Docker version 29.1.5)
- Docker socket dari host di-mount ke container
- Bisa manage semua containers/images di host dari dalam container
- Perfect untuk deployment workflows

**Contoh Penggunaan:**
```bash
# Masuk ke container
docker exec -it claude-code-container bash

# List semua containers di host
docker ps

# List semua images di host
docker images

# Build image dari dalam container
docker build -t myapp:latest /workspace/myapp

# Run container baru di host
docker run -d --name myapp myapp:latest

# Check logs container lain
docker logs some-container

# Stop/start container lain
docker stop some-container
docker start some-container
```

**Use Cases:**
1. **Build & Deploy** - Build Docker image dari dalam container, lalu deploy ke host
2. **Container Orchestration** - Manage multiple containers untuk microservices
3. **CI/CD Pipelines** - Automated build dan deployment
4. **Development Testing** - Test integration antar containers

**Catatan:**
- Container ini punya akses penuh ke Docker daemon di host
- Gunakan dengan hati-hati - punya akses ke semua containers
- Pastikan user permission sudah benar (user `claude` sudah di group `docker`)

## Security Notes

### Security Features (2026 Edition)

Container ini dilengkapi dengan **security improvements** untuk development environment:

✅ **Non-Root User Execution:**
- Container jalan sebagai user `claude` (UID 1001), bukan root
- Mengikuti prinsip *least privilege*
- Mengurangi risk jika container compromised

✅ **Docker Group Access:**
- User `claude` ditambahkan ke docker group (GID 998)
- Bisa akses Docker socket untuk container management
- Perlu akses ini untuk Docker CLI functionality

⚠️ **Security Considerations:**

**Masih ada beberapa security tradeoffs untuk convenience:**
1. **Passwordless sudo** - User `claude` bisa jadi root tanpa password
   - *Reasoning*: Development convenience untuk package installation
   - *Risk*: Medium - hanya issue jika container compromised

2. **Docker socket mount** - Container punya akses ke host Docker daemon
   - *Reasoning*: Diperlukan untuk manage containers dari dalam development environment
   - *Risk*: High - tapi acceptable untuk trusted development environment

3. **Host network mode** - Tidak ada network isolation
   - *Reasoning*: Automatic port exposure untuk development apps
   - *Risk*: Low - hanya untuk development, bukan production

### Security Best Practices

**Untuk Development Environment (Current Config):**
- ✅ AMAN untuk local/private VPS development
- ✅ OK untuk trusted environments
- ⚠️ JANGAN expose ke public internet tanpa firewall
- ⚠️ JANGAN jalankan untrusted code

**Untuk Production:**
- ❌ JANGAN gunakan config ini untuk production
- ❌ Perlu additional hardening measures
- ✅ Gunakan container security best practices:
  - Read-only root filesystem
  - Remove passwordless sudo
  - Implement proper secrets management
  - Use network policies
  - Enable AppArmor/SELinux
  - Regular security updates

**Data Protection:**
- ✅ Data disimpan di `./data/` (terpisah dari container)
- ✅ `./data/` di-.gitignore dan di-.dockerignore
- ✅ API keys tersimpan di `./data/.claude/` (tidak di-commit ke git)
- ⚠️ Pastikan `./data/` tidak di-commit ke version control

**Recommendations:**
1. Regular backup data di `./data/`
2. Monitor container access dan activity
3. Gunakan firewall di VPS/host
4. Jangan share container akses ke untrusted users
5. Review code sebelum di-run (meskipun dari Claude Code)

### Security Comparison

| Aspect | Before | After (Opsi 1) | Improvement |
|--------|--------|----------------|-------------|
| **Default User** | root | claude (1001) | ✅ Significantly better |
| **Process Isolation** | Low | Medium | ✅ Better |
| **Privilege Escalation** | Easy (root) | Harder (need sudo) | ✅ Better |
| **Damage if Compromised** | High | Medium | ✅ Reduced |
| **Convenience** | High | High | ✅ Maintained |
| **Development Workflow** | Smooth | Smooth | ✅ No impact |

## Cleanup

### Stop dan remove container

```bash
docker-compose down
```

### Remove volumes (hapus semua Claude Code data)

```bash
docker-compose down -v
```

### Remove image

```bash
docker rmi claude-code:latest
```

## Resources

- [Claude Code Official Documentation](https://code.claude.com/docs/en/setup)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)
- [Docker Documentation](https://docs.docker.com/)
- [Ubuntu 24.04 LTS Release Notes](https://discourse.ubuntu.com/t/ubuntu-24-04-lts-noble-numbat-release-notes/39890)
- [Node.js 20 LTS Documentation](https://nodejs.org/docs/latest-v20.x/)

## Changelog

### Version 2026.1 (January 2026)
- Upgrade to Ubuntu 24.04 LTS base image
- Upgrade Node.js from 18 to 20 LTS
- Add additional development tools (wget, jq, unzip)
- Add sudo support for non-root user
- Improve build optimization
- Update documentation for 2026 standards

## License

This Docker configuration is provided as-is for running Claude Code.
Claude Code itself is owned by Anthropic.

---

**Last Updated:** January 2026
**Maintained for:** Claude Code community usage
