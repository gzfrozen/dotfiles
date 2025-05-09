#!/bin/bash

sketchybar --add event input_change "AppleSelectedInputSourcesChangedNotification"
sketchybar --add item input_source right \
           --subscribe input_source input_change \
           --set input_source \
               script="$PLUGIN_DIR/input_source.sh" \
               click_script="$PLUGIN_DIR/input_source.sh click" \
