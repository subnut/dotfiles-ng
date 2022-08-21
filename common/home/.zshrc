## Source $ENV if it exists
(( ${+ENV} )) && [[ -f "$ENV" ]] && source "$ENV"


## `zsh-newuser-install`
HISTFILE=~/.zsh_history
HISTSIZE=30000
SAVEHIST=30000


## `compinstall`
zstyle ':completion:*' completer _complete _approximate _ignored
zstyle ':completion:*' matcher-list '+m:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+m:{[:lower:][:upper:]}={[:upper:][:lower:]}' '' '+m:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' menu select
zstyle :compinstall filename '$HOME/.zshrc'
autoload -Uz compinit
compinit


## Config
setopt AUTOPUSHD
setopt CORRECT                  # [nyae]? (Also see $SPROMPT)
setopt EXTENDED_HISTORY         # add timestamp to .zsh_history
setopt HIST_IGNORE_DUPS         # ignore duplicate
setopt HIST_IGNORE_SPACE        # command prefixed by space are incognito
setopt HIST_REDUCE_BLANKS       # RemoveTrailingWhiteSpace
setopt HIST_VERIFY              # VERY IMPORTANT. `sudo !!` <enter> doesn't execute directly. instead, it just expands.
setopt INC_APPEND_HISTORY       # immediately _append_ to HISTFILE instead of _replacing_ it _after_ the shell exits
setopt INTERACTIVE_COMMENTS     # Allow comments using '#' in interactive mode
zmodload zsh/terminfo
typeset -ga pre{cmd,exec}_functions


## PATH
export PATH=./:$PATH
typeset -U PATH path    # remove duplicates


## Set terminal title
function title_precmd   { print -Pn "\e]0;%n@%m: %~\a"; }       # user@host: ~/cur/dir
function title_preexec  { printf "\e]0;%s\a" "${2//    / }"; }  # name of running command
precmd_functions+=title_precmd
preexec_functions+=title_preexec


## Other config files
export ZDOTDIR=${ZDOTDIR-$HOME}
source $ZDOTDIR/.zsh/prompt.zsh
source $ZDOTDIR/.zsh/keybindings.zsh
source $ZDOTDIR/.zsh/named_directories.zsh


## oh-my-zsh scripts
[[ -d $ZDOTDIR/.zsh/OMZ_snippets ]] || mkdir -p $ZDOTDIR/.zsh/OMZ_snippets
[[ -f $ZDOTDIR/.zsh/OMZ_snippets/clipboard.zsh ]] || \
    curl -L http://github.com/ohmyzsh/ohmyzsh/raw/master/lib/clipboard.zsh \
    -o $ZDOTDIR/.zsh/OMZ_snippets/clipboard.zsh
source $ZDOTDIR/.zsh/OMZ_snippets/clipboard.zsh


## Terminal compatibility/tweaks
(( ${+commands[stty]} )) && {
    <>$TTY stty -echo                   # Don't echo keypresses while zsh is starting
    <>$TTY stty stop undef              # unbind ctrl-s from stty stop to allow fwd-i-search
    <>$TTY stty erase ${terminfo[kbs]}  # vim :term has ^H in $terminfo[kbs] but sets ^? in stty erase
}

## ZSH-specific
(( ${+commands[curl]} )) && alias curl='noglob curl'


## Custom completions
(( ${+functions[compdef]} )) && {
    # Enable completion for any function aliased to ssh
    (( ${+functions[${aliases[ssh]}]} )) && compdef "${aliases[ssh]}=ssh"
}
(( ${+commands[light]} )) && [[ ${commands[light]} == $HOME/.local/bin/light ]] && {
    alias light='noglob light'
    compdef _localbin_light light
    _localbin_light() {
        [[ ${#words} -eq 3 ]] || return
        [[ -d /sys/class/backlight ]] || return
        compadd ${$(echo /sys/class/backlight/*)##*/}
    }
}


## Custom commands
(( ${+functions[_xbps]} )) && _xbps && {
    (( ${+functions[compdef]} )) &&
        compdef _xbps_comp xbps
    _xbps_comp() {
        case ${#words} in
            (2) compadd 'search'
                compadd ${${(Mk)commands%xbps-*}#xbps-};;
            (*) words=("xbps-${words[2]}" "${(@)words[3,-1]}"); service=${words[1]}; CURRENT=$(( CURRENT - 1 ))
                _xbps "$@";;
        esac
    }
    xbps() {
        (( $# )) || return 0
        (( ${+commands[xbps-$1]} )) || [ $1 = search ] || { echo "$0: command not found: xbps-$1"; return 127; }
        local ANSWER
        (( $( (){echo ${(%)1}} '%(#.1.0)' ) )) && ANSWER=n  # i am root.
        case $1 in
            (search)
                # Custom command
                shift; xbps-query -Rs "$*"; return $?;;
            (checkvers|create|dgraph|digest|fbulk|fetch|rindex|query)
                # These (maybe) never need root
                ANSWER=n;;
            (install|remove|pkgdb)
                # These (almost) always need root
                [ -z "$ANSWER" ] && ANSWER=y;;
            (*)
                while [ -z "$ANSWER" ]; do
                    read -k ANSWER'?Run as root? [Y/n/a] '; [[ $ANSWER == $'\n' ]] || echo;
                    case $ANSWER in
                        ([yYnNaN]|$'\n') break;;
                        (*) ANSWER=;;
                    esac
                done
        esac
        case ${(L)ANSWER} in
            (n) "xbps-$1" ${(@)@[2,-1]};;
            (*) if   (( ${+commands[doas]} )); then doas "xbps-$1" ${(@)@[2,-1]}
                elif (( ${+commands[sudo]} )); then sudo "xbps-$1" ${(@)@[2,-1]}
                elif (( ${+commands[su]}   )); then su -c "xbps-$1 ${(@)@[2,-1]}"; fi;;
        esac
    }
}

# vim: nowrap sw=0 ts=4 sts=4 et
