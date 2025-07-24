#TODO 1 YASH
#TODO 2 SAWASH
#TODO 3 SPIT



# Load colors and define get_dir_color() as you already have...
autoload -U colors && colors

get_dir_color() {
  case "$PWD" in
    *Documents*) echo "%F{cyan}" ;;
    *Downloads*) echo "%F{yellow}" ;;
    *Projects*)  echo "%F{red}" ;;
    *Desktop*)   echo "%F{magenta}" ;;
    *Videos*)    echo "%F{red}" ;;
    *Music*)     echo "%F{purple}" ;;
    *)           echo "%F{blue}" ;;  # Default color for other directories
  esac
}

# Combined dynamic prompt with colored directory and venv prefix
update_prompt() {
  local dir_color=$(get_dir_color)
  local venv_prefix=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    venv_prefix="($(basename $VIRTUAL_ENV)) "
  fi
  PROMPT="${venv_prefix}%F{green}%n@${dir_color}%~%f %# "
}

# Add the hook so that update_prompt runs before each prompt
autoload -Uz add-zsh-hook
add-zsh-hook precmd update_prompt
update_prompt

# 3️⃣ Enable Colored `ls` Output (Folder, File, Executables, etc.)
export LS_COLORS="di=34:fi=37:ln=35:so=32:pi=33:ex=31:bd=36:cd=36:su=37:sg=37:tw=34:ow=34"
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lah'

# 4️⃣ Enable Syntax Highlighting (⚠️ Slows terminal a bit — comment to test performance)
# if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
#   source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# fi

# 5️⃣ Enable Command Autosuggestions (⚠️ Also slows terminal — comment to improve speed)
# if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
#   source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# fi

# 6️⃣ Useful Aliases for Developers
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias v='nvim'  # Change to vim if you use vim
alias python='python3'
alias pip='pip3'
alias on='source bin/activate'
alias off='deactivate'

# Git Aliases
alias g='git'
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push origin main '
alias gl='git log '

# Project VS Code
alias prj='gtk-launch vscode-workspace'
alias clg='gtk-launch vscode-workspace-SPIT'
alias dsa='code /home/yashsawant/Desktop/DSA'

# Personal Aliases
alias command='code /home/yashsawant/Desktop/College/Commands'
alias active='source /home/yashsawant/Desktop/venv/bin/activate'
alias cur='/home/yashsawant/Desktop/./Cursor-0.48.8-x86_64.AppImage'
alias jn='active && jupyter notebook'

# Browser Aliases
alias leetcode='brave-browser --profile-directory="Profile 2" --new-window "https://leetcode.com/problemset/" '
alias gfg='brave-browser --profile-directory="Profile 2" --new-window  "https://www.geeksforgeeks.org/user/sawash09am/"'
alias github='brave-browser --profile-directory="Profile 2" --new-window  "https://github.com/SytherAsh"'
alias dis='brave-browser --profile-directory="Profile 2" --new-window  "https://discord.com/channels/1226542217741467689/1226542217741467692"'
alias gpt='brave-browser --profile-directory="Profile 2" --new-window  "https://chatgpt.com/"'
alias smk='brave-browser --profile-directory="Profile 3" --new-window  "https://smashkarts.io/"'
alias yts='brave-browser --profile-directory="Profile 3" --new-window  "https://yts.mx/"'

alias ryp='brave-browser --profile-directory="Profile 1" --new-window  "https://rpy.club/course/APlFbgQQfN?module-id=677a9d42e3de0f8dd2d215e8&lesson-id=677a9d42e3de0f8dd2d215ec"'

alias cmd='code ~/.zshrc'

# Docker Aliases
alias docker-clean='docker system prune -af'

# 7️⃣ History & Performance Tweaks
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# 8️⃣ Load Powerlevel10k (⚠️ Heavy theme — slows prompt, disable for max performance)
# if [[ -f ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme ]]; then
#   source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
# fi

alias major="~/run-major.sh"
export PATH="$HOME/scripts:$PATH"
export PATH=$PATH:~/.local/bin
