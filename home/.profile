[ -f "$HOME/.shrc" ] &&
  export ENV="$HOME/.shrc"

alias exists='command -v >/dev/null'

exists zsh &&
  export SHELL="$(command -v zsh)"

exists ssh-agent && exists zenity &&
  eval `SSH_ASKPASS="$HOME/.ssh/askpass.sh" SSH_ASKPASS_REQUIRE=force ssh-agent -s`

if exists sway; then
  printf '%s' 'Run Sway? [Y/n] '; read ANSWER
  if [ -z "$ANSWER" ] || printf '%s' "$ANSWER" | grep -q '^[Yy]'; then
    if exists dbus-run-session
      then dbus-run-session sway
      else sway
    fi
  fi
fi

exists ssh-agent &&
  ssh-agent -k

# vim: et sw=2 ts=2 sts=2 ft=sh isk+=-
