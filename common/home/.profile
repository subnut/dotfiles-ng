[ -f "$HOME/.shrc" ] &&
  export ENV="$HOME/.shrc"
alias exists='command -v >/dev/null'

exists zsh &&
  export SHELL="$(command -v zsh)"

exists ssh-agent && {
  eval `ssh-agent -s`; ssh-add
  export _SSH_AUTH_SOCK="$SSH_AUTH_SOCK"; unset SSH_AUTH_SOCK
  export _SSH_AGENT_PID="$SSH_AGENT_PID"; unset SSH_AGENT_PID
}

# Wayland WMs
wmselect() {
  for wm in sway river Hyprland hyprland; do
    if exists $wm; then
      set -- "$@" $wm
    fi
  done
  i=0
  >&2 echo
  >&2 echo $i: '<none>'
  for wm in "$@"; do
    i=$(( i + 1 ))
    >&2 echo $i: $wm
  done
  if [ $i -gt 0 ]; then
    while true; do
      >&2 echo
      >&2 printf %s "Choose your option [0-$i] [default=1]: "
      read ANS
      if [ -z "$ANS" ]; then
        ANS=1
        break
      fi
      if printf %s "$ANS" | grep -q "[0-$i]"; then
        break
      fi
      >&2 echo Invalid input
    done
    unset -v i
    if [ $ANS -eq 0 ]; then
      return
    else
      eval "echo \${$ANS}"
    fi
  fi
}
wm=$(wmselect); unset -f wmselect
if ! [ -z "$wm" ]; then
  export GDK_BACKEND=wayland
  export QT_QPA_PLATFORM=wayland  # needs qt5-wayland installed
  export MOZ_ENABLE_WAYLAND=1     # for firefox
  if exists dbus-run-session
    then dbus-run-session $wm
    else $wm
  fi
else
  eval "$SHELL"
fi

exists ssh-agent && {
  export SSH_AUTH_SOCK="$_SSH_AUTH_SOCK"; unset _SSH_AUTH_SOCK
  export SSH_AGENT_PID="$_SSH_AGENT_PID"; unset _SSH_AGENT_PID
  eval `ssh-agent -sk`
}

exit
# vim: et sw=2 ts=2 sts=2 ft=sh isk+=-
