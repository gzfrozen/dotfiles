#!/bin/bash

# Unlock the vault and export the session key to BW_SESSION
export BW_SESSION=$(bw unlock --raw)

# Optionally, verify that the session is set
if [ -z "$BW_SESSION" ]; then
  echo "Failed to unlock Bitwarden vault."
  exit 1
fi

echo "Bitwarden session exported to BW_SESSION."
