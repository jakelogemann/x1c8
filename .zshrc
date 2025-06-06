# shellcheck shell=bash disable=2046,2068,1090,2086
#==============================================================================#
#                            .d888 d8b                                888      #
#                           d88P"  Y8P                                888      #
#                           888                                       888      #
#  .d8888b .d88b.  88888b.  888888 888  .d88b.      88888888 .d8888b  88888b.  #
# d88P"   d88""88b 888 "88b 888    888 d88P"88b        d88P  88K      888 "88b #
# 888     888  888 888  888 888    888 888  888       d88P   "Y8888b. 888  888 #
# Y88b.   Y88..88P 888  888 888    888 Y88b 888 d8b  d88P         X88 888  888 #
#  "Y8888P "Y88P"  888  888 888    888  "Y88888 Y8P 88888888  88888P' 888  888 #
#                                           888                                #
#                                      Y8b d88P                                #
#                                       "Y88P"                                 #
#===============================================================================

#========================================================================

function dir-exists(){ test -d "$1"; }
function edit-local-shell-config(){ safely-edit $(local-shell-config); }
function edit-shell-aliases(){ safely-edit $(shell-aliases); }
function edit-shell-config(){ safely-edit $(shell-config); }
function edit-shell-functions(){ safely-edit $(shell-functions); }
function file-exists(){ test -e "$1"; }
function file-is-readable(){ test -r "$1"; }
function has-bin(){ test -x $(which "$1" 2>/dev/null || true); }
function has-path(){ list-path | grep -q "$1"; }
function list-hosts(){ column -t </etc/hosts ;}
function list-path(){ echo $PATH | tr ':' '\n'; }
function list-users(){ column -ts: </etc/passwd | sort -nk3 ;}
function list-keybinds(){ column -t <(bindkey|xargs -n2 echo) ;}
function local-shell-config(){ echo "${HOME}/.$(shell-name)rc.local"; }
function maybe-add-path(){ has-path "$1" || test ! -d "$1" || export PATH="$1:$PATH"; }
function maybe-eval-bin(){ missing-bin "$1" || eval "$($@)"; }
function maybe-source(){ test ! -r "$1" || source "${2:-$1}"; }
function missing-bin(){ command -v "$1" >/dev/null 2>&1; }
function reload-config(){ safely-source $(shell-config); }
function reload-local-config(){ safely-source $(local-shell-config); }
function reload-shell-aliases(){ safely-source $(shell-aliases); }
function reload-shell-functions(){ safely-source $(shell-functions); }
function safely-edit(){ touch "$1" && "$EDITOR" "$1"; }
function safely-source(){ touch "$1" && source "$1"; }
function shell-aliases(){ echo "${HOME}/.aliases.sh"; }
function shell-config(){ echo "${HOME}/.$(shell-name)rc"; }
function shell-functions(){ echo "${HOME}/.fn.sh"; }
function shell-name(){ basename "$SHELL"; }

#=======================================================================

maybe-add-path "$HOME/bin"
maybe-add-path "$HOME/go/bin"
maybe-add-path "$HOME/.cargo/bin"
maybe-add-path "/bin"
maybe-add-path "/opt/homebrew/bin"
maybe-add-path "/opt/homebrew/sbin"
maybe-add-path "/sbin"
maybe-add-path "/usr/bin"
maybe-add-path "/usr/local/bin"
maybe-add-path "/usr/sbin"


#=======================================================================

# zmodload "zsh/attr" "zsh/cap" "zsh/clone" "zsh/complete" "zsh/complist" "zsh/computil" \
#   "zsh/curses" "zsh/langinfo" "zsh/mathfunc" "zsh/parameter" "zsh/regex" "zsh/sched" "zsh/system" \
#   "zsh/termcap" "zsh/terminfo" "zsh/zle" "zsh/zleparameter" "zsh/zpty" "zsh/zselect" "zsh/zutil"

# autoload -Uz promptinit colors compinit bashcompinit;
# promptinit && colors && compinit && bashcompinit

#=======================================================================
#
# zstyle ':completion:*'                cache-path        "$zsh_dir/completion.cache"
# zstyle ':vcs_info:*'                  enable            git cvs svn hg
# zstyle ':completion:*'                completer         _complete _match _approximate _expand_alias
# zstyle ':completion:*'                file-list         list=20 insert=10
# zstyle ':completion:*'                squeeze-slashes   true
# zstyle ':completion:*'                use-cache         on
# zstyle ':completion:*:*:kill:*'       menu              yes select
# zstyle ':completion:*:(all-|)files'   ignored-patterns  '(|*/)CVS'
# zstyle ':completion:*:default'        list-dirs-first   true
# zstyle ':completion:*:approximate:*'  max-errors        1 numeric
# zstyle ':completion:*:cd:*'           ignore-parents    parent pwd
# zstyle ':completion:*:cd:*'           ignored-patterns  '(*/)#CVS'
# zstyle ':completion:*:functions'      ignored-patterns  '_*'
# zstyle ':completion:*:kill:*'         force-list        always
# zstyle ':completion:*:match:*'        original          only
# zstyle ':completion:*:rm:*'           file-patterns     '*.log:log-files' '%p:all-files'
#
#=======================================================================

