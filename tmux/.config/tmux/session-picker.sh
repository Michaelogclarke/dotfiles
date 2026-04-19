#!/usr/bin/env bash

MENU_ARGS=("-T" "#[align=centre] Sessions " "-x" "C" "-y" "C")

i=1
while IFS='|' read -r name windows attached; do
    label="$name  (${windows}w)"
    [ "$attached" = "1" ] && label="$name *  (${windows}w)"
    MENU_ARGS+=("$label" "$i" "switch-client -t '$name'")
    ((i++))
done < <(tmux list-sessions -F "#{session_name}|#{session_windows}|#{session_attached}" 2>/dev/null)

MENU_ARGS+=(
    "" "" ""
    "New session"          "n" "command-prompt -p 'Name:' 'new-session -d -s %% ; switch-client -t %%'"
    "Rename session"       "r" "command-prompt -p 'Rename:' 'rename-session %%'"
    "Last session"         "l" "switch-client -l"
)

tmux display-menu "${MENU_ARGS[@]}"
