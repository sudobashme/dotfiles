# Personal OS Layer

This is the working space for a serious, long-term project:

**Building a high-craftsmanship personal computing environment on macOS with the same intentionality and ownership that people bring to custom Linux distributions and ricing.**

## Documents

- [VISION.md](./VISION.md) — The core philosophy and north star
- [PROJECT-CHARTER.md](./PROJECT-CHARTER.md) — Scope, principles, and stance
- [CURRENT-STATE.md](./CURRENT-STATE.md) — Honest assessment of where things are today
- [GAME-PLAN.md](./GAME-PLAN.md) — **Living agenda** — what's done, what's next, phase order
- [WORKLOG.md](./WORKLOG.md) — **Session log** — what actually shipped and when
- [UPDATE-STRATEGY.md](./UPDATE-STRATEGY.md) — **How to update** — git, deploy, `up`, Neovim, docs cadence

## Where we are (Jun 2026)

**Just finished:** Editor cohesion sprint — Neovim plugin conflicts, Yazi flavor, dotfyle sync (`bcb779a`). Details in [WORKLOG.md](./WORKLOG.md).

**Next up:** Phase 1 in [GAME-PLAN.md](./GAME-PLAN.md) — **diagnostics / `lamina health`** (the biggest quality gap vs. LazyVim-style `:checkhealth`).

## Current Focus Areas

1. ~~Creating cohesion across shell + editor + tooling~~ → Neovim slice done; shell↔editor bridge still open
2. Building a genuinely useful, beautiful, and actionable self-diagnostics system (**primary focus now**)
3. Re-thinking the deployment/bootstrap story
4. Moving beyond derivative/OMZ-influenced patterns in the shell layer

More documents (architecture, principles, component designs, etc.) will be added as the project progresses.

---

This is not about having "nice dotfiles."

This is about building your own OS layer.

## Integrations

- [OPENCLAW-INTEGRATION.md](./OPENCLAW-INTEGRATION.md) — Bridging this Grok TUI with OpenClaw (ACP client, shared workflows for the Personal OS Layer project, using OpenClaw's infrastructure with this Grok's local power).
