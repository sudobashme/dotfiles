# Lamina Vault: AI State Recovery

Lamina Vault extends the Personal OS Layer from reproducible configuration into private AI state. Its purpose is to make a dead or replaced Mac an inconvenience, not a week-long reconstruction project.

## Recovery model

Four systems have separate responsibilities:

| Layer | Owns | Does not own |
| --- | --- | --- |
| Git/dotfiles | Portable instructions, agent docs, skills, manifests, restoration code | Conversations, private memory, credentials |
| Lamina Vault | Encrypted snapshots of private AI state | Application binaries and caches |
| 1Password | Vault encryption password and account recovery information | Bulk backup data |
| Time Machine | Fast whole-machine local recovery | Sole off-site recovery copy |

Dropbox is a storage destination, not a live-state synchronization mechanism. Restic encrypts and versions the data locally, then rclone sends only encrypted repository objects to Dropbox.

## Protected applications

`lamina vault plan` is the authoritative inventory. The current policy protects:

- Codex configuration, user rules and skills, sessions, memories, goals, and state databases.
- Grok configuration, memory, sessions, projects, user skills, and plugin inventory.
- Cursor settings, snippets, custom agents/plugins, and selected global state.
- OpenClaw configuration, workspace/personality, current agent sessions, memory, tasks, flows, device identity, and channel/service configuration.

The snapshot deliberately excludes authentication files for Codex and Grok, caches, downloaded binaries, extensions, bundled skills, logs, sockets, locks, SQLite WAL/SHM files, terminal logs, and OpenClaw's large rolling `.bak` history. Reauthenticate hosted products after recovery.

SQLite files are never trusted as ordinary file copies. The staging process detects SQLite databases and recreates them through SQLite's online backup interface.

## Commands

```bash
lamina vault plan
lamina vault stage
lamina vault health
lamina vault init
lamina vault backup
lamina vault snapshots
lamina vault restore latest --target ~/Desktop/lamina-vault-restore
lamina vault retain
lamina vault verify
```

Restore is review-first: it writes only to the requested empty directory. It never replaces a live application database. This is intentional because application state formats can change between releases.

## Initial setup

### 1. Install the tools

`restic`, `rclone`, and `1password-cli` are declared in the Homebrew bundle. Install the bundle through the normal machine bootstrap, or install those formulae individually.

### 2. Configure the Dropbox adapter

Run:

```bash
rclone config
```

Create a remote named `dropbox` and complete Dropbox authorization in the browser. Verify it without exposing private contents:

```bash
rclone about dropbox:
```

Rclone's local configuration contains an access token. Do not commit it. On a replacement machine, authorize Dropbox again.

### 3. Create the encryption password

Generate a long random password in 1Password and save it as an item named `Lamina Vault`, with a password field named `password`. Do not use the 1Password account password.

For interactive backups, 1Password CLI can supply it directly:

```zsh
export LAMINA_VAULT_PASSWORD_COMMAND='op read "op://Personal/Lamina Vault/password"'
```

For unattended backups, put the same generated password in a local mode-600 file:

```bash
mkdir -p ~/.config/lamina
op read 'op://Personal/Lamina Vault/password' > ~/.config/lamina/vault-password
chmod 600 ~/.config/lamina/vault-password
```

The plaintext file is a local operational copy. The durable recovery copy remains in 1Password. Never add the local file to Git or Dropbox directly.

### 4. Configure Vault

Copy `lamina/vault/config.example.zsh` to `~/.config/lamina/vault.zsh`, then keep:

```zsh
export LAMINA_VAULT_REPOSITORY="rclone:dropbox:Lamina/Vault"
export LAMINA_VAULT_PASSWORD_FILE="${HOME}/.config/lamina/vault-password"
```

The local configuration contains locations and secret references, not the password itself.

### 5. Initialize and prove recovery

```bash
lamina vault health
lamina vault init
lamina vault backup
lamina vault snapshots
lamina vault restore latest --target ~/Desktop/lamina-vault-proof
lamina vault verify
```

Inspect the proof directory before considering setup complete. A backup that has never been restored is only a theory.

## New-machine recovery

1. Install macOS updates, Homebrew, Git, 1Password, and Dropbox.
2. Clone the dotfiles repository.
3. Run `lamina deploy` and `lamina health`.
4. Install the Homebrew bundle so restic, rclone, and 1Password CLI exist.
5. Sign in to 1Password and reauthorize the `dropbox` rclone remote.
6. Recreate `~/.config/lamina/vault.zsh` from the checked-in example.
7. Recreate the local password file from the `Lamina Vault` 1Password item.
8. Run `lamina vault restore latest --target ~/Desktop/lamina-vault-restore`.
9. Install and open each AI application once so it creates current-format directories.
10. Merge reviewed state from the restore directory into each application while the application is closed.
11. Reauthenticate Codex, Grok, Cursor, and OpenClaw providers.
12. Run `lamina health`, `lamina vault health`, and a fresh backup.

Database state should be restored conservatively. Prefer current portable Markdown memories and configuration when a new application version cannot read an old database.

## Retention and verification

`lamina vault retain` applies this policy:

- 7 daily snapshots
- 8 weekly snapshots
- 12 monthly snapshots
- 3 yearly snapshots

Retention deletes old encrypted snapshots and prunes unreferenced data, so it is a separate explicit command rather than a hidden part of every backup.

Run `lamina vault verify` monthly. Run `lamina vault verify --full` and perform a test restore quarterly. A launchd schedule can automate ordinary backups after the initial manual recovery proof is complete.

## 1Password safety

No agent needs the 1Password account password, Secret Key, recovery code, or unrestricted vault export. Enable the 1Password desktop application's CLI integration and approve `op` locally. Secret references let scripts retrieve one field without placing it in source code.

For this design, the only required secret is the generated Restic repository password. Dropbox authorization and AI application authentication can be recreated interactively on a new machine.

## Failure cases

- **Mac dies:** clone Git, recover the Restic password from 1Password, authorize Dropbox, and restore.
- **Dropbox files are deleted:** Dropbox version history may recover the encrypted repository; Restic snapshots provide the logical recovery history.
- **A live AI database is corrupt:** restore an earlier snapshot into a review directory and extract only the affected application state.
- **1Password is unavailable:** use the family emergency kit and account recovery process. The Restic repository cannot be decrypted without its password by design.
- **Restic repository password is lost:** the backup is unrecoverable. Keep it in 1Password and include its existence—not its value—in the family recovery instructions.
