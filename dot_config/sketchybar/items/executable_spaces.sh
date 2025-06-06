#!/bin/bash

declare -A monitors_id
declare -A monitors_name
while IFS="|" read -r monitor_name monitor_id display_id; do
  # Trim whitespace from each field
  monitor_name=$(echo "$monitor_name" | xargs)
  monitor_id=$(echo "$monitor_id" | xargs)
  display_id=$(echo "$display_id" | xargs)
  
  monitors_id["$monitor_id"]="$display_id"
  monitors_name["$monitor_id"]="$monitor_name"
done < <(aerospace list-monitors --format '%{monitor-name}|%{monitor-id}|%{monitor-appkit-nsscreen-screens-id}')

for monitor_id in "${!monitors_id[@]}"; do
  monitor_name="${monitors_name[$monitor_id]}"
  
  for sid in $(aerospace list-workspaces --monitor $monitor_id); do
    # Filter workspaces based on monitor name
    if [[ "$monitor_name" == "Built-in Retina Display" ]]; then
      # For Built-in Retina Display, only allow Q, W, E, R
      if [[ ! "$sid" =~ ^[QWER]$ ]]; then
        continue
      fi
    else
      # For other monitors, allow any except Q, W, E, R
      if [[ "$sid" =~ ^[QWER]$ ]]; then
        continue
      fi
    fi
    
    sketchybar --add item space.$sid left \
      --subscribe space.$sid aerospace_workspace_change \
      --set space.$sid \
            display=${monitors_id["$monitor_id"]}\
            background.color=$ACCENT_COLOR \
            background.drawing=off \
            background.height=18 \
            background.corner_radius=3 \
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

sketchybar --add bracket spaces '/space\..*/'