# typeset -a baliases; baliases=(); # blank aliases
# typeset -a ialiases; ialiases=(); # ignored aliases
# function balias() { alias $@; args="$@"; args=${args%%\=*}; baliases+=(${args##* }); }
# function ialias() { alias $@; args="$@"; args=${args%%\=*}; ialiases+=(${args##* }); }
# function zle-run-navi() {  BUFFER=" navi"; zle accept-line; }
# function zle-skim-dir() {  BUFFER=" sk --ansi -i -c 'grep -rI --color=always --line-number \"{}\" .'"; zle accept-line; }
# function zle-skim-dirs() {  BUFFER=' vim -p $(find . -type f | sk -m)'; zle accept-line; }
# function expand-alias-space() {
#   [[ $LBUFFER =~ "\<(${(j:|:)ialiases})\$" ]]; ignored=$?
#   [[ $LBUFFER =~ "\<(${(j:|:)baliases})\$" ]]; insertBlank=$?
#   if [[ "$ignored" = "0" ]]; then return; fi
#   # zle _expand_alias
#   zle self-insert
#   if [[ "$insertBlank" = "0" ]]; then zle backward-delete-char; fi
# }

#=======================================================================

# setopt cbases cprecedences
# setopt autocd autopushd pushdsilent pushdignoredups pushdtohome
# setopt cdablevars interactivecomments printexitvalue shortloops
# setopt localloops localoptions localpatterns
# setopt pipefail vi evallineno
#
# # Autocompletion
# setopt hashdirs hashcmds
# setopt aliases
# setopt automenu
# setopt autoparamslash
# setopt autoremoveslash
# setopt completealiases
# setopt promptbang promptcr promptsp promptpercent promptsubst transientrprompt
# setopt listambiguous
# setopt listpacked
# setopt listrowsfirst
# setopt autolist
# setopt markdirs
# setopt banghist
# setopt histbeep
# setopt inc_append_history
# setopt histexpiredupsfirst
# setopt histignorealldups
# setopt histnostore
# setopt histfcntllock
# setopt histfindnodups
# setopt histreduceblanks
# setopt histsavebycopy
# setopt histverify
# setopt sharehistory

# # Shell History
# HISTFILE="$HOME/.zhistory"
# SAVEHIST=50000  # Total lines to save in zsh history.
# HISTSIZE=1000   # Lines of history to save to save from the current session.

unsetopt correct correctall

# Job Control
unsetopt flowcontrol   #Disable ^S & ^Q.
setopt autocontinue autoresume bgnice checkjobs notify longlistjobs
setopt checkrunningjobs

#=======================================================================
zmodload "zsh/zle" "zsh/zleparameter" "zsh/zselect"
# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() { echoti smkx; }
  function zle-line-finish() { echoti rmkx; }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

autoload -U expand-alias-space && zle -N expand-alias-space
autoload -U edit-command-line  && zle -N edit-command-line
autoload -U up-line-or-beginning-search && zle -N up-line-or-beginning-search
autoload -U down-line-or-beginning-search && zle -N down-line-or-beginning-search
zle -N zle-run-navi
zle -N zle-skim-dir
zle -N zle-skim-dirs

# Use bash-style word separators (such as dirs).
autoload -U select-word-style && select-word-style bash

# Use emacs key bindings
bindkey -e

# [PageUp] - Up a line of history
if [[ -n "${terminfo[kpp]}" ]]; then
  bindkey -M emacs "${terminfo[kpp]}" up-line-or-history
  bindkey -M viins "${terminfo[kpp]}" up-line-or-history
  bindkey -M vicmd "${terminfo[kpp]}" up-line-or-history
fi

# [PageDown] - Down a line of history
if [[ -n "${terminfo[knp]}" ]]; then
  bindkey -M emacs "${terminfo[knp]}" down-line-or-history
  bindkey -M viins "${terminfo[knp]}" down-line-or-history
  bindkey -M vicmd "${terminfo[knp]}" down-line-or-history
fi

