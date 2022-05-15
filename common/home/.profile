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
[ -z "$wm" ] && exists sway  && wm=sway
[ -z "$wm" ] && exists river && wm=river
printf '%s' "Run $wm? [Y/n] "; read ANSWER
if [ -z "$ANSWER" ] || printf '%s' "$ANSWER" | grep -q '^[Yy]'; then
  export GDK_BACKEND=wayland
  export QT_QPA_PLATFORM=wayland  # needs qt5-wayland installed
  exists firefox &&
    export MOZ_ENABLE_WAYLAND=1
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
  ssh-agent -k
}

exit
# vim: et sw=2 ts=2 sts=2 ft=sh isk+=-
