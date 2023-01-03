#!/bin/zsh

# FUNCS
backup () {
    # BACKUP to GIT
    cp -R ~/.config/colorls .config/
    cp ~/.oh-my-zsh/custom/*.zsh .oh-my-zsh/custom/
    cp ~/.bashrc .
    cp ~/.p10k.zsh .
    cp ~/.tmux.conf .
    cp ~/.vimrc .
    cp -R ~/.vim .
    cp ~/.zshrc .
}

restore () {
    # RESTORE FROM GIT
    cp -R .config/colorls ~/.config
    cp .oh-my-zsh/custom/*.zsh ~/.oh-my-zsh/custom/
    cp .bashrc ~
    cp .p10k.zsh ~
    cp .tmux.conf ~
    cp .vimrc ~
    cp -R .vim ~
    cp .zshrc ~
}

dif () {
    echo '>>> colorls'
    diff -r ~/.config/colorls .config/colorls
    echo '>>> ohmyzsh'
    diff ~/.oh-my-zsh/custom/*.zsh .oh-my-zsh/custom/*.zsh
    echo '>>> bashrc'
    diff ~/.bashrc .bashrc
    echo '>>> p10k'
    diff ~/.p10k.zsh .p10k.zsh
    echo '>>> tmux'
    diff ~/.tmux.conf .tmux.conf
    echo '>>> vimrc'
    diff ~/.vimrc .vimrc
    echo '>>> vim'
    diff -r ~/.vim .vim
    echo '>>> zshrc'
    diff ~/.zshrc .zshrc
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
