# Personal OS Layer — Project Charter

## Project Name
**TBD** (suggestions welcome: something that feels like high-craft systems work rather than "dotfiles")

## Mission
To design and build a personal computing environment on macOS that embodies the same level of intentionality, ownership, and craftsmanship found in the best custom Linux distributions and ricing communities — without leaving macOS.

## Why This Matters
The user has a long history of treating their OS layer as a serious creative and technical act (Windows customization → Knoppix/Morphix remastering → custom Kali). Staying on macOS should not mean lowering that standard.

This is infrastructure for thinking and working. It deserves real design.

## Scope (Initial)

### In Scope
- Zsh + tmux + kitty configuration (the interactive shell layer)
- Self-diagnostics / Health system (the "LazyHealth for the terminal" problem — this is a major focus)
- Deployment / Bootstrap system (`deploy.zsh` and related tooling)
- Integration points with the existing Neovim (LazyVim) configuration
- Overall philosophy, principles, and documentation for the environment

### Out of Scope (for now)
- Full window management layer (Aerospace, yabai, etc.) unless it becomes clearly necessary
- Complete replacement of all macOS defaults and Homebrew packages
- Making this easily usable by other people (this is a personal system first)

## Success Criteria (High Level)

- The environment feels *designed*, not accumulated.
- Running diagnostics actually helps the user understand and improve their setup (high signal, not high volume).
- The deployment process is trustworthy and reasonably pleasant to work with.
- The user feels genuine pride when using and maintaining the system.
- It is obvious to the user (and eventually to others) that a high level of care went into this.

## Guiding Principles (Draft)

- **Signal over Noise**: Especially critical for diagnostics.
- **Craft over Convenience** (when the tradeoff is worth it).
- **Cohesion**: The pieces should feel like they belong together.
- **Honesty**: We will be ruthless about what is derivative or low-effort.
- **Long-term Ownership**: This should be maintainable and understandable in 3–5 years.

## Relationship to Existing Work

Much of the current content in this repository will be treated as historical reference rather than sacred. We are allowed (and expected) to let go of patterns that no longer serve the vision.

The goal is not to throw everything away, but to stop being limited by the shape of what was built before.

## Project Stance

This is not a "weekend project" or a series of small refactors.

This is the user choosing to take their personal computing environment as seriously as they have taken custom OS builds in the past.

That level of seriousness deserves structure, design, and deliberate execution.
