# Lamina Vault local configuration.
# Copy to ~/.config/lamina/vault.zsh and keep the live file out of Git.

# Restic encrypts everything locally; rclone only transports encrypted data.
export LAMINA_VAULT_REPOSITORY="rclone:dropbox:Lamina/Vault"

# Recommended for unattended launchd backups: create this 0600 file from a
# generated password, and store the same password in 1Password.
export LAMINA_VAULT_PASSWORD_FILE="${HOME}/.config/lamina/vault-password"

# Interactive alternative. The 1Password desktop app must authorize the CLI.
# export LAMINA_VAULT_PASSWORD_COMMAND='op read "op://Personal/Lamina Vault/password"'

# Optional: identify this machine in restic snapshots.
export LAMINA_VAULT_HOST="$(scutil --get ComputerName 2>/dev/null || hostname -s)"
