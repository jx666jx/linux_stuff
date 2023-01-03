### VARS ###
# freedom from tyranny
TMOUT=0
# where are the files
REPO=/usr/local/share/pypilibs
SCRIPTS=~/SCRIPTS
DOWNLOADS=~/DUMP
PYTHON=python3.9

### COLORLS
# grab the ruby version
RUBVER=`ruby -e 'puts RUBY_VERSION' | cut -c1-3`
# if colorls is installed configure aliases with it, else default to ls aliases
if `gem search -i colorls` = true ; then
  PATH=$PATH:~/.local/share/gem/ruby/$RUBVER.0/bin
  source $(dirname $(gem which colorls))/tab_complete.sh
  alias lt='colorls -lA --tree=2 --sd'
  alias ll='colorls -la --sd'
  alias llg='colorls -la --sd --gs'
  alias la='colorls -l --sd'
  alias ld='colorls -lAd --sd'
  alias lf='colorls -lAf --sd'
  alias l='colorls -Ca --sd'
  alias lsp='colorls -a --sd '$REPO
  alias lss='colorls -a --sd '$SCRIPTS
  alias lsd='colorls -a --sd '$DOWNLOADS
  if [ -f ~/.local/share/icons-in-terminal/icons_bash.sh ]; then
    source ~/.local/share/icons-in-terminal/icons_bash.sh
  fi
else
  alias ll='ls -la --group-directories-first'
  alias la='ls -l --group-directories-first'
  alias lf="ls -l | egrep -v '^d'"
  alias ld='ls -ld */'
  alias l='ls -Ca --group-directories-first'
  alias lsp='ls -a '$REPO' --group-directories-first'
  alias lss='ls -a '$SCRIPTS' --group-directories-first'
  alias lsd='ls -a '$DOWNLOADS' --group-directories-first'
fi

### ALIAS FUNK
alias cdd='cd '$DOWNLOADS
alias cds='cd '$SCRIPTS
alias cdp='cd '$REPO
alias cdz='cd '$ZSH_CUSTOM
alias sv='source .venv/bin/activate'
alias zshrc='. ~/.zshrc'
alias zshrcv='vi ~/.zshrc'
alias tls='tmux ls'
# what procs am i running
alias pg='pgrep -u $USER -a -f '$1

# make dir and enter
mcd () {
    mkdir -p $1
    cd $1
}

# show formatted json
jxson () {
    cat $1 | $PYTHON -c "import sys, json; parse=(json.load(sys.stdin)); print (json.dumps(parse, indent=4))"
}

# vscode refresh IPC
vscri () {
   export VSCODE_IPC_HOOK_CLI=$(lsof 2>/dev/null | grep $UID/vscode-ipc | awk '{print $(NF-1)}' | head -n 1) 
}

# tmux stuff
alias tls='tmux ls'
tat () {
    select sel in $(tmux ls -F '#{session_name}' ); do break; done
    tmux attach -t "$sel"
}
tla () {
    select sel in $(tmux ls -F '#{session_name}'); do break; done
    tmux attach -t "$sel"
}
logz () {
    tmux new-session -d -s logz -n 'sys_logs' >/dev/null
    tmux splitw -v -t logz:1.1
    tmux select-pane -t logz:1.1
    tmux send-keys -t logz:1.1 'tail -f /var/log/syslog' Enter
    tmux select-pane -t logz:1.2
    tmux send-keys -t logz:1.2 'tail -f /var/log/dmesg' Enter

    tmux new-window -t logz -n 'apache_logs' >/dev/null
    tmux splitw -v -t logz:2.1
    tmux select-pane -t logz:2.1
    tmux send-keys -t logz:2.1 'tail -f /var/log/apache2/access.log' Enter
    tmux select-pane -t logz:2.2
    tmux send-keys -t logz:2.2 'tail -f /var/log/apache2/error.log' Enter

    tmux a -t logz
}

# ansible shorts
apn () {
 ansible-playbook $1 -i ../netarch-inventory/inventory-nsx.yml
}
apc () {
 ansible-playbook $1 -i ../netarch-inventory/inventory-cocc.yml
}
apcv () {
 ansible-playbook -vvv $1 -i ../netarch-inventory/inventory-cocc.yml
}

# git
# git push local to gitlab
alias gitpn='git push --set-upstream git@git.cocci.com:\`whoami\`/$(git rev-parse --show-toplevel | xargs basename).git $(git rev-parse --abbrev-ref HEAD)'

# python stuff
cvenv () {
    $PYTHON -m venv .venv --prompt=$1
    source .venv/bin/activate
    pip install wheel 
    pipup
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
    fi
}
pipin () {
    pip install $*
    #pip install  --no-index --find-links file://$REPO/ $*
}
pipup (){
    pip list --outdated --format=json | jq -r '.[] | "\(.name)==\(.latest_version)"' | xargs -n1 pip install -U
}
pipl () {
    pip list
}
pipfree () {
    pip freeze --all > requirements.txt
}

# cd function that will activate venv in current path
function cd() {
  builtin cd "$@"
  ## Default path to virtualenv in your projects
  DEFAULT_ENV_PATH="./.venv"
  function activate_venv() {
    if [[ -f "${DEFAULT_ENV_PATH}/bin/activate" ]] ; then 
      source "${DEFAULT_ENV_PATH}/bin/activate"
      echo -e "\e[42mactivating:\e[0m ${VIRTUAL_ENV}"
    fi
  }
  if [[ -z "$VIRTUAL_ENV" ]] ; then
    activate_venv
  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate then run a new env folder check
      parentdir="$(dirname ${VIRTUAL_ENV})"
      if [[ "$PWD"/ != "$parentdir"/* ]] ; then
        echo -e "\e[0;41mdeactivating:\e[0m ${VIRTUAL_ENV}"
        deactivate
        activate_venv
      fi
  fi
}

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
