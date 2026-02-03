# Complete Dev Container Guide for Frappe Development

This guide provides comprehensive documentation for setting up and using the VS Code Dev Container environment for Frappe/ERPNext development.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration Files](#configuration-files)
- [Services](#services)
- [Development Workflow](#development-workflow)
- [Automated Setup with installer.py](#automated-setup-with-installerpy)
- [VS Code Integration](#vs-code-integration)
- [Debugging](#debugging)
- [Database Options](#database-options)
- [Optional Services](#optional-services)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Overview

The Frappe Docker Dev Container provides a fully containerized development environment that includes:

- **Frappe Bench**: The development container with Python, Node.js, and all required tools
- **MariaDB/PostgreSQL**: Database server
- **Redis**: Cache and queue services
- **Optional services**: Mailpit (email testing), Cypress (UI testing)

This setup ensures consistency across development machines and eliminates "works on my machine" issues.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Docker Network                           │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │   MariaDB   │  │ Redis Cache │  │      Frappe Bench       │ │
│  │   :3306     │  │   :6379     │  │  (Development Container)│ │
│  └─────────────┘  └─────────────┘  │                         │ │
│                                     │  - Python (pyenv)       │ │
│  ┌─────────────┐  ┌─────────────┐  │  - Node.js (nvm)        │ │
│  │ PostgreSQL  │  │ Redis Queue │  │  - Bench CLI            │ │
│  │   :5432     │  │   :6379     │  │  - VS Code Extensions   │ │
│  │ (optional)  │  └─────────────┘  │                         │ │
│  └─────────────┘                   │  Ports: 8000-8005       │ │
│                                     │         9000-9005       │ │
│  ┌─────────────┐  ┌─────────────┐  └─────────────────────────┘ │
│  │   Mailpit   │  │   Cypress   │                               │
│  │   :8025     │  │ (optional)  │                               │
│  │ (optional)  │  └─────────────┘                               │
│  └─────────────┘                                                │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

### System Requirements

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher (V2 syntax)
- **VS Code**: Latest version recommended
- **RAM**: Minimum 4GB allocated to Docker (8GB recommended)
- **Disk Space**: At least 10GB free space

### Installing Prerequisites

#### Docker Desktop (Windows/macOS)

1. Download from [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Install and start Docker Desktop
3. Allocate at least 4GB RAM in Settings → Resources

#### Docker Engine (Linux)

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
```

#### VS Code Dev Containers Extension

Install via one of these methods:

```bash
# Command line
code --install-extension ms-vscode-remote.remote-containers
```

Or search for "Dev Containers" (ms-vscode-remote.remote-containers) in VS Code Extensions.

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/frappe/frappe_docker.git
cd frappe_docker
```

### 2. Copy Configuration Files

```bash
# Copy devcontainer configuration
cp -R devcontainer-example .devcontainer

# Copy VS Code settings for debugging
cp -R development/vscode-example development/.vscode
```

### 3. Open in VS Code

```bash
code .
```

### 4. Reopen in Container

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
2. Type "Dev Containers: Reopen in Container"
3. Select the command and wait for the container to build

### 5. Initialize Development Environment

Once inside the container, run the automated installer:

```bash
cd /workspace/development
python installer.py
```

Or set up manually (see [Development Workflow](#development-workflow)).

### 6. Access Your Site

- **Web Interface**: http://development.localhost:8000
- **Username**: `Administrator`
- **Password**: `admin` (default)

## Configuration Files

### `.devcontainer/devcontainer.json`

The main Dev Container configuration file:

```json
{
  "name": "Frappe Bench",
  "forwardPorts": [8000, 9000, 6787],
  "remoteUser": "frappe",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-vscode.live-server",
        "grapecity.gc-excelviewer",
        "mtxr.sqltools",
        "mtxr.sqltools-driver-mysql",
        "visualstudioexptteam.vscodeintellicode"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "frappe bash",
        "sqltools.connections": [
          {
            "server": "mariadb",
            "port": 3306,
            "driver": "MariaDB",
            "name": "MariaDB",
            "username": "root",
            "password": "123"
          }
        ]
      }
    }
  },
  "dockerComposeFile": "./docker-compose.yml",
  "service": "frappe",
  "workspaceFolder": "/workspace/development",
  "shutdownAction": "stopCompose",
  "mounts": [
    "source=${localEnv:HOME}${localEnv:USERPROFILE}/.ssh,target=/home/frappe/.ssh,type=bind,consistency=cached"
  ]
}
```

#### Key Settings Explained

| Setting | Description |
|---------|-------------|
| `forwardPorts` | Ports exposed to the host (8000=web, 9000=socketio, 6787=debugger) |
| `remoteUser` | Container user (`frappe` - non-root) |
| `workspaceFolder` | Default directory when opening terminal |
| `shutdownAction` | Stops all services when closing VS Code |
| `mounts` | Mounts SSH keys for git operations |

### `.devcontainer/docker-compose.yml`

Defines all services for the development environment:

```yaml
services:
  mariadb:
    image: docker.io/mariadb:11.8
    command:
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_unicode_ci
      - --skip-character-set-client-handshake
      - --skip-innodb-read-only-compressed
    environment:
      MYSQL_ROOT_PASSWORD: 123
      MARIADB_AUTO_UPGRADE: 1
    volumes:
      - mariadb-data:/var/lib/mysql

  redis-cache:
    image: docker.io/redis:alpine

  redis-queue:
    image: docker.io/redis:alpine

  frappe:
    image: docker.io/frappe/bench:latest
    command: sleep infinity
    environment:
      - SHELL=/bin/bash
    volumes:
      - ..:/workspace:cached
    working_dir: /workspace/development
    ports:
      - 8000-8005:8000-8005
      - 9000-9005:9000-9005

volumes:
  mariadb-data:
```

## Services

### Core Services

| Service | Image | Purpose | Default Port |
|---------|-------|---------|--------------|
| `frappe` | `frappe/bench:latest` | Development container | 8000-8005, 9000-9005 |
| `mariadb` | `mariadb:11.8` | Primary database | 3306 |
| `redis-cache` | `redis:alpine` | Caching | 6379 |
| `redis-queue` | `redis:alpine` | Background job queue | 6379 |

### Optional Services

| Service | Image | Purpose | Default Port |
|---------|-------|---------|--------------|
| `postgresql` | `postgres:14` | Alternative database | 5432 |
| `mailpit` | `axllent/mailpit` | Email testing | 8025 (web), 1025 (SMTP) |
| `ui-tester` | `cypress/included:latest` | UI testing with Cypress | - |

## Development Workflow

### Manual Bench Setup

#### 1. Initialize Bench

```bash
# For Frappe v15 (default)
bench init --skip-redis-config-generation frappe-bench
cd frappe-bench

# For Frappe v14
nvm use v16
PYENV_VERSION=3.10.13 bench init --skip-redis-config-generation --frappe-branch version-14 frappe-bench
cd frappe-bench

# For Frappe v13
nvm use v14
PYENV_VERSION=3.9.17 bench init --skip-redis-config-generation --frappe-branch version-13 frappe-bench
cd frappe-bench
```

#### 2. Configure Service Hosts

```bash
bench set-config -g db_host mariadb
bench set-config -g redis_cache redis://redis-cache:6379
bench set-config -g redis_queue redis://redis-queue:6379
bench set-config -g redis_socketio redis://redis-queue:6379
```

#### 3. Create a New Site

```bash
# Interactive (will prompt for password)
bench new-site --mariadb-user-host-login-scope=% development.localhost

# Non-interactive
bench new-site --db-root-password 123 --admin-password admin --mariadb-user-host-login-scope=% development.localhost
```

#### 4. Enable Developer Mode

```bash
bench --site development.localhost set-config developer_mode 1
bench --site development.localhost clear-cache
```

#### 5. Install Apps

```bash
# Install ERPNext v15
bench get-app --branch version-15 --resolve-deps erpnext
bench --site development.localhost install-app erpnext

# Install custom app
bench get-app --branch main https://github.com/username/custom_app
bench --site development.localhost install-app custom_app
```

#### 6. Start Development Server

```bash
bench start
```

## Automated Setup with installer.py

The `installer.py` script automates the entire setup process.

### Basic Usage

```bash
cd /workspace/development
python installer.py
```

### Command Line Options

```bash
python installer.py --help

Options:
  -j, --apps-json       Path to apps.json (default: apps-example.json)
  -b, --bench-name      Bench directory name (default: frappe-bench)
  -s, --site-name       Site name (default: development.localhost)
  -r, --frappe-repo     Frappe repository URL
  -t, --frappe-branch   Frappe branch (default: version-15)
  -p, --py-version      Python version
  -n, --node-version    Node.js version
  -v, --verbose         Enable verbose output
  -a, --admin-password  Admin password (default: admin)
  -d, --db-type         Database type: mariadb or postgres (default: mariadb)
```

### Examples

```bash
# Use PostgreSQL instead of MariaDB
python installer.py --db-type postgres

# Install specific Frappe version with custom apps
python installer.py -j apps.json -t version-14 -p 3.10.13 -n 16

# Custom site name and admin password
python installer.py -s mysite.localhost -a mysecurepassword
```

### Custom Apps Configuration

Create a custom `apps.json` file:

```json
[
  {
    "url": "https://github.com/frappe/erpnext",
    "branch": "version-15"
  },
  {
    "url": "https://github.com/frappe/hrms",
    "branch": "version-15"
  },
  {
    "url": "https://github.com/myorg/custom_app",
    "branch": "main"
  }
]
```

Then run:

```bash
python installer.py -j apps.json
```

## VS Code Integration

### Pre-installed Extensions

The Dev Container automatically installs these extensions:

| Extension | Purpose |
|-----------|---------|
| `ms-python.python` | Python language support |
| `ms-vscode.live-server` | Live reload for web development |
| `grapecity.gc-excelviewer` | Excel file viewer |
| `mtxr.sqltools` | Database management |
| `mtxr.sqltools-driver-mysql` | MariaDB/MySQL driver |
| `visualstudioexptteam.vscodeintellicode` | AI-assisted coding |

### Database Connection

SQLTools is pre-configured to connect to MariaDB:

- **Server**: `mariadb`
- **Port**: `3306`
- **Username**: `root`
- **Password**: `123`

## Debugging

### VS Code Launch Configurations

The `development/.vscode/launch.json` provides several debug configurations:

#### Bench Web (Main Application)

Debug the Frappe web server with breakpoints:

1. Start supporting services:
   ```bash
   honcho start socketio watch schedule worker
   ```

2. Press `F5` or click "Run and Debug" → "Bench Web"

#### Bench Workers

Debug background workers:

- **Bench Short Worker**: Short-running jobs
- **Bench Default Worker**: Default queue jobs
- **Bench Long Worker**: Long-running jobs

#### Compound Configuration

**"Honcho + Web debug"**: Starts both Honcho services and the web debugger together.

### Debugging Steps

1. Set breakpoints in your Python code
2. Start Honcho for supporting services:
   ```bash
   cd frappe-bench
   honcho start socketio watch schedule worker
   ```
3. Select "Bench Web" from the debug dropdown
4. Press F5 to start debugging
5. Access http://development.localhost:8000
6. Execution will pause at breakpoints

### Interactive Console

```bash
# Simple console
bench --site development.localhost console

# Jupyter-based console in VS Code
# 1. Select Python interpreter: /workspace/development/frappe-bench/env/bin/python
# 2. Run: Python: Show Python interactive window
```

## Database Options

### MariaDB (Default)

Already configured by default. No additional steps needed.

### PostgreSQL

1. Edit `.devcontainer/docker-compose.yml`:

```yaml
services:
  # Comment out mariadb section if not needed
  # mariadb:
  #   ...

  postgresql:
    image: postgres:14
    environment:
      POSTGRES_PASSWORD: 123
    volumes:
      - postgresql-data:/var/lib/postgresql/data

volumes:
  postgresql-data:
```

2. Rebuild the container

3. Create site with PostgreSQL:
   ```bash
   bench new-site --db-type postgres --db-host postgresql mysite.localhost
   ```

4. Or use the installer:
   ```bash
   python installer.py --db-type postgres
   ```

## Optional Services

### Mailpit (Email Testing)

Mailpit captures all outgoing emails for testing.

1. Uncomment in `.devcontainer/docker-compose.yml`:

```yaml
mailpit:
  image: axllent/mailpit
  volumes:
    - mailpit-data:/data
  ports:
    - 8025:8025
    - 1025:1025
  environment:
    MP_MAX_MESSAGES: 5000
    MP_DATA_FILE: /data/mailpit.db
    MP_SMTP_AUTH_ACCEPT_ANY: 1
    MP_SMTP_AUTH_ALLOW_INSECURE: 1
```

2. Configure Frappe to use Mailpit:
   ```bash
   bench --site development.localhost set-config mail_server mailpit
   bench --site development.localhost set-config mail_port 1025
   bench --site development.localhost set-config disable_mail_smtp_authentication 1
   ```

3. Access Mailpit UI: http://localhost:8025

### Cypress UI Testing

For running end-to-end UI tests:

1. Run the X11 setup script on your host:
   ```bash
   sudo bash ./install_x11_deps.sh
   ```

2. Uncomment the `ui-tester` service in `docker-compose.yml`

3. Rebuild and enter the container

4. Run Cypress tests:
   ```bash
   docker exec -it <ui-tester-container> bash
   export CYPRESS_baseUrl=http://frappe:8000
   cypress run
   ```

## Troubleshooting

### Common Issues

#### Container Won't Start

```bash
# Check Docker status
docker ps -a
docker logs <container-name>

# Rebuild container
# In VS Code: Dev Containers: Rebuild Container
```

#### Permission Denied Errors

```bash
# Inside container, ensure you're the frappe user
whoami  # Should output: frappe

# Fix permissions if needed
sudo chown -R frappe:frappe /workspace/development
```

#### Database Connection Failed

```bash
# Check if MariaDB is running
docker ps | grep mariadb

# Test connection
mysql -h mariadb -u root -p123 -e "SELECT 1"

# Check common_site_config.json
cat frappe-bench/sites/common_site_config.json
```

#### Redis Connection Issues

```bash
# Test Redis connectivity
redis-cli -h redis-cache ping
redis-cli -h redis-queue ping
```

#### Site Not Accessible

```bash
# Check if bench is running
bench start

# Verify site exists
ls frappe-bench/sites/

# Check hosts file (on host machine)
# Add: 127.0.0.1 development.localhost
```

#### "Node/Python version mismatch"

```bash
# Check available versions
nvm ls
pyenv versions

# Switch versions
nvm use v18
PYENV_VERSION=3.11.0 bench init ...
```

### Resetting the Environment

```bash
# Remove bench directory (keeps database)
rm -rf frappe-bench

# Full reset (removes database data too)
# On host machine:
docker compose -f .devcontainer/docker-compose.yml down -v
```

## Best Practices

### Git Configuration

Your SSH keys are mounted automatically. Ensure git is configured:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Multiple Sites

Create multiple sites for different projects:

```bash
bench new-site --mariadb-user-host-login-scope=% project1.localhost
bench new-site --mariadb-user-host-login-scope=% project2.localhost

# Switch between sites
bench use project1.localhost
```

### Keeping Data Persistent

The following are persisted between container rebuilds:
- Database data (Docker volumes)
- `/workspace/development` directory
- SSH keys (mounted from host)

### Performance Tips

1. **Allocate sufficient RAM** to Docker (4GB minimum, 8GB recommended)
2. **Use WSL2** on Windows for better performance
3. **Exclude node_modules** from file watching if slow:
   ```json
   // .vscode/settings.json
   {
     "files.watcherExclude": {
       "**/node_modules/**": true
     }
   }
   ```

### Security Notes

- Default passwords (`123`, `admin`) are for development only
- Never use these defaults in production
- SSH keys are mounted read-only for security

## Additional Resources

- [Frappe Framework Documentation](https://frappeframework.com/docs)
- [ERPNext Documentation](https://docs.erpnext.com)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Docker Documentation](https://docs.docker.com)
