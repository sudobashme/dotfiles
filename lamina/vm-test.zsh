#!/usr/bin/env zsh
set -euo pipefail

DOTFILES="$(lamina_dotfiles)" || exit 1

LAMINA_VM_CONFIG="${DOTFILES}/lamina/vm.toml"
LAMINA_VM_STATE="${XDG_CACHE_HOME:-${HOME}/.cache}/lamina/vm"

zmodload zsh/files 2>/dev/null || true

typeset -i CHECK=0 KEEP=0
typeset -a VM_ARGS=()

lamina_vm_cfg() {
    local key="$1"
    python3 - "${LAMINA_VM_CONFIG}" "${key}" <<'PY'
import sys, tomllib
from pathlib import Path
path, key = sys.argv[1], sys.argv[2]
data = tomllib.loads(Path(path).read_text())
value = data["vm"][key]
if isinstance(value, bool):
    print("true" if value else "false")
else:
    print(value)
PY
}

while (( $# > 0 )); do
    case "${1}" in
        --check) CHECK=1 ;;
        --keep) KEEP=1 ;;
        -h|--help)
            cat <<'EOF'
lamina vm-test — Tart macOS sandbox for deploy verification

Usage:
  lamina vm-test setup-base       Clone/configure golden base image (once)
  lamina vm-test clone [name]     Clone base → disposable test VM
  lamina vm-test run [name]       Start VM headless with dotfiles mounted
  lamina vm-test stop [name]      Stop a running VM
  lamina vm-test ip [name]        Print guest IP (if running)
  lamina vm-test ssh [name] [cmd] SSH into guest (default: interactive shell)
  lamina vm-test deploy [name]    Run lamina deploy + health inside guest
  lamina vm-test destroy [name]   Delete a VM
  lamina vm-test list             List Tart VMs (lamina-*)
  lamina vm-test e2e [--keep]     Clone → run → deploy → stop (destroy unless --keep)

Options:
  --check   Print planned actions only
  --keep    Keep test VM after `e2e` (don't stop/destroy)

Requires: tart, sshpass (brew install cirruslabs/cli/tart cirruslabs/cli/sshpass)
Guest mount: /Volumes/My Shared Files/dotfiles

See: docs/personal-os-layer/VM-INFRASTRUCTURE.md
EOF
            exit 0
            ;;
        *)
            VM_ARGS+=("${1}")
            ;;
    esac
    shift
done

lamina_vm_need_tart() {
    if ! command -v tart >/dev/null 2>&1; then
        lamina_fail "tart not found — brew install cirruslabs/cli/tart"
        exit 1
    fi
}

lamina_vm_need_sshpass() {
    if ! command -v sshpass >/dev/null 2>&1; then
        lamina_fail "sshpass not found — brew install cirruslabs/cli/sshpass"
        exit 1
    fi
}

lamina_vm_memory_mb() {
    local gb
    gb="$(lamina_vm_cfg memory_gb)"
    print -r -- $(( gb * 1024 ))
}

lamina_vm_default_test_name() {
    print -r -- "$(lamina_vm_cfg test_prefix)-$(date +%Y%m%d-%H%M%S)"
}

lamina_vm_exists() {
    local name="$1"
    tart list 2>/dev/null | awk '$1 == "local" { print $2 }' | grep -Fxq "${name}"
}

lamina_vm_ssh_opts() {
    print -r -- \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=10
}

lamina_vm_wait_ip() {
    local name="$1"
    local timeout="${2:-$(lamina_vm_cfg ssh_timeout_secs)}"
    local start=$SECONDS ip=""

    while (( SECONDS - start < timeout )); do
        ip="$(tart ip "${name}" 2>/dev/null || true)"
        if [[ -n "${ip}" ]]; then
            print -r -- "${ip}"
            return 0
        fi
        sleep 3
    done
    lamina_fail "timed out waiting for ${name} IP (${timeout}s)"
    return 1
}

lamina_vm_wait_ssh() {
    local name="$1" ip="$2"
    local user pass timeout start
    user="$(lamina_vm_cfg guest_user)"
    pass="$(lamina_vm_cfg guest_password)"
    timeout="$(lamina_vm_cfg ssh_timeout_secs)"
    start=$SECONDS

    while (( SECONDS - start < timeout )); do
        if sshpass -p "${pass}" ssh \
            $(lamina_vm_ssh_opts) \
            "${user}@${ip}" "echo lamina-vm-ready" >/dev/null 2>&1; then
            lamina_ok "SSH ready on ${ip}"
            return 0
        fi
        sleep 5
    done
    lamina_fail "timed out waiting for SSH on ${name}"
    return 1
}

