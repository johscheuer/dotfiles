#!/bin/zsh

setopt prompt_subst
autoload -U colors && colors # Enable colors in prompt
local return_code="%(?.. - %F{cyan}[%B%F{red}%?%b%F{cyan}]%f)"

host=''
[[ -n $SSH_CLIENT || $(who am i | tr -s ' ' | cut -d' ' -f2) =~ "pts/*" ]] && host='%F{yellow}@%F{cyan}%m'

function my_uh() {
  user_color='{green}'
  [[ $UID == 0 ]] && user_color='{red}'

  echo "%B%F${user_color}%n$1%f%b"
}

function my_dir() {
  path_color='{yellow}'
  [[ ! -w $PWD ]] && path_color='{red}'
  echo " - %F{cyan}[%B%F${path_color}%~%b%F{cyan}]%f"
}

function my_load() {
  [[ $UID == 0 ]] && echo " - %F{cyan}[%F{yellow}$(uptime | sed 's/.*load average: //' | awk -F', ' '{print $1}')/$(uptime | sed 's/.*load average: //' | awk -F', ' '{print $2}')/$(uptime | sed 's/.*load average: //' | awk -F', ' '{print $3}')%F{cyan}]%f%b"
}

function my_jobs() {
  [[ $(jobs | wc -l) -gt 0 ]] && echo ' - %F{cyan}[%B%F{green}%j%b%F{cyan}]%f'
}

# Show Git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

# Show different symbols as appropriate for various Git repository states
parse_git_state() {

  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi

}

# If inside a Git repository, print its branch and state
git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
}

function my_time() {
  echo ' %F{green}%D{%H:%M:%S}'
}

function cmd_exec_time() {
  [[ -z $ETIME ]] && ETIME=0
  echo "%F{cyan}[%B%F{yellow}$(convertsecs ${ETIME})%b%F{cyan}]%f"
}

function convertsecs() {
  ((h=${1}/3600))
  ((m=(${1}%3600)/60))
  ((s=${1}%60))
  printf "%02dh %02dm %02ds\n" $h $m $s
}

function get_kubernetes_context() {
    local NAMESPACE="$(kubectl config get-contexts | grep $(kubectl config current-context) | awk '{print $5}')"
    if [[ -z ${NAMESPACE} ]] || [[ ${NAMESPACE} == 'default' ]]; then
        NAMESPACE="%B%F{yellow}default"
    else
        NAMESPACE="%B%F{cyan}${NAMESPACE}"
    fi

    local K8S_INFO="$(kubectl config current-context) ${NAMESPACE}"

    echo "%F{cyan}[%B%F{yellow}${K8S_INFO}%b%F{cyan}]%f"
}

PROMPT=$'
%F{cyan}┌──[ $(my_uh ${host})$(my_dir)$(cmd_exec_time)$(my_load)${return_code}$(my_jobs)
%F{cyan}└──[%f '

RPROMPT='$(git_prompt_string)$(get_kubernetes_context)$(my_time)'

GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"
GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg[red]%}●%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg[yellow]%}●%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg[green]%}●%{$reset_color%}"
