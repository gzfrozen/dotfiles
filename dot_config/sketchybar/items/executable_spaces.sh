#!/bin/bash

# declare -A monitors
while IFS=" " read -r monitor_id display_id; do
  monitors["$monitor_id"]="$display_id"
done < <(aerospace list-monitors --format '%{monitor-id} %{monitor-appkit-nsscreen-screens-id}')

for monitor_id in "${monitors[@]}"; do
  for sid in $(aerospace list-workspaces --monitor $monitor_id); do
    sketchybar --add item space.$sid left \
      --subscribe space.$sid aerospace_workspace_change \
      --set space.$sid \
            display=${monitors["$monitor_id"]}\
            background.drawing=off \
            icon=$sid \
            label.font="sketchybar-app-font:Regular:16.0" \
            label.padding_right=13 \
            label.y_offset=-1 \
            click_script="aerospace workspace $sid" \
            script="$CONFIG_DIR/plugins/space.sh $sid"
  done
done

sketchybar --add item chevron left \
           --subscribe chevron space_windows_change \
           --subscribe chevron aerospace_workspace_change \
           --set chevron icon= icon.font="Hack Nerd Font:Regular:16.0" label.drawing=off background.drawing=off script="$CONFIG_DIR/plugins/space_windows.sh"
