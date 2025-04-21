# Ubuntu Configuration Backup

This directory contains a backup of your Ubuntu system configurations and installed packages.

## Contents

- `shell_configs/`: Shell configuration files (.zshrc, .bashrc, etc.)
- `packages/`: Lists of installed packages and repository sources
- `vscode/`: VSCode settings and extension list
- `ssh/`: SSH configuration (excluding private keys)
- `git/`: Git configuration
- `cron/`: Crontab entries
- `desktop/`: Desktop environment settings
- `browsers/`: Browser bookmarks

## Restoration

A `restore.sh` script is included to help you restore these configurations.
Run it from within this backup directory:

```
chmod +x restore.sh
./restore.sh
```

Note: The restore script will overwrite existing configurations.
