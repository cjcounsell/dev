#!/usr/bin/env bash

module_check() {
    [[ -f "$HOME/.ssh/id_ed25519" ]]
}

module_install() {
    if [[ -z "${BW_SSH_KEY_ID:-}" ]]; then
        error_exit "BW_SSH_KEY_ID not set"
    fi
    
    bw_ensure_session
    
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    log_info "Fetching SSH keys"
    bw get item "$BW_SSH_KEY_ID" | jq -r '.sshKey.privateKey' > "$HOME/.ssh/id_ed25519"
    chmod 600 "$HOME/.ssh/id_ed25519"
    
    bw get item "$BW_SSH_KEY_ID" | jq -r '.sshKey.publicKey' > "$HOME/.ssh/id_ed25519.pub"
    chmod 644 "$HOME/.ssh/id_ed25519.pub"
    
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_ed25519"
    
    if [[ -d "$DEV_ROOT/.git" ]]; then
        git -C "$DEV_ROOT" remote set-url origin git@github.com:cjcounsell/dev
    fi
}
