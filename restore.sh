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
