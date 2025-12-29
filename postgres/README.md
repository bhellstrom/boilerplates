# PostgreSQL Production Setup

PostgreSQL 18 production deployment with automated daily backups, health monitoring, and optimized configuration.

## Features

- ✅ PostgreSQL 18 with optimized configuration for 8GB shared environment
- ✅ Automated daily backups at midnight (with 7-day retention)
- ✅ Docker secrets for secure password management
- ✅ Health checks and auto-restart
- ✅ Resource limits (2GB RAM, 2 CPU cores)
- ✅ Comprehensive logging
- ✅ UTF-8 encoding

## Quick Start

### Prerequisites
- Docker & Docker Compose
- SSH access to production server

### Deployment

1. Clone repository:
```bash
git clone <your-repo-url>
cd postgres-prod-utf8
```

2. Configure secrets:
```bash
# Create password file
echo "your_secure_password" > secrets/postgres_password
chmod 600 secrets/postgres_password
```

3. Start services:
```bash
docker compose up -d --build
```

4. Verify status:
```bash
docker compose ps
docker compose logs -f
```

## Configuration

### PostgreSQL Settings
- **User:** myuser
- **Database:** mydb
- **Port:** 5432 (internal network only)
- **Memory:** 2GB limit, 1GB reserved
- **CPU:** 2 cores max, 1 core reserved

Settings can be modified in `postgres-conf/postgresql.conf`

### Backup Configuration
- **Schedule:** Daily at 00:00 (midnight)
- **Retention:** 7 days
- **Location:** `./backups/`
- **Format:** Compressed SQL (gzip)

To change schedule, edit `backup/crontab-root`

## Directory Structure

```
.
├── docker-compose.yml          # Main compose file
├── secrets/
│   └── postgres_password       # Database password (not in git)
├── postgres-conf/
│   └── postgresql.conf         # PostgreSQL configuration
├── backup/
│   ├── Dockerfile             # Backup container image
│   ├── backup.sh              # Backup script
│   └── crontab-root           # Cron schedule
├── backups/                   # Backup storage (not in git)
├── initdb/                    # Init scripts (run once)
└── README.md
```

## Maintenance

### View logs
```bash
docker compose logs postgres
docker compose logs backup
```

### Manual backup
```bash
docker exec postgres_backup /usr/local/bin/backup.sh
```

### Restore from backup
```bash
gunzip -c backups/backup_YYYY-MM-DD_HH-MM-SS.sql.gz | \
  docker exec -i postgres psql -U myuser -d mydb
```

### Update configuration
```bash
# Edit config files, then:
docker compose restart postgres
```

### Rebuild backup container
```bash
docker compose up -d --build backup
```

## Monitoring

### Check backup status
```bash
tail -f backups/backup_summary.log
ls -lh backups/
```

### Check database health
```bash
docker exec postgres pg_isready -U myuser -d mydb
docker exec postgres psql -U myuser -d mydb -c "SELECT version();"
```

## Security Considerations

- Passwords stored in Docker secrets (not environment variables)
- Backup files are stored locally only
- Database accessible only within Docker network
- Resource limits prevent resource exhaustion

### TODO for Enhanced Security
- [ ] Set up offsite backup sync (rsync/rclone)
- [ ] Implement backup monitoring/alerting
- [ ] Enable SSL/TLS for connections
- [ ] Restrict `listen_addresses` to specific networks
- [ ] Set up WAL archiving for point-in-time recovery

## Troubleshooting

### Container won't start
```bash
docker compose logs postgres
docker compose ps
```

### Backups not running
```bash
docker exec postgres_backup crontab -l
docker exec postgres_backup ps aux | grep cron
```

### Database connection issues
```bash
docker exec postgres pg_isready -U myuser -d mydb
docker compose logs postgres | grep error
```

## Production Readiness: 8/10

✅ Core functionality complete
⚠️ Recommended additions: Offsite backups, monitoring/alerting

## License

Internal use only

## Advanced: Push Backup Image to Docker Hub

If you want to share the backup container image across multiple servers or with a team, you can push it to Docker Hub.

### Prerequisites
- Docker Hub account
- Logged in: `docker login`

### Steps

1. **Build and tag the image:**
```bash
cd backup/
docker build -t yourusername/postgres-backup:latest .
```

2. **Tag with version (optional but recommended):**
```bash
docker tag yourusername/postgres-backup:latest yourusername/postgres-backup:1.0.0
```

3. **Push to Docker Hub:**
```bash
docker push yourusername/postgres-backup:latest
docker push yourusername/postgres-backup:1.0.0
```

4. **Update docker-compose.yml to use the image:**
```yaml
services:
  backup:
    image: yourusername/postgres-backup:latest
    # Remove the 'build:' section
    container_name: postgres_backup
    # ... rest of config
```

### When to Push to Docker Hub

**Push when:**
- ✅ You have multiple servers running the same setup
- ✅ You want to share with team members
- ✅ You want faster deployments (no build time)

**Don't push when:**
- ❌ Single server deployment (local build is simpler)
- ❌ You want to keep backup logic private
- ❌ You're still testing/iterating (build locally)

**Note:** For this boilerplate, local build is recommended for most use cases.