# Start typing + [Up-Arrow] - fuzzy find history forward
if [[ -n "${terminfo[kcuu1]}" ]]; then
  bindkey -M emacs "${terminfo[kcuu1]}" up-line-or-beginning-search
  bindkey -M viins "${terminfo[kcuu1]}" up-line-or-beginning-search
  bindkey -M vicmd "${terminfo[kcuu1]}" up-line-or-beginning-search
fi

# Start typing + [Down-Arrow] - fuzzy find history backward
if [[ -n "${terminfo[kcud1]}" ]]; then
  bindkey -M emacs "${terminfo[kcud1]}" down-line-or-beginning-search
  bindkey -M viins "${terminfo[kcud1]}" down-line-or-beginning-search
  bindkey -M vicmd "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Home] - Go to beginning of line
if [[ -n "${terminfo[khome]}" ]]; then
  bindkey -M emacs "${terminfo[khome]}" beginning-of-line
  bindkey -M viins "${terminfo[khome]}" beginning-of-line
  bindkey -M vicmd "${terminfo[khome]}" beginning-of-line
fi
# [End] - Go to end of line
if [[ -n "${terminfo[kend]}" ]]; then
  bindkey -M emacs "${terminfo[kend]}"  end-of-line
  bindkey -M viins "${terminfo[kend]}"  end-of-line
  bindkey -M vicmd "${terminfo[kend]}"  end-of-line
fi

# [Shift-Tab] - move through the completion menu backwards
if [[ -n "${terminfo[kcbt]}" ]]; then
  bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete
  bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete
  bindkey -M vicmd "${terminfo[kcbt]}" reverse-menu-complete
fi

# [Backspace] - delete backward
bindkey -M emacs '^?' backward-delete-char
bindkey -M viins '^?' backward-delete-char
bindkey -M vicmd '^?' backward-delete-char

# [Delete] - delete forward
if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey -M emacs "${terminfo[kdch1]}" delete-char
  bindkey -M viins "${terminfo[kdch1]}" delete-char
  bindkey -M vicmd "${terminfo[kdch1]}" delete-char
else
  bindkey -M emacs "^[[3~" delete-char
  bindkey -M viins "^[[3~" delete-char
  bindkey -M vicmd "^[[3~" delete-char

  bindkey -M emacs "^[3;5~" delete-char
  bindkey -M viins "^[3;5~" delete-char
  bindkey -M vicmd "^[3;5~" delete-char
fi

# [Ctrl-Delete] - delete whole forward-word
bindkey -M emacs '^[[3;5~' kill-word
bindkey -M viins '^[[3;5~' kill-word
bindkey -M vicmd '^[[3;5~' kill-word

# [Ctrl-RightArrow] - move forward one word
bindkey -M emacs '^[[1;5C' forward-word
bindkey -M viins '^[[1;5C' forward-word
bindkey -M vicmd '^[[1;5C' forward-word

# [Ctrl-LeftArrow] - move backward one word
bindkey -M emacs '^[[1;5D' backward-word
bindkey -M viins '^[[1;5D' backward-word
bindkey -M vicmd '^[[1;5D' backward-word

bindkey      '\ew' kill-region # kill from the cursor to the mark.
# bindkey       '^r' history-incremental-search-backward      # [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.
bindkey ' ' magic-space # [Space] - history expansion
bindkey '\C-x\C-e' edit-command-line # Edit the current command line in $EDITOR
bindkey "\C-x\C-x" zle-run-navi
bindkey "^[m" copy-prev-shell-word
bindkey "^[e" edit-command-line
bindkey "^[d"  zle-skim-dirs
bindkey "^[n"  zle-run-navi
bindkey "\C-g" zle-run-navi
bindkey "^[f"  zle-skim-dir
bindkey '\C-x\C-e' edit-command-line
bindkey '\C-k' up-line-or-history
bindkey '\C-j' down-line-or-history
bindkey '\C-h' backward-word
bindkey '\C-w' backward-kill-word
bindkey '^[h'  run-help
bindkey '\C-b' backward-word
bindkey '\C-a' beginning-of-line
bindkey '\C-e' end-of-line
bindkey '\C-f' forward-word
bindkey '\C-l' forward-word
bindkey " "    expand-alias-space
bindkey -M isearch " " magic-space

#=======================================================================
# maybe-eval-bin direnv hook zsh
# maybe-eval-bin navi widget zsh
# # maybe-eval-bin starship init zsh
# maybe-eval-bin zoxide init zsh
# maybe-eval-bin docc completion zsh

# maybe-source   "$HOME/.aliases.sh"
maybe-source   "$HOME/.cargo/env"
maybe-source   "$HOME/.zshrc.local"

