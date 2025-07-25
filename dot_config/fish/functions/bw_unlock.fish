function bw_unlock
    # Unlock the vault and export the session key to BW_SESSION
    set -gx BW_SESSION (bw unlock --raw)
    
    # Optionally, verify that the session is set
    if test -z "$BW_SESSION"
        echo "Failed to unlock Bitwarden vault."
        return 1
    end
    
    echo "Bitwarden session exported to BW_SESSION."
end
