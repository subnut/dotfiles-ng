[ -f "$HOME/.shrc" ] &&
  export ENV="$HOME/.shrc"

command -v zsh >/dev/null &&
  export SHELL="$(command -v zsh)"

if command -v sway >/dev/null; then
  printf '%s' 'Run Sway? [Y/n] '; read ANSWER
  if [ -z "$ANSWER" ] || printf '%s' "$ANSWER" | grep -q '^[Yy]'; then
    if command -v dbus-run-session >/dev/null
      then exec dbus-run-session sway
      else exec sway
    fi
  fi
fi

# vim: et sw=2 ts=2 sts=2 ft=sh isk+=-
