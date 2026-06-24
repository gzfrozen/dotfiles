#!/bin/bash

while IFS="|" read -r monitor_name monitor_id display_id; do
  # Trim whitespace from each field
  monitor_name=$(echo "$monitor_name" | xargs)
  monitor_id=$(echo "$monitor_id" | xargs)
  display_id=$(echo "$display_id" | xargs)
  monitors_id["$monitor_id"]="$display_id"
  monitors_name["$monitor_id"]="$monitor_name"
done < <(aerospace list-monitors --format '%{monitor-name}|%{monitor-id}|%{monitor-appkit-nsscreen-screens-id}')

# Build complete display mapping using jq
sketchybar_json=$(sketchybar --query displays)

# Find arrangement-id for built-in display (DirectDisplayID=1)
builtin_arrangement_id=$(echo "$sketchybar_json" | jq -r '.[] | select(.DirectDisplayID == 1) | ."arrangement-id"')

# Get ordered list of external display arrangement-ids (excluding built-in), sorted ascending
external_arrangement_ids=($(echo "$sketchybar_json" | jq -r '.[] | select(.DirectDisplayID != 1) | ."arrangement-id"' | sort -n))

# Map each aerospace external monitor to its NSScreen/arrangement display id.
# monitors_id[$mid] is the monitor-appkit-nsscreen-screens-id, which equals
# sketchybar's arrangement-id. Use this as the single source of truth for ordering.
external_monitor_ids=()
builtin_exists=false
builtin_monitor_id=""

for mid in "${!monitors_name[@]}"; do
  if [[ "${monitors_name[$mid]}" == "Built-in Retina Display" ]]; then
    builtin_exists=true
    builtin_monitor_id="$mid"
  else
    external_monitor_ids+=("$mid")
  fi
done

# Sort external aerospace monitor-ids by their arrangement-id (physical order),
# NOT by the raw monitor-id string.
sorted_external_monitor_ids=($(
  for mid in "${external_monitor_ids[@]}"; do
    echo "${monitors_id[$mid]} $mid"
  done | sort -n | awk '{print $2}'
))

# Create mapping: aerospace monitor_id -> sketchybar arrangement-id.
# Both lists are now ordered by arrangement-id, so indices line up.
for i in "${!sorted_external_monitor_ids[@]}"; do
  mid="${sorted_external_monitor_ids[$i]}"
  monitor_to_display["$mid"]="${monitors_id[$mid]}"
done

# Add built-in mapping
if [[ "$builtin_exists" == true && -n "$builtin_arrangement_id" ]]; then
  monitor_to_display["$builtin_monitor_id"]="$builtin_arrangement_id"
fi

# Count only real, distinct monitors
monitor_count=${#monitors_id[@]}

for monitor_id in "${!monitors_id[@]}"; do
  monitor_name="${monitors_name[$monitor_id]}"
  first_external="${sorted_external_monitor_ids[0]}"
  second_external="${sorted_external_monitor_ids[1]}"

  # Filter workspaces based on monitor configuration
  for sid in $(aerospace list-workspaces --monitor "$monitor_id"); do
    show_space=false

    if [[ "$builtin_exists" == true && $monitor_count -eq 1 ]]; then
      # MacBook only
      [[ "$sid" =~ ^[1234]$ ]] && show_space=true

    elif [[ "$builtin_exists" == true && $monitor_count -eq 2 ]]; then
      # MacBook + one external
      if [[ "$monitor_name" == "Built-in Retina Display" ]]; then
        [[ "$sid" =~ ^[1234]$ ]] && show_space=true
      else
        [[ "$sid" =~ ^[ABCD]$ ]] && show_space=true
      fi

    elif [[ "$builtin_exists" == true && $monitor_count -ge 3 ]]; then
      # MacBook + two or more externals
      if [[ "$monitor_name" == "Built-in Retina Display" ]]; then
        [[ "$sid" =~ ^[QWER]$ ]] && show_space=true
      elif [[ "$monitor_id" == "$first_external" ]]; then
        [[ "$sid" =~ ^[1234]$ ]] && show_space=true
      elif [[ "$monitor_id" == "$second_external" ]]; then
        [[ "$sid" =~ ^[ABCD]$ ]] && show_space=true
      fi

    elif [[ "$builtin_exists" == false && $monitor_count -eq 2 ]]; then
      # Mac mini + two externals
      if [[ "$monitor_id" == "$first_external" ]]; then
        [[ "$sid" =~ ^[1234]$ ]] && show_space=true
      elif [[ "$monitor_id" == "$second_external" ]]; then
        [[ "$sid" =~ ^[ABCD]$ ]] && show_space=true
      fi
    fi

    [[ "$show_space" == true ]] || continue

    # Get mapped sketchybar display ID
    target_display="${monitor_to_display[$monitor_id]}"

    sketchybar --add item space.$sid left \
      --subscribe space.$sid aerospace_workspace_change \
      --set space.$sid \
      display=$target_display background.color=$ACCENT_COLOR \
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
