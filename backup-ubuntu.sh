#!/bin/bash

# Create a backup directory
BACKUP_DIR="$HOME/Desktop/SAWASH/Ubuntu"
mkdir -p $BACKUP_DIR

echo "Creating Ubuntu backup in $BACKUP_DIR..."

# 1. Shell and user config files
echo "Backing up shell and user config files..."
mkdir -p $BACKUP_DIR/shell_configs
cp -v $HOME/.zshrc $BACKUP_DIR/shell_configs/ 2>/dev/null
cp -v $HOME/.bashrc $BACKUP_DIR/shell_configs/ 2>/dev/null
cp -v $HOME/.profile $BACKUP_DIR/shell_configs/ 2>/dev/null
cp -v $HOME/.bash_profile $BACKUP_DIR/shell_configs/ 2>/dev/null
cp -v $HOME/.bash_aliases $BACKUP_DIR/shell_configs/ 2>/dev/null
cp -vr $HOME/.oh-my-zsh $BACKUP_DIR/shell_configs/ 2>/dev/null

# 2. Package lists
echo "Backing up package lists..."
mkdir -p $BACKUP_DIR/packages
# Installed packages
dpkg --get-selections > $BACKUP_DIR/packages/dpkg-selections.txt
# APT sources
cp -v /etc/apt/sources.list $BACKUP_DIR/packages/ 2>/dev/null
cp -vr /etc/apt/sources.list.d $BACKUP_DIR/packages/ 2>/dev/null
# Snap packages
snap list > $BACKUP_DIR/packages/snap-list.txt 2>/dev/null
# Flatpak packages (if installed)
which flatpak >/dev/null && flatpak list --columns=application > $BACKUP_DIR/packages/flatpak-list.txt 2>/dev/null

# 3. VSCode configurations
echo "Backing up VSCode configurations..."
mkdir -p $BACKUP_DIR/vscode
cp -vr $HOME/.config/Code/User/settings.json $BACKUP_DIR/vscode/ 2>/dev/null
cp -vr $HOME/.config/Code/User/keybindings.json $BACKUP_DIR/vscode/ 2>/dev/null
# Get VSCode extension list
which code >/dev/null && code --list-extensions > $BACKUP_DIR/vscode/extensions.txt 2>/dev/null

# 4. SSH keys and config
echo "Backing up SSH configurations..."
mkdir -p $BACKUP_DIR/ssh
cp -vr $HOME/.ssh/config $BACKUP_DIR/ssh/ 2>/dev/null
# Note: For security, we're NOT backing up the actual SSH keys
# You should transfer those securely if needed

# 5. Git configurations
echo "Backing up Git configurations..."
mkdir -p $BACKUP_DIR/git
cp -v $HOME/.gitconfig $BACKUP_DIR/git/ 2>/dev/null
cp -v $HOME/.gitignore_global $BACKUP_DIR/git/ 2>/dev/null

# 6. Cron jobs
echo "Backing up cron jobs..."
mkdir -p $BACKUP_DIR/cron
crontab -l > $BACKUP_DIR/cron/crontab 2>/dev/null

# 7. Desktop configurations (if using GUI)
echo "Backing up desktop configurations..."
mkdir -p $BACKUP_DIR/desktop
# GNOME settings
if which dconf > /dev/null; then
    dconf dump / > $BACKUP_DIR/desktop/dconf-settings 2>/dev/null
fi
# Copy desktop configuration folders
cp -vr $HOME/.config/gtk-3.0 $BACKUP_DIR/desktop/ 2>/dev/null
cp -vr $HOME/.themes $BACKUP_DIR/desktop/ 2>/dev/null
cp -vr $HOME/.icons $BACKUP_DIR/desktop/ 2>/dev/null

# 8. Favorite applications
echo "Creating list of installed applications..."
ls /usr/share/applications/*.desktop > $BACKUP_DIR/desktop/available-applications.txt 2>/dev/null

# 9. Browser bookmarks
echo "Backing up browser data..."
mkdir -p $BACKUP_DIR/browsers
# Firefox (if installed)
cp -vr $HOME/.mozilla/firefox/*.default*/bookmarks*.* $BACKUP_DIR/browsers/ 2>/dev/null
# Chrome/Chromium (if installed)
cp -vr $HOME/.config/google-chrome/Default/Bookmarks $BACKUP_DIR/browsers/ 2>/dev/null
cp -vr $HOME/.config/chromium/Default/Bookmarks $BACKUP_DIR/browsers/ 2>/dev/null

# 10. Create a restore script
echo "Creating restore script..."
cat > $BACKUP_DIR/restore.sh << 'EOL'
#!/bin/bash
# This script helps restore your backed up configurations
# Run it from within your backup directory

echo "This script will help you restore your Ubuntu configurations"
echo "WARNING: This may overwrite existing configurations"
read -p "Continue? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Restoration cancelled."
    exit 1
fi

# Restore shell configs
echo "Restoring shell configurations..."
cp -v shell_configs/.zshrc $HOME/ 2>/dev/null
cp -v shell_configs/.bashrc $HOME/ 2>/dev/null
cp -v shell_configs/.profile $HOME/ 2>/dev/null
cp -v shell_configs/.bash_profile $HOME/ 2>/dev/null
cp -v shell_configs/.bash_aliases $HOME/ 2>/dev/null

# Restore packages
echo "Restoring package selections (this may take time)..."
sudo dpkg --set-selections < packages/dpkg-selections.txt
sudo apt-get update
sudo apt-get dselect-upgrade

# For VSCode extensions
if [ -f vscode/extensions.txt ] && which code > /dev/null; then
    echo "Reinstalling VSCode extensions..."
    cat vscode/extensions.txt | xargs -L 1 code --install-extension
fi

# Restore VSCode settings
echo "Restoring VSCode settings..."
mkdir -p $HOME/.config/Code/User/
cp -v vscode/settings.json $HOME/.config/Code/User/ 2>/dev/null
cp -v vscode/keybindings.json $HOME/.config/Code/User/ 2>/dev/null

# Restore Git config
echo "Restoring Git configurations..."
cp -v git/.gitconfig $HOME/ 2>/dev/null
cp -v git/.gitignore_global $HOME/ 2>/dev/null

# Restore crontab
if [ -f cron/crontab ]; then
    echo "Restoring cron jobs..."
    crontab cron/crontab
fi

# Restore desktop settings
if [ -f desktop/dconf-settings ]; then
    echo "Restoring desktop settings..."
    dconf load / < desktop/dconf-settings
fi

echo "Restoration completed!"
echo "Some changes may require logging out and back in or restarting applications."
EOL

chmod +x $BACKUP_DIR/restore.sh

# Create a README file
echo "Creating README..."
cat > $BACKUP_DIR/README.md << 'EOL'
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
EOL

# Create a .gitignore file
echo "Creating .gitignore..."
cat > $BACKUP_DIR/.gitignore << 'EOL'
# Ignore potentially sensitive files
.ssh/id_*
.ssh/*.pem
.gnupg/
EOL

echo "Backup completed! Your configurations are stored in $BACKUP_DIR"
echo "You can now initialize a git repository in this directory and push it to GitHub:"
