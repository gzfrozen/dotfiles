#!/bin/bash

if [ "$SENDER" = "space_windows_change" ] || [ "$SENDER" = "aerospace_workspace_change" ]; then
  source "$CONFIG_DIR/plugins/icon_map.sh"
  for sid in $(aerospace list-workspaces --all); do
    apps="$(aerospace list-windows --workspace $sid --format "%{app-name}")"
    if [ "${apps}" == "" ]; then
      sketchybar --set space.$sid label=" —"
    else
      icon_strip=" "
      while read -r app; do
        __icon_map "$app"
        icon_strip+=" $icon_result"
      done <<< "${apps}"

      sketchybar --set space.$sid label="$icon_strip"
    fi
  done
fi

