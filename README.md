# Boilerplates

Collection of production-ready Docker configurations and templates.

## Available Boilerplates

### [postgres](./postgres/)
PostgreSQL 18 production setup with automated daily backups, health monitoring, and optimized configuration.

**Features:**
- Automated daily backups with retention
- Docker secrets for password management
- Health checks and resource limits
- Optimized for 8GB shared environment

[See postgres/README.md for details](./postgres/README.md)

---

## Usage

Each boilerplate has its own directory with complete setup instructions.

```bash
# Clone repository
git clone git@github.com:hellstrom73/boilerplates.git
cd boilerplates

# Choose a boilerplate
cd postgres

# Follow the README in that directory
```

## Contributing

When adding new boilerplates:
1. Create a new directory with descriptive name
2. Include README.md with setup instructions
3. Add .gitignore for secrets/data
4. Update this main README with link

## Structure

```
boilerplates/
├── README.md           # This file
├── postgres/           # PostgreSQL setup
├── nginx/              # (Future: Nginx reverse proxy)
├── monitoring/         # (Future: Prometheus/Grafana)
└── ...
```
