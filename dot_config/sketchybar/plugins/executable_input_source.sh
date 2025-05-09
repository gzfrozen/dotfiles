#!/bin/bash

# Function to get current input source
get_current_input() {
  # Using macism to get current input source
  current=$(macism)

  # Set icon and color based on input method
  case "$current" in
    "com.apple.keylayout.ABC" | "com.apple.keylayout.US")
      icon="􂐦"
      source="EN"
      ;;
    "com.apple.inputmethod.SCIM.ITABC" | *"Pinyin"* | *"pinyin"* | *"Chinese"*)
      icon="拼"
      source="CN"
      ;;
    *"Romaji"* | *"Hiragana"* | *"hiragana"* | *"Japanese"*)
      icon="あ"
      source="JP"
      ;;
    *)
      icon="􀇳"
      source="UNKNOWN"
      ;;
  esac
  
  # Update the sketchybar item
  sketchybar --set input_source icon="$icon" label.drawing=off
}

# Call the function when the script is executed
get_current_input

# If this script is called with the "click" argument, cycle through input methods
if [[ "$1" == "click" ]]; then
  # Call the function when the script is executed
  get_current_input
  
  case "$source" in
    "EN")
      # Switch to Pinyin
      macism com.apple.inputmethod.SCIM.ITABC
      ;;
    "CN")
      # Switch to Japanese
      macism com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese
      ;;
    "JP")
      # Switch back to US
      macism com.apple.keylayout.ABC
      ;;
    *)
      # Default to US
      macism com.apple.keylayout.ABC
      ;;
  esac
fi
