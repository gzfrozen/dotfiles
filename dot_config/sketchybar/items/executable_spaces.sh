#!/bin/bash

while IFS="|" read -r monitor_name monitor_id display_id; do
  # Trim whitespace from each field
  monitor_name=$(echo "$monitor_name" | xargs)
  monitor_id=$(echo "$monitor_id" | xargs)
  display_id=$(echo "$display_id" | xargs)
  
  monitors_id["$monitor_id"]="$display_id"
  monitors_name["$monitor_id"]="$monitor_name"
done < <(aerospace list-monitors --format '%{monitor-name}|%{monitor-id}|%{monitor-appkit-nsscreen-screens-id}')

# Find sketchybar arrangement-id for built-in display (DirectDisplayID=1)
# Build complete display mapping using jq
sketchybar_json=$(sketchybar --query displays)

# Find arrangement-id for built-in display (DirectDisplayID=1)
builtin_arrangement_id=$(echo "$sketchybar_json" | jq -r '.[] | select(.DirectDisplayID == 1) | ."arrangement-id"')

# Get ordered list of external display arrangement-ids (excluding built-in)
external_arrangement_ids=($(echo "$sketchybar_json" | jq -r '.[] | select(.DirectDisplayID != 1) | ."arrangement-id"'))

# Build ordered list of external aerospace monitor-ids (excluding built-in)
external_monitor_ids=()
for mid in "${!monitors_name[@]}"; do
  if [[ "${monitors_name[$mid]}" != "Built-in Retina Display" ]]; then
    external_monitor_ids+=("$mid")
  fi
done

# Sort external_monitor_ids to ensure consistent ordering
IFS=$'\n' sorted_external_monitor_ids=($(sort <<<"${external_monitor_ids[*]}")); unset IFS

# Create mapping: aerospace monitor_id -> sketchybar arrangement-id
for i in "${!sorted_external_monitor_ids[@]}"; do
  mid="${sorted_external_monitor_ids[$i]}"
  if [[ $i -lt ${#external_arrangement_ids[@]} ]]; then
    monitor_to_display["$mid"]="${external_arrangement_ids[$i]}"
  fi
done

# Add built-in mapping
for mid in "${!monitors_name[@]}"; do
  if [[ "${monitors_name[$mid]}" == "Built-in Retina Display" ]]; then
    monitor_to_display["$mid"]="$builtin_arrangement_id"
  fi
done

# Detect if only built-in display is connected
monitor_count=${#monitors_id[@]}
builtin_only=false
if [[ $monitor_count -eq 1 ]]; then
  for mid in "${!monitors_name[@]}"; do
    if [[ "${monitors_name[$mid]}" == "Built-in Retina Display" ]]; then
      builtin_only=true
    fi
  done
fi

for monitor_id in "${!monitors_id[@]}"; do
  monitor_name="${monitors_name[$monitor_id]}"
  
  for sid in $(aerospace list-workspaces --monitor $monitor_id); do
    # Filter workspaces based on monitor configuration
    if [[ "$builtin_only" == true ]]; then
      # Only built-in display connected: only show 1, 2, 3, 4
      if [[ ! "$sid" =~ ^[1234]$ ]]; then
        continue
      fi
    elif [[ $monitor_count -eq 2 ]]; then
      # Two monitors (including built-in): hide QWER spaces entirely
      if [[ "$sid" =~ ^[QWER]$ ]]; then
        continue
      fi
    else
      # 3+ monitors: show Q, W, E, R only on built-in display
      if [[ "$monitor_name" != "Built-in Retina Display" && "$sid" =~ ^[QWER]$ ]]; then
        continue
      fi
    fi
    # When external monitors exist, trust aerospace's workspace assignment
    
    # Get mapped sketchybar display ID
    target_display="${monitor_to_display[$monitor_id]}"

    sketchybar --add item space.$sid left \
      --subscribe space.$sid aerospace_workspace_change \
      --set space.$sid \
            display=$target_display\
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