lamina_vm_ssh() {
    local name="$1"
    shift
    local ip user pass
    lamina_vm_need_sshpass
    ip="$(tart ip "${name}" 2>/dev/null || true)"
    [[ -n "${ip}" ]] || { lamina_fail "no IP for ${name} — is it running?"; return 1; }
    user="$(lamina_vm_cfg guest_user)"
    pass="$(lamina_vm_cfg guest_password)"
    sshpass -p "${pass}" ssh \
        $(lamina_vm_ssh_opts) \
        "${user}@${ip}" "$@"
}

lamina_vm_setup_base() {
    local image base cpus memory
    image="$(lamina_vm_cfg base_image)"
    base="$(lamina_vm_cfg base_name)"
    cpus="$(lamina_vm_cfg cpus)"
    memory="$(lamina_vm_memory_mb)"

    if (( CHECK )); then
        print -r -- "  → tart clone ${image} ${base}"
        print -r -- "  → tart set ${base} --cpu ${cpus} --memory ${memory}"
        return 0
    fi

    if lamina_vm_exists "${base}"; then
        lamina_warn "${base} already exists — skipping clone"
    else
        lamina_update_banner "cloning base image ${image}"
        tart clone "${image}" "${base}"
    fi
    tart set "${base}" --cpu "${cpus}" --memory "${memory}"
    lamina_ok "base VM ${base} ready"
}

lamina_vm_clone() {
    local name="${1:-$(lamina_vm_default_test_name)}"
    local base="$(lamina_vm_cfg base_name)"

    if (( CHECK )); then
        print -r -- "  → tart clone ${base} ${name}"
        return 0
    fi

    if ! lamina_vm_exists "${base}"; then
        lamina_fail "base VM ${base} missing — run: lamina vm-test setup-base"
        return 1
    fi
    if lamina_vm_exists "${name}"; then
        lamina_fail "VM ${name} already exists"
        return 1
    fi

    tart clone "${base}" "${name}"
    lamina_ok "cloned ${base} → ${name}"
}

lamina_vm_run() {
    local name="${1:-$(lamina_vm_default_test_name)}"
    local mount guest_dotfiles
    mount="$(lamina_vm_cfg mount_name)"
    guest_dotfiles="$(lamina_vm_cfg guest_dotfiles)"

    if (( CHECK )); then
        print -r -- "  → tart run --no-graphics --dir=${mount}:${DOTFILES} ${name}"
        return 0
    fi

    if ! lamina_vm_exists "${name}"; then
        lamina_fail "VM ${name} not found"
        return 1
    fi

    zf_mkdir -p "${LAMINA_VM_STATE}"
    lamina_update_banner "starting ${name} (headless, dotfiles mounted)"
    print -r -- "  guest path: ${guest_dotfiles}"
    tart run --no-graphics --dir="${mount}:${DOTFILES}" "${name}" &
    print -r -- $! >"${LAMINA_VM_STATE}/${name}.pid"
    lamina_ok "VM ${name} starting in background (pid $(<"${LAMINA_VM_STATE}/${name}.pid"))"
}

lamina_vm_stop() {
    local name="${1:?VM name required}"

    if (( CHECK )); then
        print -r -- "  → tart stop ${name}"
        return 0
    fi

    tart stop "${name}" || true
    rm -f "${LAMINA_VM_STATE}/${name}.pid"
    lamina_ok "stopped ${name}"
}

lamina_vm_destroy() {
    local name="${1:?VM name required}"

    if (( CHECK )); then
        print -r -- "  → tart stop ${name}"
        print -r -- "  → tart delete ${name}"
        return 0
    fi

    tart stop "${name}" 2>/dev/null || true
    tart delete "${name}"
    rm -f "${LAMINA_VM_STATE}/${name}.pid"
    lamina_ok "destroyed ${name}"
}

lamina_vm_guest_bootstrap() {
    local name="${1:?VM name required}"

    if (( CHECK )); then
        print -r -- "  → ssh: install Homebrew + dotter (if missing)"
        return 0
    fi

    lamina_update_banner "guest bootstrap (Homebrew + dotter)"
    lamina_vm_ssh "${name}" 'set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:${PATH}"
if command -v dotter >/dev/null 2>&1; then
  exit 0
fi
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew install dotter'
    lamina_ok "guest bootstrap complete"
}

lamina_vm_deploy() {
    local name="${1:?VM name required}"
    local guest_dotfiles
    guest_dotfiles="$(lamina_vm_cfg guest_dotfiles)"

    if (( CHECK )); then
        lamina_vm_guest_bootstrap "${name}"
        print -r -- "  → ssh: cd '${guest_dotfiles}' && ./bin/lamina deploy"
        print -r -- "  → ssh: cd '${guest_dotfiles}' && ./bin/lamina health"
        return 0
    fi

    lamina_vm_guest_bootstrap "${name}"
    lamina_vm_ssh "${name}" \
        "export PATH=/opt/homebrew/bin:/usr/local/bin:\${PATH}; set -euo pipefail; cd '${guest_dotfiles}' && ./bin/lamina deploy && ./bin/lamina health"
    lamina_ok "deploy + health passed in ${name}"
}

