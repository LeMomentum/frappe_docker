# Laptop Migration Guide: Backup & Restore Your Frappe Development Environment

This guide walks you through backing up your complete Frappe development environment from one laptop and restoring it on a new one.

## Table of Contents

- [Overview](#overview)
- [What Gets Migrated](#what-gets-migrated)
- [Part 1: Backup on Old Laptop](#part-1-backup-on-old-laptop)
- [Part 2: Setup on New Laptop](#part-2-setup-on-new-laptop)
- [Part 3: Restore Your Environment](#part-3-restore-your-environment)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Overview

Your Frappe development environment consists of:

```
frappe_docker/
├── .devcontainer/          # Dev container config (in git, but needs to be copied)
├── development/
│   ├── frappe-bench/       # ⚠️ NOT in git - needs backup!
│   │   ├── apps/           # Installed applications
│   │   ├── sites/          # Site data, database backups
│   │   └── ...
│   └── .vscode/            # VS Code settings (needs to be copied)
└── ...
```

## What Gets Migrated

| Component | Method | Notes |
|-----------|--------|-------|
| Repository code | Git clone | Your fork + branches |
| Site database | Backup file | Contains all your data |
| Uploaded files | Backup file | Public & private files |
| Installed apps | Reinstall | From apps.json or manual |
| Site configuration | Backup file | site_config.json |
| VS Code settings | Copy | .vscode folder |

---

## Part 1: Backup on Old Laptop

### Step 1: Create Site Backup

Inside your dev container terminal:

```bash
cd /workspace/development/frappe-bench

# Create full backup with all files
bench --site development.localhost backup --with-files
```

This creates 4 files in `sites/development.localhost/private/backups/`:
- `*-database.sql.gz` - Database dump
- `*-files.tar` - Public files
- `*-private-files.tar` - Private files
- `*-site_config_backup.json` - Site configuration

### Step 2: Note Your Installed Apps

Check what apps you have installed:

```bash
# List apps in bench
ls apps/

# Get detailed app info
cat sites/apps.json
```

**Your current apps:**
| App | Repository | Branch |
|-----|------------|--------|
| frappe | https://github.com/frappe/frappe | version-15 |
| crm | https://github.com/frappe/crm.git | main |
| frappe_whatsapp | https://github.com/shridarpatil/frappe_whatsapp | master |
| mail | https://github.com/frappe/mail.git | develop |
| vooroo_saas | https://github.com/LeMomentum/vooroo_saas.git | develop |

### Step 3: Copy Backup Files to Safe Location

**Option A: Copy to USB/External Drive**

On your **host machine** (not inside container), find the backup files:

```bash
# macOS/Linux - find your Docker volume or mounted path
cd ~/path/to/frappe_docker/development/frappe-bench/sites/development.localhost/private/backups/

# Copy all backup files
cp -r . /path/to/usb/frappe-backup/
```

**Option B: Upload to Cloud Storage**

```bash
# Inside container - create a single archive
cd /workspace/development/frappe-bench/sites/development.localhost/private/backups/

# Create migration bundle
tar -czvf migration-backup.tar.gz \
  *-database.sql.gz \
  *-files.tar \
  *-private-files.tar \
  *-site_config_backup.json
```

Then copy `migration-backup.tar.gz` to Google Drive, Dropbox, etc.

**Option C: SCP to New Laptop (if both on same network)**

```bash
scp migration-backup.tar.gz user@new-laptop:/tmp/
```

### Step 4: Push Any Uncommitted Work

```bash
cd /workspace

# Check for uncommitted changes
git status

# Commit and push if needed
git add .
git commit -m "WIP: Save work before laptop migration"
git push myfork dev-container
```

### Step 5: Document Custom Configurations

Save any custom configurations you've made:

```bash
# Export common_site_config.json
cat sites/common_site_config.json > ~/frappe-backup/common_site_config.json

# Export any custom Procfile changes
cat Procfile > ~/frappe-backup/Procfile

# List installed pip packages (for reference)
./env/bin/pip freeze > ~/frappe-backup/requirements.txt
```

---

## Part 2: Setup on New Laptop

### Step 1: Install Prerequisites

#### Docker Desktop (macOS/Windows)

1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Install and start Docker
3. **Allocate at least 4GB RAM** in Settings → Resources

#### Docker Engine (Linux)

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in
```

#### VS Code + Dev Containers Extension

```bash
# Install VS Code, then:
code --install-extension ms-vscode-remote.remote-containers
```

#### Git

```bash
# macOS
brew install git

# Ubuntu/Debian
sudo apt install git

# Windows - download from git-scm.com
```

### Step 2: Clone Your Fork

```bash
git clone https://github.com/LeMomentum/frappe_docker.git
cd frappe_docker

# Checkout your working branch
git checkout dev-container

# Add upstream for future updates
git remote add upstream https://github.com/frappe/frappe_docker.git
```

### Step 3: Setup Dev Container Configuration

```bash
# Copy devcontainer config
cp -R devcontainer-example .devcontainer

# Copy VS Code settings
cp -R development/vscode-example development/.vscode
```

### Step 4: Copy Backup Files

Copy your backup files to the new laptop:

```bash
# Create a temp location for backups
mkdir -p ~/frappe-migration-backup

# Copy from USB, cloud, or wherever you stored them
cp /path/to/backup/* ~/frappe-migration-backup/

# Or extract if you created a tar archive
tar -xzvf migration-backup.tar.gz -C ~/frappe-migration-backup/
```

### Step 5: Open in Dev Container

```bash
code .
```

In VS Code:
1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
2. Type "Dev Containers: Reopen in Container"
3. Wait for container to build (first time takes a few minutes)

---

## Part 3: Restore Your Environment

All following commands run **inside the dev container**.

### Step 1: Initialize Bench

```bash
cd /workspace/development

# Initialize bench with Frappe v15
bench init --skip-redis-config-generation frappe-bench
cd frappe-bench
```

### Step 2: Configure Services

```bash
bench set-config -g db_host mariadb
bench set-config -g redis_cache redis://redis-cache:6379
bench set-config -g redis_queue redis://redis-queue:6379
bench set-config -g redis_socketio redis://redis-queue:6379
```

### Step 3: Install Your Apps

```bash
# Install CRM
bench get-app --branch main https://github.com/frappe/crm.git

# Install Frappe WhatsApp
bench get-app --branch master https://github.com/shridarpatil/frappe_whatsapp

# Install Mail
bench get-app --branch develop https://github.com/frappe/mail.git

# Install your custom app
bench get-app --branch develop https://github.com/LeMomentum/vooroo_saas.git
```

### Step 4: Create New Site

```bash
bench new-site --db-root-password 123 --admin-password admin --mariadb-user-host-login-scope=% development.localhost
```

### Step 5: Copy Backup Files into Container

The backup files need to be accessible inside the container. They should be placed in a location the container can access.

**From host machine terminal (not container):**

```bash
# Copy backups to the development folder (which is mounted in container)
cp ~/frappe-migration-backup/* ~/path/to/frappe_docker/development/
```

### Step 6: Restore Database and Files

**Inside the container:**

```bash
cd /workspace/development/frappe-bench

# Find your backup files
ls /workspace/development/*.sql.gz
ls /workspace/development/*.tar

# Restore the site (adjust filenames to match your backup)
bench --site development.localhost restore \
  /workspace/development/20260203_235953-development_localhost-database.sql.gz \
  --db-root-password 123 \
  --admin-password admin

# Restore public files
bench --site development.localhost restore-files \
  /workspace/development/20260203_235953-development_localhost-files.tar

# Restore private files
bench --site development.localhost restore-private-files \
  /workspace/development/20260203_235953-development_localhost-private-files.tar
```

### Step 7: Install Apps on Site

```bash
bench --site development.localhost install-app crm
bench --site development.localhost install-app frappe_whatsapp
bench --site development.localhost install-app mail
bench --site development.localhost install-app vooroo_saas
```

### Step 8: Run Migrations

```bash
bench --site development.localhost migrate
```

### Step 9: Enable Developer Mode

```bash
bench --site development.localhost set-config developer_mode 1
bench --site development.localhost clear-cache
```

### Step 10: Build Assets

```bash
bench build
```

---

## Verification

### Start the Development Server

```bash
bench start
```

### Check Everything Works

1. Open http://development.localhost:8000
2. Login with `Administrator` / your password
3. Verify your data is present
4. Test key functionality

### Verify Apps

```bash
bench --site development.localhost list-apps
```

Expected output:
```
frappe
crm
frappe_whatsapp
mail
vooroo_saas
```

---

## Troubleshooting

### "Site does not exist" Error

```bash
# Check if site directory exists
ls sites/

# If not, create site first before restoring
bench new-site --db-root-password 123 --mariadb-user-host-login-scope=% development.localhost
```

### Database Connection Failed

```bash
# Verify MariaDB is running
docker ps | grep mariadb

# Test connection
mysql -h mariadb -u root -p123 -e "SHOW DATABASES;"

# Check configuration
cat sites/common_site_config.json
```

### "App not installed" After Restore

The database has app records but the apps aren't installed in the bench:

```bash
# Get the app first
bench get-app <app-name>

# Then install on site
bench --site development.localhost install-app <app-name>
```

### Permission Errors

```bash
# Fix ownership
sudo chown -R frappe:frappe /workspace/development/frappe-bench
```

### Redis Connection Issues

```bash
# Verify Redis containers are running
docker ps | grep redis

# Test connection
redis-cli -h redis-cache ping
redis-cli -h redis-queue ping
```

### Missing Node Modules

```bash
cd /workspace/development/frappe-bench
bench setup requirements
yarn install
bench build
```

### Python Package Issues

```bash
cd /workspace/development/frappe-bench
./env/bin/pip install -e apps/frappe
./env/bin/pip install -e apps/crm
# Repeat for each app
```

---

## Quick Reference: Complete Migration Commands

### On Old Laptop (inside container)

```bash
# 1. Backup
cd /workspace/development/frappe-bench
bench --site development.localhost backup --with-files

# 2. Push code
cd /workspace
git add . && git commit -m "Pre-migration save" && git push myfork dev-container
```

### On New Laptop

```bash
# 1. Clone and setup
git clone https://github.com/LeMomentum/frappe_docker.git
cd frappe_docker && git checkout dev-container
cp -R devcontainer-example .devcontainer
cp -R development/vscode-example development/.vscode

# 2. Open in VS Code and "Reopen in Container"

# 3. Inside container - initialize
cd /workspace/development
bench init --skip-redis-config-generation frappe-bench
cd frappe-bench

# 4. Configure
bench set-config -g db_host mariadb
bench set-config -g redis_cache redis://redis-cache:6379
bench set-config -g redis_queue redis://redis-queue:6379
bench set-config -g redis_socketio redis://redis-queue:6379

# 5. Install apps
bench get-app --branch main https://github.com/frappe/crm.git
bench get-app --branch master https://github.com/shridarpatil/frappe_whatsapp
bench get-app --branch develop https://github.com/frappe/mail.git
bench get-app --branch develop https://github.com/LeMomentum/vooroo_saas.git

# 6. Create and restore site
bench new-site --db-root-password 123 --admin-password admin --mariadb-user-host-login-scope=% development.localhost

# 7. Restore (adjust filenames)
bench --site development.localhost restore /workspace/development/BACKUP-database.sql.gz --db-root-password 123
bench --site development.localhost restore-files /workspace/development/BACKUP-files.tar
bench --site development.localhost restore-private-files /workspace/development/BACKUP-private-files.tar

# 8. Install apps on site
bench --site development.localhost install-app crm
bench --site development.localhost install-app frappe_whatsapp  
bench --site development.localhost install-app mail
bench --site development.localhost install-app vooroo_saas

# 9. Finalize
bench --site development.localhost migrate
bench --site development.localhost set-config developer_mode 1
bench build
bench start
```

---

## Backup Location Reference

Your backup files are located at:

```
/workspace/development/frappe-bench/sites/development.localhost/private/backups/
```

**Current backup files:**
- `20260203_235953-development_localhost-database.sql.gz` (623 KB)
- `20260203_235953-development_localhost-files.tar` (50 KB)
- `20260203_235953-development_localhost-private-files.tar` (10 KB)
- `20260203_235953-development_localhost-site_config_backup.json` (206 B)

**Copy these files to your new laptop before proceeding!**
