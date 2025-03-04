#! /bin/sh

# Terminate already running bar instances
 killall -q polybar

#wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lauch bar
polybar toph &

if [[ $(xrandr -q | grep 'HDMI-A-0 connected') ]]; then
  polybar top_external &
fi
