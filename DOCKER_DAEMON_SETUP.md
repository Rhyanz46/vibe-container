# Docker Daemon TCP Setup untuk Container

## Ringkasan

Container ini menggunakan `network_mode: host` untuk mengakses Docker daemon host melalui TCP socket di `127.0.0.1:2375`.

## Keamanan

**PENTING**: Docker daemon hanya listening di `127.0.0.1:2375` (localhost only), BUKAN `0.0.0.0:2375`.

Ini berarti:
- ✅ Aman - tidak terbuka ke internet
- ✅ Hanya localhost yang bisa akses
- ✅ Container bisa akses karena `network_mode: host`
- ✅ Host machine tetap bisa akses via Unix socket `/var/run/docker.sock`

## Setup yang Sudah Dilakukan

### 1. Konfigurasi Docker Daemon (`/etc/docker/daemon.json`)
```json
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://127.0.0.1:2375"]
}
```

### 2. Systemd Override (`/etc/systemd/system/docker.service.d/override.conf`)
```ini
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
```

### 3. Docker Daemon Berjalan
```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## Verifikasi

### Cek Docker daemon listening:
```bash
sudo ss -tlnp | grep 2375
# Output: LISTEN 0 4096 127.0.0.1:2375 ...
```

### Test dari dalam container:
```bash
./shell.sh
docker ps          # List host containers
docker images      # List host images
docker compose up  # Run docker-compose
```

## Troubleshooting

### Jika docker ps error:
```
Cannot connect to the Docker daemon at tcp://localhost:2375
```

**Solusi**:
1. Cek apakah Docker daemon berjalan:
   ```bash
   sudo systemctl status docker
   ```

2. Cek apakah listening di port 2375:
   ```bash
   sudo ss -tlnp | grep 2375
   ```

3. Jika tidak listening di 2375:
   ```bash
   sudo systemctl restart docker
   ```

### Jika container error saat build/start:
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Keuntungan Setup Ini

1. **Docker CLI dalam container**: Bisa manage host containers dari dalam container
2. **Aman**: Hanya localhost yang bisa akses, tidak terbuka ke internet
3. **Shared network**: Container & host share network stack (`network_mode: host`)
4. **No port conflicts**: Tidak perlu port mapping

## File Konfigurasi

- `/etc/docker/daemon.json` - Docker daemon configuration
- `/etc/systemd/system/docker.service.d/override.conf` - Systemd override
- `docker-compose.yml` - Container configuration (network_mode: host, DOCKER_HOST environment)
