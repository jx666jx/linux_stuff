### COLORLS
# grab the ruby version
RUBVER=`ruby -e 'puts RUBY_VERSION' | cut -c1-3`
# if colorls is installed configure aliases with it, else default to ls aliases
if `gem search -i colorls` = true ; then
  PATH=$PATH:~/.local/share/gem/ruby/$RUBVER.0/bin
  source $(dirname $(gem which colorls))/tab_complete.sh
  alias lt='colorls -lA --tree=2 --sd'
  alias ll='colorls -la --sd'
  alias la='colorls -l --sd'
  alias ld='colorls -lAd --sd'
  alias lf='colorls -lAf --sd'
  alias l='colorls -Ca --sd'
  if [ -f ~/.local/share/icons-in-terminal/icons_bash.sh ]; then
    source ~/.local/share/icons-in-terminal/icons_bash.sh
  fi
else
  alias ll='ls -la --group-directories-first'
  alias la='ls -l --group-directories-first'
  alias lf="ls -l | egrep -v '^d'"
  alias ld='ls -ld */'
  alias l='ls -Ca --group-directories-first'
fi

### ALIAS FUNK
alias cdd='cd ~/DUMP'
alias cds='cd ~/SCRIPTS'
alias cdg='cd ~/SCRIPTS/github'
alias bashrc='source ~/.bashrc'
alias tls='tmux ls'
alias pg='pgrep -u $USER -a -f '$1

alias sup='sudo apt update; sudo apt upgrade'

mcd () {
    mkdir -p $1
    cd $1
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
