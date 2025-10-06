#!/bin/zsh

# Color and symbol definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
CHECK_MARK="${GREEN}✓${NC}"
X_MARK="${RED}✗${NC}"

# Status update functions
show_success() {
    echo -e "${CHECK_MARK} $1"
}

show_error() {
    echo -e "${X_MARK} $1"
    return 1
}

# FUNCS
backup () {
    echo "Starting backup process..."
    
    # BACKUP to GIT
    if cp -R ~/.config/colorls .config/ 2>/dev/null; then
        show_success "Backed up colorls config"
    else
        show_error "Failed to backup colorls config"
    fi

    if cp ~/.oh-my-zsh/custom/*.zsh .oh-my-zsh/custom/ 2>/dev/null; then
        show_success "Backed up oh-my-zsh custom files"
    else
        show_error "Failed to backup oh-my-zsh custom files"
    fi

    local files=(".bashrc" ".p10k.zsh" ".tmux.conf" ".vimrc" ".zshrc")
    for file in "${files[@]}"; do
        if cp ~/$file . 2>/dev/null; then
            show_success "Backed up $file"
        else
            show_error "Failed to backup $file"
        fi
    done

    if cp -R ~/.vim . 2>/dev/null; then
        show_success "Backed up vim directory"
    else
        show_error "Failed to backup vim directory"
    fi
}

restore () {
    echo "Starting restore process..."
    
    # RESTORE FROM GIT
    echo "Installing required packages..."
    if sudo apt-get install vim tmux zsh -y >/dev/null 2>&1; then
        show_success "Installed required packages"
    else
        show_error "Failed to install required packages"
    fi

    if cp .oh-my-zsh/custom/*.zsh ~/.oh-my-zsh/custom/ 2>/dev/null; then
        show_success "Restored oh-my-zsh custom files"
    else
        show_error "Failed to restore oh-my-zsh custom files"
    fi

    local files=(".bashrc" ".p10k.zsh" ".tmux.conf" ".vimrc" ".zshrc")
    for file in "${files[@]}"; do
        if cp $file ~/ 2>/dev/null; then
            show_success "Restored $file"
        else
            show_error "Failed to restore $file"
        fi
    done

    if cp -R .vim ~/ 2>/dev/null; then
        show_success "Restored vim directory"
    else
        show_error "Failed to restore vim directory"
    fi
}

dif () {
    echo "Checking for differences..."
    
    local files=(
        "ohmyzsh:~/.oh-my-zsh/custom/jx-aliases.zsh:.oh-my-zsh/custom/jx-aliases.zsh"
        "bashrc:~/.bashrc:.bashrc"
        "p10k:~/.p10k.zsh:.p10k.zsh"
        "tmux:~/.tmux.conf:.tmux.conf"
        "vimrc:~/.vimrc:.vimrc"
        "zshrc:~/.zshrc:.zshrc"
    )

    local has_differences=0

    for entry in "${files[@]}"; do
        IFS=':' read -r name src dest <<< "$entry"
        echo -e "\nChecking $name..."
        
        # Expand the ~ in the source path
        src="${src/#\~/$HOME}"
        
        if [[ ! -f "$src" && ! -f "$dest" ]]; then
            show_error "Neither source nor repo file exists for $name"
            has_differences=1
            continue
        elif [[ ! -f "$src" ]]; then
            show_error "Source file $src does not exist"
            has_differences=1
            continue
        elif [[ ! -f "$dest" ]]; then
            show_error "Repo file $dest does not exist"
            has_differences=1
            continue
        fi

        if diff "$src" "$dest" >/dev/null 2>&1; then
            show_success "No differences found in $name"
        else
            show_error "Differences found in $name:"
            diff "$src" "$dest" || true  # continue even if diff exits with error
            has_differences=1
        fi
    done

    echo -e "\nChecking vim directory..."
    if [[ ! -d "$HOME/.vim" && ! -d ".vim" ]]; then
        show_error "Neither source nor repo vim directory exists"
        has_differences=1
    elif [[ ! -d "$HOME/.vim" ]]; then
        show_error "Source vim directory does not exist"
        has_differences=1
    elif [[ ! -d ".vim" ]]; then
        show_error "Repo vim directory does not exist"
        has_differences=1
    else
        if diff -r "$HOME/.vim" .vim >/dev/null 2>&1; then
            show_success "No differences found in vim directory"
        else
            show_error "Differences found in vim directory:"
            diff -r "$HOME/.vim" .vim || true  # continue even if diff exits with error
            has_differences=1
        fi
    fi

    if [ $has_differences -eq 0 ]; then
        echo -e "\n${CHECK_MARK} All files are in sync!"
    else
        echo -e "\n${X_MARK} Some files have differences"
    fi
}

# WHAT YOU WANNA DO!?
case $1 in
    'backup')
        backup
        ;;
    'restore')
        restore
        ;;
    'dif')
        dif
        ;;
    *)
        echo 'USAGE: setup.sh [ backup | restore | dif ]'
        echo '  backup local files to repo'
        echo '  restore repo to local files'
        echo '  diff the local and repo files'
        echo ''
        exit
        ;;
esac
