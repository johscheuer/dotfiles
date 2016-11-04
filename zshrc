export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="johscheuer"
ZSH_CUSTOM=${HOME}/.ohmyzsh/
plugins=(git brew docker golang httpie vagrant sudo colored-man)

# User configuration

export GOPATH="$HOME/go"
export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:/usr/local/MacGPG2/bin:$HOME/ykpers/bin:$HOME/go/bin:/opt/local/bin:/Library/TeX/texbin/"
source $ZSH/oh-my-zsh.sh

# ZSH SETTINGS
set -k
SAVEHIST=1000
HISTSIZE=1000
HISTFILE=~/.history
export HISTTIMEFORMAT='%F %T '
export HISTTIMEFORMAT="%Y-%m-%d% H:%M"
export HISTCONTROL="erasedups:ignoreboth"


# AUTOCOMPLETION
zmodload -i zsh/complist
autoload -U compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
zstyle ':completion:*' completer _complete _correct _approximate _prefix
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:predict:*' completer _complete
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' accept-exact false
_comp_options+=(globdots)

fpath=(~/.zsh/completion $fpath)
# ALIASES
alias update='brew update && brew upgrade'
alias ckctl="./cluster/kubectl.sh"
export EDITOR=vim

# NUMBLOCK/KEYPAD FIXES FROM http://superuser.com/questions/742171/zsh-z-shell-numpad-numlock-doesnt-work
if [[ -n "$(which bindkey)" ]]; then
  # 0 . Enter
  bindkey -s "^[OM" "^M"
fi

# MISC
l8security() {
  command="$1"
  echo "Are you sure? Type 'YES, do as I say' now or abort with ^C:"
  read -r resp
  if [[ "$resp" == 'YES, do as I say' ]]; then
    echo -e "\nExecuting ${command}.."
    zsh <<< "${command}" &!
  fi
}

preexec() {
    typeset -gi CALCTIME=1
    typeset -gi CMDSTARTTIME=SECONDS
}

precmd() {
    if (( CALCTIME )) ; then
        typeset -gi ETIME=SECONDS-CMDSTARTTIME
    fi
    typeset -gi CALCTIME=0
}


[[ -e $HOME/.shell_common ]] && source $HOME/.shell_common
[[ -e $HOME/.zsh_local ]] && source $HOME/.zsh_local
[[ -e $HOME/.zsh_aliases ]] && source $HOME/.zsh_aliases

true

# The next line updates PATH for the Google Cloud SDK.
source '/Users/jscheuermann/google-cloud-sdk/path.zsh.inc'
# The next line enables shell command completion for gcloud.
source '/Users/jscheuermann/google-cloud-sdk/completion.zsh.inc'

source <(kubectl completion zsh) 

# added by travis gem
[ -f /Users/jscheuermann/.travis/travis.sh ] && source /Users/jscheuermann/.travis/travis.sh
