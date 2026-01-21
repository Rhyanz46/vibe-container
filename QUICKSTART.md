# Quick Start Guide

## 🚀 Masuk ke Container

Gunakan script `exec.sh` untuk masuk ke container dengan mudah:

```bash
# Masuk ke container (interactive bash shell)
./exec.sh

# Jalankan perintah di dalam container
./exec.sh ls -la
./exec.sh go version
./exec.sh pwd

# Jalankan multiple commands
./exec.sh bash -c "cd /workspace && ls -la"
```

## 📝 Perintah Docker Umum

```bash
# Start container
docker-compose up -d

# Stop container
docker-compose down

# Restart container
docker-compose restart

# Lihat logs container
docker-compose logs -f

# Lihat status container
docker ps
```

## 🔑 Setup SSH Key di GitHub

1. Masuk ke container:
   ```bash
   ./exec.sh
   ```

2. Copy SSH public key yang ditampilkan di welcome message

3. Tambahkan ke GitHub:
   - Go to: https://github.com/settings/keys
   - Click: "New SSH key"
   - Paste key dan "Add SSH key"

## 💡 Contoh Penggunaan

### Development
```bash
# Masuk ke container
./exec.sh

# Di dalam container:
cd /workspace
git clone git@github.com:username/repo.git
cd repo
npm install
npm start
```

### Build & Test
```bash
# Jalankan tests di container
./exec.sh go test ./...

# Build project
./exec.sh npm run build
```

### Docker Operations dari Dalam Container
```bash
# Lihat containers di host
./exec.sh docker ps

# Build image dari host
./exec.sh docker build -t myapp .

# Run container baru
./exec.sh docker run -d myapp
```

## 🛠️ Development Tools yang Tersedia

- **Go**: 1.23.5
- **Node.js**: 20 (LTS), 22 (LTS), 25 (Current)
- **Python**: 3.12.3
- **npm**: Global package manager
- **git**: Version control dengan SSH key
- **ripgrep (rg)**: Fast grep
- **Playwright**: Browser automation (install on demand)

## 📚 Mode Networking

Container menggunakan **host network mode**, artinya:
- `localhost` di container = `localhost` di host
- Semua ports otomatis exposed
- Tidak perlu port mapping

Contoh:
```bash
# Di dalam container, jalankan server di port 3000
./exec.sh bash -c "cd /workspace/myapp && npm start"

# Akses langsung dari host browser
# http://localhost:3000
```

## 🔧 Troubleshooting

### Container tidak berjalan?
```bash
docker-compose up -d
```

### Permission denied?
```bash
sudo chown -R $USER:$USER .
```

### Container perlu rebuild?
```bash
docker-compose down
docker-compose build
docker-compose up -d
```
