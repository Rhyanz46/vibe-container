# Status Container & Persistensi Data

## 📊 Status Container Saat Ini

**Container Status:** ✅ Running (Healthy)
- **Container ID:** f0f4e60209f0
- **Image:** claude-code:2026.1
- **Status:** Up 4 minutes (healthy)
- **Restart Policy:** unless-stopped

## 🗄️ Volume Persistence (Data Tersimpan Permanen)

### ✅ Data TIDAK Akan Hilang Jika:

1. **Container di-stop**
   ```bash
   docker-compose stop
   # atau
   docker stop claude-code-container
   ```
   - **Data:** AMAN ✅
   - semua config tetap ada di volumes

2. **Container dihapus**
   ```bash
   docker-compose down
   # atau
   docker rm claude-code-container
   ```
   - **Data:** AMAN ✅
   - volumes tetap ada

3. **Container di-restart**
   ```bash
   docker-compose restart
   ```
   - **Data:** AMAN ✅
   - semua config reload dari volumes

4. **Host machine direstart**
   - **Data:** AMAN ✅
   - Docker volumes tetap ada

### ⚠️ Data AKAN Hilang Jika:

1. **Volumes dihapus secara eksplisit**
   ```bash
   docker-compose down -v  # HATI-HATI! flag -v hapus volumes
   ```

2. **Volumes di-delete manual**
   ```bash
   docker volume rm claude-code-config claude-code-data ...
   ```

3. **Docker purge**
   ```bash
   docker system prune -a --volumes  # HATI-HATI!
   ```

## 📁 Apa Saja Yang Tersimpan di Volumes?

### 7 Persistent Volumes:

| Volume Name | Path di Container | Isi | Penting? |
|-------------|------------------|-----|----------|
| `claude-code-config` | `/home/claude/.claude` | **API Keys**, settings, preferences, sessions | ⭐⭐⭐ SANGAT PENTING |
| `claude-code-data` | `/home/claude/.local/share/claude` | Conversations history, cache | ⭐⭐ PENTING |
| `claude-code-local` | `/home/claude/.local` | Binary files, local data | ⭐⭐ PENTING |
| `claude-code-mcp` | `/home/claude/.mcp` | MCP server configurations | ⭐⭐ PENTING |
| `claude-code-npm-cache` | `/home/claude/.npm` | npm package cache | ⭐ Membantu tapi bisa di-rebuild |
| `claude-code-go-workspace` | `/home/claude/go` | Go packages, workspace | ⭐ Membantu tapi bisa di-rebuild |
| `claude-code-go-cache` | `/home/claude/.cache/go-build` | Go build cache | ⭐ Bisa di-rebuild |

## 🔐 Authentication & API Keys

### ✅ Tidak Perlu Config Ulang Jika:

- Anda **TIDAK** menghapus volumes
- API keys tersimpan di `claude-code-config` volume
- Claude Code credentials persist di `~/.claude/`

### ⚠️ Harus Config Ulang Jika:

- Volume `claude-code-config` dihapus
- Anda menjalankan `docker-compose down -v`
- Anda secara manual menghapus volume

## 🛡️ Cara Melindungi Data

### 1. Backup Volumes (Recommended)

```bash
# Backup semua Claude Code volumes
docker run --rm \
  -v claude-code-config:/data/config \
  -v claude-code-data:/data/data \
  -v claude-code-local:/data/local \
  -v claude-code-mcp:/data/mcp \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/claude-code-backup-$(date +%Y%m%d).tar.gz /data

# Restore dari backup
docker run --rm \
  -v claude-code-config:/data/config \
  -v claude-code-data:/data/data \
  -v claude-code-local:/data/local \
  -v claude-code-mcp:/data/mcp \
  -v $(pwd):/backup \
  ubuntu tar xzf /backup/claude-code-backup-YYYYMMDD.tar.gz -C /
```

### 2. Cek Volume Existence Sebelum Hapus