lamina_vm_test() {
    local name
    name="$(lamina_vm_default_test_name)"

    if (( CHECK )); then
        lamina_vm_clone "${name}"
        lamina_vm_run "${name}"
        print -r -- "  → wait for IP + SSH"
        lamina_vm_deploy "${name}"
        if (( ! KEEP )); then
            lamina_vm_destroy "${name}"
        else
            print -r -- "  → keep VM ${name}"
        fi
        return 0
    fi

    lamina_vm_clone "${name}"
    lamina_vm_run "${name}"

    local ip
    ip="$(lamina_vm_wait_ip "${name}")"
    lamina_vm_wait_ssh "${name}" "${ip}"
    lamina_vm_deploy "${name}"

    if (( KEEP )); then
        lamina_ok "test VM kept: ${name} (ssh admin@${ip})"
        print -r -- "  stop:    lamina vm-test stop ${name}"
        print -r -- "  destroy: lamina vm-test destroy ${name}"
        return 0
    fi

    lamina_vm_stop "${name}"
    lamina_vm_destroy "${name}"
    lamina_ok "vm-test complete"
}

lamina_vm_list() {
    tart list 2>/dev/null | awk 'NR == 1 || ($1 == "local" && $2 ~ /^lamina-/)' || tart list
}

lamina_update_banner() {
    print -r -- ""
    print -r -- "▸ $*"
}

# --- dispatch ---

# zsh arrays are 1-indexed by default
typeset -r subcmd="${VM_ARGS[1]:-help}"
typeset -a rest=("${VM_ARGS[@]:2}")

lamina_vm_need_tart

print -r -- "lamina vm-test — ${DOTFILES}"
if (( CHECK )); then
    print -r -- "lamina vm-test — check mode"
fi

case "${subcmd}" in
    setup-base) lamina_vm_setup_base ;;
    clone) lamina_vm_clone "${rest[1]:-}" ;;
    run) lamina_vm_run "${rest[1]:-}" ;;
    stop) lamina_vm_stop "${rest[1]:?usage: lamina vm-test stop <name>}" ;;
    ip)
        name="${rest[1]:?usage: lamina vm-test ip <name>}"
        tart ip "${name}" || exit 1
        ;;
    ssh)
        name="${rest[1]:?usage: lamina vm-test ssh <name> [cmd]}"
        if (( ${#rest[@]} > 1 )); then
            lamina_vm_ssh "${name}" "${rest[@]:2}"
        else
            ip="$(tart ip "${name}")"
            user="$(lamina_vm_cfg guest_user)"
            pass="$(lamina_vm_cfg guest_password)"
            exec sshpass -p "${pass}" ssh $(lamina_vm_ssh_opts) "${user}@${ip}"
        fi
        ;;
    deploy) lamina_vm_deploy "${rest[1]:?usage: lamina vm-test deploy <name>}" ;;
    destroy) lamina_vm_destroy "${rest[1]:?usage: lamina vm-test destroy <name>}" ;;
    list) lamina_vm_list ;;
    e2e) lamina_vm_test ;;
    help|-h|--help|"")
        cat <<'EOF'
lamina vm-test — Tart macOS sandbox for deploy verification

Usage:
  lamina vm-test setup-base       Clone/configure golden base image (once)
  lamina vm-test clone [name]     Clone base → disposable test VM
  lamina vm-test run [name]       Start VM headless with dotfiles mounted
  lamina vm-test stop [name]      Stop a running VM
  lamina vm-test ip [name]        Print guest IP (if running)
  lamina vm-test ssh [name] [cmd] SSH into guest (default: interactive shell)
  lamina vm-test deploy [name]    Run lamina deploy + health inside guest
  lamina vm-test destroy [name]   Delete a VM
  lamina vm-test list             List Tart VMs (lamina-*)
  lamina vm-test e2e [--keep]     Clone → run → deploy → stop (destroy unless --keep)

Options:
  --check   Print planned actions only
  --keep    Keep test VM after `e2e` (don't stop/destroy)

Requires: tart, sshpass (brew install cirruslabs/cli/tart cirruslabs/cli/sshpass)
Guest mount: /Volumes/My Shared Files/dotfiles

See: docs/personal-os-layer/VM-INFRASTRUCTURE.md
EOF
        ;;
    *)
        lamina_fail "unknown vm-test command: ${subcmd}"
        print -u2 "Run: lamina vm-test --help"
        exit 1
        ;;
esac