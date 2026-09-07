# SSH-friendly Zsh: no framework, no network bootstrap, graceful optional tools.
# Source from ~/.zshrc: source /path/to/zsh-ssh-terminal/.zshrc

export HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt append_history inc_append_history share_history hist_ignore_dups hist_reduce_blanks
setopt auto_cd auto_pushd pushd_ignore_dups interactive_comments
setopt complete_in_word menu_complete auto_menu
autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-${ZSH_VERSION}"

# Make backspace/delete, Home/End and the history search keys behave consistently
bindkey -e
bindkey '^[[A' history-substring-search-up 2>/dev/null || true
bindkey '^[[B' history-substring-search-down 2>/dev/null || true
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

_has() { command -v "$1" >/dev/null 2>&1 }
if _has eza; then alias ls='eza --group-directories-first'; alias ll='eza -lah --git --group-directories-first'; else alias ll='ls -lah'; fi
_has bat && alias cat='bat --paging=never --style=plain'
_has rg && alias grep='rg'
_has kubectl && alias k='kubectl'
_has terraform && alias tf='terraform'
_has terragrunt && alias tg='terragrunt'
alias g='git'
alias gst='git status -sb'
alias gdf='git diff'
alias gl='git log --oneline --decorate -20'

# Kubernetes context and namespace helpers. Usage: kctx prod; kns platform.
kctx() { kubectl config use-context "$1"; }
kns() { kubectl config set-context --current --namespace="$1"; }
kpods() { kubectl get pods "${@}"; }
kgw() { kubectl get "${@}" --watch; }
tfplan() { terraform plan -out=tfplan "$@"; }
tfapply() { terraform apply tfplan; }

# Compact, dependency-free prompt: status, user@host, working directory, git branch.
autoload -Uz colors && colors
_git_prompt() {
  local branch dirty
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  git diff --quiet --ignore-submodules -- 2>/dev/null || dirty='*'
  print -n " %F{magenta}(${branch}${dirty})%f"
}
setopt prompt_subst
PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f$(_git_prompt) %(?.%F{green}.%F{red})❯%f '
RPROMPT='%F{244}%D{%H:%M}%f'

# fzf integration is optional and varies by distribution.
if _has fzf; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g "!.git" 2>/dev/null'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Keep SSH sessions usable after a remote suspend/resume.
if [[ -n $SSH_CONNECTION ]]; then
  export TERM="${TERM:-xterm-256color}"
fi
