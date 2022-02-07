## We need to run commands inside our prompts
setopt PROMPT_SUBST

## Helper function to allow running commands inside $PROMPT without changing $?
function prompt_exec {
    local exitcode=$?
    "$@"
    return $exitcode
}

## Helper function to print something with prompt expansion
function prompt_print {
    print -n -- "${(%)*}"
}

## Array of colors to use in prompts
typeset -gA prompt_colors
if [[ ${terminfo[colors]} -eq 256 ]]; then
    prompt_colors[red]=196
    prompt_colors[grey]=244
    prompt_colors[green]=34
else
    prompt_colors[red]=1
    prompt_colors[grey]=7
    prompt_colors[green]=2
fi

TRANSIENT_PROMPT=
TRANSIENT_PROMPT+="%F{${prompt_colors[grey]}}"
TRANSIENT_PROMPT+='%(!.#.$)'
TRANSIENT_PROMPT+='%f'
TRANSIENT_PROMPT+=' '

_PROMPT_PROMPT=
_PROMPT_PROMPT+='%B'
_PROMPT_PROMPT+='%(?.%F{'${prompt_colors[green]}'}.%F{'${prompt_colors[red]}'})'
_PROMPT_PROMPT+='%(!.#.$)'
_PROMPT_PROMPT+='%f'
_PROMPT_PROMPT+='%b'
_PROMPT_PROMPT+=' '

# _PROMPT_PROMPT='%F{'$${prompt_colors[grey]}'}$%f'
# _PROMPT_PROMPT='%B%(?.%F{green}.%F{red})%(!.#.$)%f%b'


function set_prompt {
    PROMPT=
    PROMPT=${PROMPT}'%B%~%b'
    PROMPT=${PROMPT}'$(prompt_exec echoti hpa $((COLUMNS)))'
    PROMPT=${PROMPT}'%(?..$(prompt_exec echoti cub ${#?})%B%F{'${prompt_colors[red]}'}%?%f%b)'
    PROMPT=${PROMPT}$'\n'
    PROMPT=${PROMPT}${_PROMPT_PROMPT}
}
set_prompt


## Show execution time in RPROMPT
zmodload zsh/datetime
typeset -ga _epochtime_precmd
typeset -ga _epochtime_preexec
function _exectime {
    # Define this function AFTER the very first prompt has been shown
    # Otherwise, it shows a bogus value in the RPROMPT, since
    # _epochtime_preexec is not defined yet
    function _exectime {
        RPROMPT="%f"
        if [[ ${_epochtime_preexec[1]} -eq ${_epochtime_precmd[1]} ]]; then
            local nanosec=$(( _epochtime_precmd[2] - _epochtime_preexec[2] ))
            local sec="$(( nanosec / 1000000000.0 ))"
            RPROMPT="${sec:0:5}s$RPROMPT"   # 0.xxx -- 5 chars
        else
            local sec
            sec=$(( _epochtime_precmd[1] - _epochtime_preexec[1] ))
            RPROMPT="$(( sec % 60 ))s$RPROMPT"
            [[ $(( sec /= 60 )) -gt 0 ]] &&
                RPROMPT="$(( sec % 60 ))m $RPROMPT"     # mins
            [[ $(( sec /= 60 )) -gt 0 ]] &&
                RPROMPT="$(( sec % 24 ))h $RPROMPT"     # hours
            [[ $(( sec /= 60 )) -gt 0 ]] &&
                RPROMPT="$(( sec % 24 ))d $RPROMPT"     # days
        fi
        RPROMPT="%F{${prompt_colors[grey]}}$RPROMPT"
    }
}
function _exectime_precmd   {
    if [[ _epochtime_precmd[1] -lt _epochtime_preexec[1] ]] ||
        [[ _epochtime_precmd[2] -lt _epochtime_preexec[2] ]]
    then _epochtime_precmd=($epochtime)
    fi
}
function _exectime_preexec  {
    _epochtime_preexec=($epochtime)
}
preexec_functions+=_exectime_preexec
precmd_functions+=_exectime_precmd
precmd_functions+=_exectime


