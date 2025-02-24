#!/bin/bash

sketchybar --add event aerospace_workspace_change

declare -A monitors
while IFS=" " read -r monitor_id display_id; do
  monitors["$monitor_id"]="$display_id"
done < <(aerospace list-monitors --format '%{monitor-id} %{monitor-appkit-nsscreen-screens-id}')

for monitor_id in "${monitors[@]}"; do
  for sid in $(aerospace list-workspaces --monitor $monitor_id); do
    sketchybar --add item space.$sid left \
      --subscribe space.$sid aerospace_workspace_change \
      --set space.$sid \
            display=${monitors["$monitor_id"]}\
            background.color=0x44ffffff \
            background.corner_radius=5 \
            background.height=20 \
            background.drawing=off \
            label="$sid" \
            label.padding_right=12 \
            click_script="aerospace workspace $sid" \
            script="$CONFIG_DIR/plugins/aerospace.sh $sid"
  done
done

sketchybar --add item chevron left \
           --set chevron icon= label.drawing=off \
           --add item front_app left \
           --set front_app icon.drawing=off script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched

