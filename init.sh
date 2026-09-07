#!/usr/bin/env bash
# Read-only check for the remote shell profile.
set -u
failures=0
need() { if command -v "$1" >/dev/null 2>&1; then printf '  [ok]      %s\n' "$1"; else printf '  [missing] %s — %s\n' "$1" "$2"; failures=$((failures+1)); fi; }
maybe() { command -v "$1" >/dev/null 2>&1 && printf '  [ok]      %s\n' "$1" || printf '  [optional] %s — %s\n' "$1" "$2"; }
printf 'Zsh SSH terminal readiness\n'
need zsh 'install Zsh from the approved mirror'
need ssh 'install the OpenSSH client'
need git 'git-aware prompt and aliases'
maybe eza 'modern ls aliases'
maybe bat 'syntax-highlighted cat alias'
maybe fzf 'fuzzy file/history selection'
maybe rg 'fast recursive search'
maybe kubectl 'k/kctx/kns helpers'
maybe terraform 'tf helpers'
maybe terragrunt 'tg alias'
printf '\nResult: %d required missing.\n' "$failures"
exit "$failures"
