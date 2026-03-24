# SSH agent - start once per login session and load all keys from ~/.ssh/
# Stored in conf.d/ so fish auto-loads it on startup.

set -l agent_env "$HOME/.ssh/agent-env.fish"

function __ssh_agent_start
    ssh-agent -c | sed 's/^echo/#echo/' > "$agent_env"
    chmod 600 "$agent_env"
    source "$agent_env"
end

function __ssh_load_keys
    # Collect private keys: files that have a matching .pub counterpart,
    # or match common private key name patterns, excluding known non-key files.
    set -l ssh_dir "$HOME/.ssh"
    set -l keys_to_add

    for f in "$ssh_dir"/*
        set -l base (basename "$f")
        # Skip obviously non-key files
        switch "$base"
            case '*.pub' 'known_hosts' 'known_hosts.old' 'config' 'authorized_keys' 'agent-env.fish' 'agent-env'
                continue
        end
        # Only process regular files
        if not test -f "$f"
            continue
        end
        # Accept if a matching .pub exists OR name matches common patterns
        if test -f "$f.pub"; or string match -rq '^id_|_rsa$|_ed25519$|_ecdsa$|_dsa$' "$base"
            set -a keys_to_add "$f"
        end
    end

    if test (count $keys_to_add) -eq 0
        return
    end

    # Only add keys not already loaded (compare by fingerprint)
    set -l loaded (ssh-add -l 2>/dev/null; or true)
    for key in $keys_to_add
        set -l fp (ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')
        if test -n "$fp"; and not string match -q "*$fp*" "$loaded"
            ssh-add "$key" 2>/dev/null; or true
        end
    end
end

# Re-attach to an existing agent or start a new one
if test -f "$agent_env"
    source "$agent_env" >/dev/null
end

if not ssh-add -l >/dev/null 2>&1
    __ssh_agent_start
end

__ssh_load_keys
