#!/bin/bash
echo "🌱 Starting restoration process..."
read -p "This may overwrite existing configs. Continue? (y/n): " confirm
[ "$confirm" != "y" ] && echo "❌ Cancelled." && exit 1

echo "⚙️ Restoring shell configurations..."
cp -v shell_configs/.*rc "$HOME/" 2>/dev/null

echo "⚙️ Restoring package selections..."
sudo dpkg --set-selections < packages/dpkg-selections.txt
sudo apt-get update && sudo apt-get dselect-upgrade -y

echo "⚙️ Restoring VSCode settings..."
mkdir -p "$HOME/.config/Code/User/"
cp -v vscode/*.json "$HOME/.config/Code/User/" 2>/dev/null
if [ -f vscode/extensions.txt ]; then
  cat vscode/extensions.txt | xargs -L 1 code --install-extension
fi

echo "⚙️ Restoring Cursor settings..."
mkdir -p "$HOME/.config/Cursor/User/"
cp -v cursor/*.json "$HOME/.config/Cursor/User/" 2>/dev/null
if [ -f cursor/extensions.txt ]; then
  cat cursor/extensions.txt | xargs -L 1 cursor --install-extension
fi

echo "⚙️ Restoring Git configs..."
cp -v git/* "$HOME/" 2>/dev/null

if [ -f cron/crontab ]; then
  echo "⚙️ Restoring cron jobs..."
  crontab cron/crontab
fi

if [ -f desktop/dconf-settings ]; then
  echo "⚙️ Restoring desktop environment..."
  dconf load / < desktop/dconf-settings
fi

echo "✅ Restoration complete! Please restart your system."