```bash
# List semua Claude Code volumes
docker volume ls | grep claude-code

# Cek isi volume
docker volume inspect claude-code-config

# Cek size (Linux)
du -sh /var/lib/docker/volumes/claude-code-*
```

### 3. Gunakan docker-compose.yml dengan Aman

File `docker-compose.yml` sudah DISETUP dengan:
- ✅ Persistent volumes
- ✅ Restart policy (auto-restart)
- ✅ Health checks
- ✅ Proper ownership

## 🔄 Scenarios: Apa Yang Terjadi Pada Data?

### Scenario 1: Stop Container

```bash
docker-compose stop
# atau
docker stop claude-code-container
```
**Result:** Container stop, **DATA AMAN** di volumes ✅

### Scenario 2: Restart Container

```bash
docker-compose restart
# atau
docker restart claude-code-container
```
**Result:** Container restart, **DATA AMAN**, config reload dari volumes ✅

### Scenario 3: Delete Container (Keep Volumes)

```bash
docker-compose down
# TANPA flag -v
```
**Result:** Container dihapus, **DATA AMAN** di volumes ✅
**Start lagi:** `docker-compose up -d` (data tetap ada!)

### Scenario 4: Rebuild Image

```bash
docker-compose down
docker-compose up -d --build
```
**Result:** Image di-rebuild, **DATA AMAN** di volumes ✅
**Login:** TIDAK perlu lagi, API keys tetap ada!

### Scenario 5: Delete Volumes (⚠️ HATI-HATI)

```bash
docker-compose down -v  # flag -v hapus volumes!
```
**Result:** Container DAN volumes dihapus ❌
**Data:** HILANG SEMUA ❌
**Login:** Harus config ulang dari awal ❌

## 💡 Best Practices

### ✅ DO (Yang Boleh Dilakukan):

1. **Stop/start container semaumu**
   ```bash
   docker-compose stop
   docker-compose start
   ```

2. **Delete container tapi keep volumes**
   ```bash
   docker-compose down  # TANPA -v
   docker-compose up -d
   ```

3. **Rebuild image**
   ```bash
   docker-compose up -d --build
   ```

4. **Restart host machine**
   - Data tetap aman di Docker volumes

### ❌ DON'T (Yang JANGAN Dilakukan):

1. **JANGAN gunakan `-v` flag jika tidak perlu**
   ```bash
   docker-compose down -v  # HAPUS VOLUMES!
   ```

2. **JANGAN delete volumes secara manual**
   ```bash
   docker volume rm claude-code-config  # JANGAN!
   ```

3. **JANGAN gunakan docker system prune -a --volumes**
   ```bash
   docker system prune -a --volumes  # HAPUS SEMUA!
   ```

## 🎯 Summary

| Tindakan | Data Aman? | Perlu Config Ulang? |
|----------|------------|-------------------|
| Stop container | ✅ Ya | ❌ Tidak |
| Start container | ✅ Ya | ❌ Tidak |
| Delete container | ✅ Ya | ❌ Tidak |
| Rebuild image | ✅ Ya | ❌ Tidak |
| Delete volumes | ❌ Tidak | ✅ Ya |
| Host restart | ✅ Ya | ❌ Tidak |

## 📝 Quick Check Command

```bash
# Cek apakah volumes masih ada
docker volume ls | grep claude-code

# Cek container status
docker ps -a | grep claude-code

# Cek volume size
sudo du -sh /var/lib/docker/volumes/claude-code-*
```

## 🔍 Saat Ini (Current State)

- ✅ Container: Running (healthy)
- ✅ Volumes: 7 volumes active
- ✅ API Keys: Tersimpan di `claude-code-config` volume
- ✅ Config: Persisten dan aman
- ✅ Restart: Auto-restart enabled

**Kesimpulan:** Data Anda AMAN selama Anda tidak menghapus volumes! 🎉
