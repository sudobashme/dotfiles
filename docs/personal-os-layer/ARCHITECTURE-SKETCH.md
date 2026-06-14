# Architecture Sketch — Personal OS Layer (Early)

This is an *initial* sketch, not a final architecture. Its purpose is to start making the shape of the system visible so we can discuss it.

## Guiding Mental Model

Think of this as four major layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    Personal OS Layer                        │
├─────────────────────────────────────────────────────────────┤
│  Interaction Layer   │  Shell (zsh + tmux + kitty)         │
│                      │  Editor (Neovim + LazyVim custom)   │
├─────────────────────────────────────────────────────────────┤
│  Self-Awareness      │  Diagnostics / Health System        │
│                      │  (The "nervous system")             │
├─────────────────────────────────────────────────────────────┤
│  Foundation          │  Deployment / Bootstrap             │
│                      │  (Reproducible construction)        │
├─────────────────────────────────────────────────────────────┤
│  Platform            │  macOS + Homebrew + Core Tools      │
└─────────────────────────────────────────────────────────────┘
```

The key insight is that **Self-Awareness (Diagnostics)** is treated as a first-class layer, not an afterthought or a script you occasionally run.

## Major Components (Current Thinking)

### 1. Shell Environment
- Zsh configuration (modular, but redesigned with clear principles)
- Tmux configuration
- Kitty configuration
- Supporting tools (starship or alternative, fzf, eza, yazi, etc.)

**Design Goal**: Coherent, fast, beautiful, and *original* rather than derivative.

### 2. Editor Environment (Neovim)
- Currently LazyVim-based with custom plugins
- Should feel like it belongs to the same "family" as the shell layer

**Open Question**: How tightly do we couple the shell diagnostics with Neovim? (e.g. a `:PersonalHealth` command that surfaces shell + deployment issues inside the editor?)

### 3. Diagnostics / Health System (Critical)
This is likely the most important new component we will build.

See `DIAGNOSTICS-VISION.md` for detailed thinking.

Possible implementation directions:
- A small, high-quality CLI tool (`pos` or `layer` or `health` or custom name)
- Shell functions that call the tool
- Structured data + multiple presentation layers
- Ability for other components to register health checks

### 4. Deployment / Construction System
Current `deploy.zsh` is too monolithic and imperative.

Better model might be:
- **Declarative** description of desired state (what packages, what symlinks, what plugins, what versions)
- **Construction** logic that can bring a machine to that state
- **Verification** that is the same system used by diagnostics
- Support for both "full bootstrap" and "update / repair" modes

This is one of the hardest and most valuable parts to get right.

### 5. Supporting Infrastructure
- Consistent configuration locations (strong XDG usage is already good)
- Shared libraries / functions used by multiple components
- Documentation that is actually maintained because it serves the design

## Key Relationships

- **Diagnostics should be able to inspect the Deployment system** (and vice versa).
- The **Shell layer** should be able to surface high-level health status easily (e.g. in the prompt or a dedicated command).
- The entire system should be able to report on how well it conforms to the documented **Principles** and **Vision**.

## What This Is Not

- A general-purpose dotfiles framework for other people (at least not initially)
- An attempt to make everything "cross-platform" at the cost of quality on macOS
- A giant monorepo that tries to own every possible tool

## Open Architectural Questions

1. **Tooling Language**: How much of the new infrastructure (especially diagnostics and a better deploy system) should be written in shell vs a "real" language (Go, Rust, etc.)?
2. **Configuration Format**: Do we want a single source of truth (e.g. a TOML or custom format) that generates parts of the zsh config, tmux config, etc.?
3. **Update Model**: How does the system stay up to date across machines in a way that still feels intentional rather than "just run the deploy script again"?
4. **Extensibility for Future Layers**: What happens when we later want to add window management, automation (hammerspoon/raycast/etc.), or other concerns?

---

This document will change significantly as we do more design work. Its current value is in making the problem space more concrete.
