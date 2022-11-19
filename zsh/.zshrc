source ~/dotFiles/zsh/antigen.zsh
antigen bundle git
antigen bundle fzf
antigen bundle ansible
antigen bundle tmux
antigen bundle ripgrep

antigen apply
autoload -U compinit promptinit
compinit
promptinit; prompt gentoo
export CLASSPATH=$CLASSPATH:/home/hanli/Codes/Projects/Coursera/Sedgewick/lib/algs4.jar
export STARDICT_DATA_DIR=$HOME/.dict/

autoload -Uz colors && colors

autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '%F{red}*'   # display this when there are unstaged changes
zstyle ':vcs_info:*' stagedstr '%F{yellow}+'  # display this when there are staged changes
zstyle ':vcs_info:*' actionformats '%F{5}(%F{2}%b%F{3}|%F{1}%a%c%u%m%F{5})%f '
zstyle ':vcs_info:*' formats '%F{5}(%F{2}%b%c%u%m%F{5})%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git cvs svn
zstyle ':vcs_info:git*+set-message:*' hooks untracked-git

+vi-untracked-git() {
  if command git status --porcelain 2>/dev/null | command grep -q '??'; then
    hook_com[misc]='%F{red}?'
  else
    hook_com[misc]=''
  fi
}

gentoo_precmd() {
  vcs_info
}

autoload -U add-zsh-hook
add-zsh-hook precmd gentoo_precmd


setopt aliases
alias s='ssh'
alias cat='sudo cat -v'
alias vms='vmstat 1'
alias emerge='sudo emerge'
alias dmidecode='sudo dmidecode'
alias tcpdump='sudo tcpdump'
alias iptables='sudo iptables'
alias ipset='sudo ipset'
alias iptables-apply='sudo iptables-apply'
alias iptables-restore='sudo iptables-restore'
alias iptables-save='sudo iptables-save'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias cd.....='cd ../../../..'
alias mount='sudo mount'
alias la='exa -alF --icons'
alias ls='exa -lF --icons'
alias g=git
alias gti=git
alias q=exit

alias set644="(find . -type d -exec sudo chmod 755 {} \;) && (find . -not -type d -exec sudo chmod 644 {} \;)"
alias set664="(find . -type d -exec sudo chmod 775 {} \;) && (find . -not -type d -exec sudo chmod 664 {} \;)"
alias set666="(find . -type d -exec sudo chmod 777 {} \;) && (find . -not -type d -exec sudo chmod 666 {} \;)"
alias set600="(find . -type d -exec sudo chmod 700 {} \;) && (find . -not -type d -exec sudo chmod 600 {} \;)"
ex () {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)   tar xjf $1   ;;
			*.tar.gz)    tar xzf $1   ;;
			*.tar.xz)    tar xf $1   ;;
			*.bz2)       bunzip2 $1   ;;
			*.rar)       rar x $1     ;;
			*.gz)        gunzip $1    ;;
			*.tar)       tar xf $1    ;;
			*.tbz2)      tar xjf $1   ;;
			*.tgz)       tar xzf $1   ;;
			*.zip)       unzip $1     ;;
			*.Z)         uncompress $1  ;;
			*.7z)        7z x $1    ;;
			*)           echo "'$1' cannot be extracted via extract()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

#PROMPT='%(!.%B%F{red}.%B%F{green}%n@)%m %F{blue}%(!.%1~.%~) ${vcs_info_msg_0_}%F{blue}%(!.#.$)%k%b%f '

[ -f "/home/hanli/.ghcup/env" ] && source "/home/hanli/.ghcup/env" # ghcup-env
# learned a lot from https://github.com/junnplus/dotfiles

eval "$(starship init zsh)"
function spaces {
    if [[ -n "$TMUX" ]]
    then
	return 0
    fi
    tmux ls -F '#{session_name}' |
    fzf --bind=enter:replace-query+print-query |
    read session && tmux attach -t ${session:-default} || tmux new -s ${session:-default}
				}

export FZF_COMPLETION_TRIGGER='~~'
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS"
--height 40%
--reverse
--bind 'ctrl-f:preview-page-down,ctrl-b:preview-page-up'
--color=light
--color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
--color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
"