## Show warning if buffer empty
EMPTY_BUFFER_WARNING_TEXT='Buffer empty!'
EMPTY_BUFFER_WARNING_COLOR=${prompt_colors[red]}
zle -N accept-line
function accept-line {
    if [[ $#BUFFER -ne 0 ]]
    then zle .accept-line
    else
        echoti cud1
        # The next two lines MUST NOT BE INTERCHANGED
        prompt_print "${_PROMPT_PROMPT}"
        echoti cuu1
        echoti sc
        echoti cud 1
        echoti hpa 0
        prompt_print "%F{$EMPTY_BUFFER_WARNING_COLOR}"$EMPTY_BUFFER_WARNING_TEXT'%f'
        echoti ed
        echoti rc
        # For the meaning of cud1,ed,hpa,... see terminfo(5)

        # Create function that resets warning
        function _empty_buffer_warning_reset {
            unfunction _empty_buffer_warning_reset
            echoti sc
            echoti cud 1
            echoti hpa 0
            printf "%${#EMPTY_BUFFER_WARNING_TEXT}s"
            echoti ed
            echoti rc
        }

        # Reset the warning if any character is typed
        zle -N self-insert
        function self-insert {
            unfunction self-insert
            zle .self-insert
            zle -A .self-insert self-insert
            _empty_buffer_warning_reset
        }
    fi
}



## Show vi mode
#function _vi_mode_show_mode {
#    echoti sc
#    echoti cud 1
#    echoti hpa 0
#    echoti el
#    (( ${#1} )) && prompt_print '%B'$1'%b'
#    echoti rc
#}
#
#function _vi_mode-visual-mode { _vi_mode_show_mode VISUAL; zle .visual-mode }
#zle -N {,_vi_mode-}visual-mode
#function _vi_mode-vi-replace { _vi_mode_show_mode REPLACE; zle .vi-replace }
#zle -N {,_vi_mode-}vi-replace
#function _vi_mode-overwrite-mode { _vi_mode_show_mode OVERWRITE; zle .overwrite-mode }
#zle -N {,_vi_mode-}overwrite-mode
#
#function _vi_mode-zle-keymap-select {
#    local text
#    [[ $KEYMAP = vicmd ]] && text=NORMAL
#    [[ $KEYMAP = viins ]] && text=INSERT
#    _vi_mode_show_mode $text
#}
#autoload -Uz add-zle-hook-widget
#add-zle-hook-widget {,_vi_mode-zle-}keymap-select


## Transient prompt
[[ -c /dev/null ]]  ||  return
zmodload zsh/system ||  return

typeset -g _transient_prompt_newline=
function _transient_prompt_set_prompt {
    set_prompt
    PROMPT='$_transient_prompt_newline'$PROMPT
}; _transient_prompt_set_prompt

zle -N clear-screen _transient_prompt_widget-clear-screen
function _transient_prompt_widget-clear-screen {
    _transient_prompt_newline=
    zle .clear-screen
}

zle -N send-break _transient_prompt_widget-send-break
function _transient_prompt_widget-send-break {
    _transient_prompt_widget-zle-line-finish
    zle .send-break
}

zle -N zle-line-finish _transient_prompt_widget-zle-line-finish
function _transient_prompt_widget-zle-line-finish {
    (( ! _transient_prompt_fd )) && {
        sysopen -r -o cloexec -u _transient_prompt_fd /dev/null
        zle -F $_transient_prompt_fd _transient_prompt_restore_prompt
    }
    zle && PROMPT=$TRANSIENT_PROMPT RPROMPT= zle reset-prompt && zle -R
}

function _transient_prompt_restore_prompt {
    exec {1}>&-
    (( ${+1} )) && zle -F $1
    _transient_prompt_fd=0
    _transient_prompt_set_prompt
    zle reset-prompt
    zle -R
}

(( ${+precmd_functions} )) || typeset -ga precmd_functions
(( ${#precmd_functions} )) || {
    do_nothing() {true}
    precmd_functions=(do_nothing)
}

precmd_functions+=_transient_prompt_precmd
function _transient_prompt_precmd {
    # We define _transient_prompt_precmd in this way because we don't want
    # _transient_prompt_newline to be defined on the very first precmd.
    TRAPINT() {zle && _transient_prompt_widget-zle-line-finish; return $(( 128 + $1 ))}
    function _transient_prompt_precmd {
        TRAPINT() {zle && _transient_prompt_widget-zle-line-finish; return $(( 128 + $1 ))}
        _transient_prompt_newline=$'\n'
    }
}


# vim: sw=0 ts=4 sts=4 et
