#!/bin/sh

# Zenity interprets a single underscore as the 'mnemonic character'
# To print a single underscore, we need to have two underscores in the --text
# See: https://bugzilla.redhat.com/show_bug.cgi?id=1696157
TEXT="$(echo "$1" | sed s/_/__/g)"

if [ "$SSH_ASKPASS_PROMPT" = confirm ]
then zenity --text="$TEXT" --title=ssh-askpass --question
else zenity --text="$TEXT" --title=ssh-askpass --entry --hide-text
fi

## Logging purposes
# cd "$(dirname "$0")"
# echo '$1:' "$1"  >> log.txt
# echo '$TEXT:' "$TEXT"  >> log.txt
# env | grep ^SSH_ >> log.txt
# return 0
