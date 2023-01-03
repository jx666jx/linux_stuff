# .bashrc
# If not running interactively, don't do nothin
case $- in
    *i*) ;;
      *) return;;
esac

# Source globalz
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# history
HISTCONTROL=ignoreboth # don't put duplicate lines or lines starting with space in the history.
shopt -s histappend # append to the history file, don't overwrite it
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, update if necessary
shopt -s checkwinsize

# set a fancy prompt (non-color, unless we know we "want" color)
function color_my_prompt {
    local __user_and_host="\[\033[01;32m\]\u\e[0;39m\]@\[\e[1;36m\]\h\[\e[0;39m\]"
    local __cur_location="\[\033[01;34m\]\w"
    local __git_branch_color="\[\033[31m\]"
    #local __git_branch="\`ruby -e \"print (%x{git branch 2> /dev/null}.grep(/^\*/).first || '').gsub(/^\* (.+)$/, '(\1) ')\"\`"
    local __git_branch='`git branch 2> /dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\/`'
    local __prompt_tail="\[\033[35m\]$"
    local __last_color="\[\033[00m\]"
    #export PS1="$__user_and_host $__cur_location $__git_branch_color$__git_branch$__prompt_tail$__last_color "
    export PS1="\[\e[1;37m\]\[\e[1;32m\]\u\[\e[0;39m\]@\[\e[1;36m\]\h\[\e[0;39m\]:\[\e[1;33m\]\w\[\e[0;39m\]\[\e[1;35m\]$__git_branch\[\e[0;39m\]\[\e[1;37m\]\[\e[0;39m\]$ "
}
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
#force_color_prompt=yes  # uncomment to force
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	    color_prompt=yes
    else
	    color_prompt=
    fi
fi
if [ "$color_prompt" = yes ]; then
    color_my_prompt
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# color GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

### VARS
# freedom from tyranny
TMOUT=0
# where are the files
REPO=/usr/local/share/pypilibs
SCRIPTS=~/SCRIPTS
DOWNLOADS=~/DUMP
# grab the python version
alias python='python3.9'  # forces calls to python to use this version
PY3VER=`python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))'`
# powerline home
export POWERLINE_HOME=~/SCRIPTS/powerline/.venv

### POWERLINE
# if powerline is in a venv, make sure the venv was built with the python version set above
# need to create a link in the venv else we get error
if [ ! -d $POWERLINE_HOME/lib/python$PY3VER/site-packages/powerline/bindings/bash/../../../scripts ]; then
  ln -s $POWERLINE_HOME/bin $POWERLINE_HOME/lib/python$PY3VER/site-packages/powerline/bindings/bash/../../../scripts
fi

# launch the daemon and setup bash
if [ -f $POWERLINE_HOME/lib/python$PY3VER/site-packages/powerline/bindings/bash/powerline.sh ]; then
  $POWERLINE_HOME/bin/powerline-daemon --quiet
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  source $POWERLINE_HOME/lib/python$PY3VER/site-packages/powerline/bindings/bash/powerline.sh
fi

### ALIAS FUNK
alias cdd='cd '$DOWNLOADS
alias cds='cd '$SCRIPTS
alias cdp='cd /usr/local/share/pypilibs'
alias sv='source .venv/bin/activate'
alias bashrc='. ~/.bashrc'
alias bashrcv='vi ~/.bashrc'

# list things
alias ll='ls -la --group-directories-first'
alias la='ls -l --group-directories-first'
alias lf="ls -l | egrep -v '^d'"
alias ld='ls -ld */'
alias l='ls -Ca --group-directories-first'
alias lsp='ls -a '$REPO' --group-directories-first'
alias lss='ls -a '$SCRIPTS' --group-directories-first'
alias lsd='ls -a '$DOWNLOADS' --group-directories-first'

# make dir and enter
mcd () {
    mkdir -p $1
    cd $1
}

# what procs am i running
alias pg='pgrep -u $USER -a -f '$1

# show formatted json
jxson () {
    cat $1 | python3 -c "import sys, json; parse=(json.load(sys.stdin)); print (json.dumps(parse, indent=4))"
}

# vscode refresh IPC
vscr () {
   export VSCODE_IPC_HOOK_CLI=$(lsof 2>/dev/null | grep $UID/vscode-ipc | awk '{print $(NF-1)}' | head -n 1) 
}

# tmux stuff
alias tls='tmux ls'
tat () {
    select sel in $(tmux ls -F '#{session_name}' ); do break; done
    tmux attach -t "$sel"
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

# python stuff
cvenv () {
    python -m venv .venv --prompt=$1
    source .venv/bin/activate
    pip install wheel 
    pipup
    if [ -f requirements.txt ]; then
        pip install -r requirements.txt
        #pip install -r requirements.txt --no-index --find-links file://$REPO/
    fi
}
pipreq () {
    pip install -r requirements.txt 
    #pip install -r requirements.txt --no-index --find-links file://$REPO/
}
pipin () {
    pip install  $*
    #pip install  --no-index --find-links file://$REPO/ $*
}
pipup (){
    pip list --outdated --format=json | jq -r '.[] | "\(.name)==\(.latest_version)"' | xargs -n1 pip install -U
    #pip3 list --outdated | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U 
    #pip list --outdated --format=freeze --no-index --find-links file://$REPO/ | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip install -U --no-index --find-links file:///usr/local/share/pypilibs/
}
pipl () {
    pip list
}
piplo () {
    pip list --outdated
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

