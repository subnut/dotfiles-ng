#!/bin/sh
# Default acpi script that takes an entry for all actions

# NOTE: This is a 2.6-centric script.  If you use 2.4.x, you'll have to
#       modify it to not use /sys

# $1 should be + or - to step up or down the brightness.
step_backlight() {
    # for backlight in /sys/class/backlight/*/; do
    for backlight in /sys/class/backlight/amdgpu_bl0/; do
        [ -d "$backlight" ] || continue
        max=$(cat "$backlight/max_brightness")
        step=$(( max / 40 ))
        [ "$step" -gt "1" ] || step=1 #fallback if gradation is too low
        val=$(( $(cat "$backlight/brightness") $1 step ))
        [ $val -lt 0   ] && val=0
        [ $val -gt $max ] && val=$max
        printf %s $val >"$backlight/brightness"
    done
}

#minspeed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
#maxspeed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
#setspeed="/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed"

alias pactl="pactl -s $(loginctl show-user subnut | sed -n s/^RuntimePath=//p)/pulse/native"
case "$1" in
#[
#    button/power)
#        case "$2" in
#            PBTN|PWRF)
#                logger "PowerButton pressed: $2, shutting down..."
#                shutdown -P now
#                ;;
#            *)  logger "ACPI action undefined: $2" ;;
#        esac
#        ;;
#    button/sleep)
#        case "$2" in
#            SBTN|SLPB)
#                # suspend-to-ram
#                logger "Sleep Button pressed: $2, suspending..."
#                zzz
#                ;;
#            *)  logger "ACPI action undefined: $2" ;;
#        esac
#        ;;
#    ac_adapter)
#        case "$2" in
#            AC|ACAD|ADP0)
#                case "$4" in
#                    00000000)
#                        printf '%s' "$minspeed" >"$setspeed"
#                        #/etc/laptop-mode/laptop-mode start
#                    ;;
#                    00000001)
#                        printf '%s' "$maxspeed" >"$setspeed"
#                        #/etc/laptop-mode/laptop-mode stop
#                    ;;
#                esac
#                ;;
#            *)  logger "ACPI action undefined: $2" ;;
#        esac
#        ;;
#    battery)
#        case "$2" in
#            BAT0)
#                case "$4" in
#                    00000000)   #echo "offline" >/dev/tty5
#                    ;;
#                    00000001)   #echo "online"  >/dev/tty5
#                    ;;
#                esac
#                ;;
#            CPU0)
#                ;;
#            *)  logger "ACPI action undefined: $2" ;;
#        esac
#        ;;
#    button/lid)
#        case "$3" in
#            close)
#                # suspend-to-ram
#                logger "LID closed, suspending..."
#                zzz
#                ;;
#            open)
#                logger "LID opened"
#                ;;
#            *)  logger "ACPI action undefined (LID): $2";;
#        esac
#        ;;
#]
#    button/volumeup)   amixer set Master -Mq 5%+ ;;
#    button/volumedown) amixer set Master -Mq 5%- ;;
#    button/mute) amixer set Master  -q toggle ;;
#    button/f20)  amixer set Capture -q toggle ;;
    button/volumedown)  pactl set-sink-volume @DEFAULT_SINK@ -5%     ;;
    button/volumeup)    pactl set-sink-volume @DEFAULT_SINK@ +5%     ;;
    button/mute)        pactl set-sink-mute   @DEFAULT_SINK@   toggle;;
    button/f20)         pactl set-source-mute @DEFAULT_SOURCE@ toggle;;
    video/brightnessdown) step_backlight - ;;
    video/brightnessup)   step_backlight + ;;
    *) logger "ACPI group/action undefined: $1 / $2" ;;
esac

# vim:set ts=2 sw=4 ft=sh et fdm=marker fmr=[,]:
