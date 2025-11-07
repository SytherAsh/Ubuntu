#!/bin/bash
# ========================================================
# 🌱 Ubuntu Backup Script (with VSCode + Cursor Support)
# ========================================================

# --- Colors and Icons ---
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color
CHECK="${GREEN}✅${NC}"
GEAR="${YELLOW}⚙️${NC}"
WARN="${YELLOW}⚠️${NC}"
CROSS="${RED}❌${NC}"

# --- Backup Directory ---
BACKUP_DIR="$HOME/Desktop/SAWASH/Ubuntu"
mkdir -p "$BACKUP_DIR"
echo -e "${CYAN}🌍 Creating Ubuntu backup at:${NC} $BACKUP_DIR"

# ========================================================
# 1️⃣ Shell and User Configs
# ========================================================
echo -e "\n${GEAR} Backing up shell and user configuration files..."
mkdir -p "$BACKUP_DIR/shell_configs"
for file in .zshrc .bashrc .profile .bash_profile .bash_aliases; do
  [ -f "$HOME/$file" ] && cp -v "$HOME/$file" "$BACKUP_DIR/shell_configs/"
done
[ -d "$HOME/.oh-my-zsh" ] && cp -vr "$HOME/.oh-my-zsh" "$BACKUP_DIR/shell_configs/"
echo -e "${CHECK} Shell configuration backup completed."

# ========================================================
# 2️⃣ Package Lists
# ========================================================
echo -e "\n${GEAR} Backing up installed packages and sources..."
mkdir -p "$BACKUP_DIR/packages"
dpkg --get-selections > "$BACKUP_DIR/packages/dpkg-selections.txt"
cp -v /etc/apt/sources.list "$BACKUP_DIR/packages/" 2>/dev/null
cp -vr /etc/apt/sources.list.d "$BACKUP_DIR/packages/" 2>/dev/null
snap list > "$BACKUP_DIR/packages/snap-list.txt" 2>/dev/null
which flatpak >/dev/null && flatpak list --columns=application > "$BACKUP_DIR/packages/flatpak-list.txt"
echo -e "${CHECK} Package list backup completed."

# ========================================================
# 3️⃣ VSCode & Cursor Configs
# ========================================================
echo -e "\n${GEAR} Backing up VSCode & Cursor configurations..."
mkdir -p "$BACKUP_DIR/vscode" "$BACKUP_DIR/cursor"

# VSCode
if [ -d "$HOME/.config/Code/User" ]; then
  cp -vr "$HOME/.config/Code/User/settings.json" "$BACKUP_DIR/vscode/" 2>/dev/null
  cp -vr "$HOME/.config/Code/User/keybindings.json" "$BACKUP_DIR/vscode/" 2>/dev/null
  which code >/dev/null && code --list-extensions > "$BACKUP_DIR/vscode/extensions.txt"
fi

# Cursor
if [ -d "$HOME/.config/Cursor/User" ]; then
  cp -vr "$HOME/.config/Cursor/User/settings.json" "$BACKUP_DIR/cursor/" 2>/dev/null
  cp -vr "$HOME/.config/Cursor/User/keybindings.json" "$BACKUP_DIR/cursor/" 2>/dev/null
  which cursor >/dev/null && cursor --list-extensions > "$BACKUP_DIR/cursor/extensions.txt" 2>/dev/null
fi
echo -e "${CHECK} VSCode & Cursor configuration backup completed."

# ========================================================
# 4️⃣ SSH Configs
# ========================================================
echo -e "\n${GEAR} Backing up SSH configuration (excluding private keys)..."
mkdir -p "$BACKUP_DIR/ssh"
cp -vr "$HOME/.ssh/config" "$BACKUP_DIR/ssh/" 2>/dev/null
echo -e "${CHECK} SSH backup done."

# ========================================================
# 5️⃣ Git Config
# ========================================================
echo -e "\n${GEAR} Backing up Git configuration..."
mkdir -p "$BACKUP_DIR/git"
cp -v "$HOME/.gitconfig" "$BACKUP_DIR/git/" 2>/dev/null
cp -v "$HOME/.gitignore_global" "$BACKUP_DIR/git/" 2>/dev/null
echo -e "${CHECK} Git config backup completed."

# ========================================================
# 6️⃣ Cron Jobs
# ========================================================
echo -e "\n${GEAR} Backing up cron jobs..."
mkdir -p "$BACKUP_DIR/cron"
crontab -l > "$BACKUP_DIR/cron/crontab" 2>/dev/null
echo -e "${CHECK} Cron jobs backup completed."

# ========================================================
# 7️⃣ Desktop Config
# ========================================================
echo -e "\n${GEAR} Backing up desktop and theme settings..."
mkdir -p "$BACKUP_DIR/desktop"
if which dconf > /dev/null; then
    dconf dump / > "$BACKUP_DIR/desktop/dconf-settings" 2>/dev/null
fi
for folder in gtk-3.0 .themes .icons; do
  [ -d "$HOME/.config/$folder" ] && cp -vr "$HOME/.config/$folder" "$BACKUP_DIR/desktop/" 2>/dev/null
  [ -d "$HOME/$folder" ] && cp -vr "$HOME/$folder" "$BACKUP_DIR/desktop/" 2>/dev/null
done
ls /usr/share/applications/*.desktop > "$BACKUP_DIR/desktop/available-applications.txt" 2>/dev/null
echo -e "${CHECK} Desktop configuration backup completed."

# ========================================================
# 8️⃣ Browser Data
# ========================================================
echo -e "\n${GEAR} Backing up browser bookmarks..."
mkdir -p "$BACKUP_DIR/browsers"
cp -vr "$HOME/.mozilla/firefox/"*.default*/bookmarks*.* "$BACKUP_DIR/browsers/" 2>/dev/null
cp -vr "$HOME/.config/google-chrome/Default/Bookmarks" "$BACKUP_DIR/browsers/" 2>/dev/null
cp -vr "$HOME/.config/chromium/Default/Bookmarks" "$BACKUP_DIR/browsers/" 2>/dev/null
echo -e "${CHECK} Browser data backup completed."

# ========================================================
# 9️⃣ Create Restore Script
# ========================================================
echo -e "\n${GEAR} Generating restore script..."
cat > "$BACKUP_DIR/restore.sh" << 'EOL'
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
EOL
chmod +x "$BACKUP_DIR/restore.sh"
echo -e "${CHECK} Restore script created."

# ========================================================
# 🔟 Final Notes and Files
# ========================================================
echo -e "\n${GEAR} Creating README and .gitignore..."
cat > "$BACKUP_DIR/README.md" << 'EOL'
# 🐧 Ubuntu Configuration Backup

This folder contains your full Ubuntu environment backup — including:
- Shell & user configs
- Installed packages (APT, Snap, Flatpak)
- VSCode and Cursor editor settings + extensions
- Git, SSH, and Cron configurations
- Desktop themes and bookmarks

## 🔁 To Restore:
```bash
cd ~/Desktop/SAWASH/Ubuntu
chmod +x restore.sh
./restore.sh

