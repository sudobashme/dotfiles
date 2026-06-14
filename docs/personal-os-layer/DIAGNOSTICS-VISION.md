# Diagnostics & Health System — Vision

## The Problem (Current State)

The existing diagnostic capability is a modified version of the classic Oh My Zsh `omz_diagnostic_dump` script.

Its fundamental model is:
> "Collect a massive amount of raw information about the environment and dump it into a file so a human can try to figure out what's wrong."

This is the opposite of what a high-craftsmanship personal OS layer should have.

It produces **volume**, not **understanding**. It is performative self-awareness rather than genuine self-awareness.

## The Standard We Are Aiming For

We have a clear, high-quality reference point: **Neovim's health checking system**, especially as presented in LazyVim and modern plugin ecosystems (`:checkhealth`, Lazy's health UI, etc.).

What makes it excellent:
- **Actionable**: It doesn't just report facts. It tells you when something is wrong *and* what you might do about it.
- **Categorized and prioritized**: Issues are grouped and severity is communicated.
- **Beautiful and scannable**: The presentation respects the user's attention.
- **Context-aware**: It knows about the actual plugins, versions, and configuration in use.
- **Extensible**: Individual components can contribute their own health checks.

We want something at least this good for the terminal + deployment + tooling environment.

## What "Self-Diagnostics" Should Actually Mean

A good diagnostics system in this project should be able to answer questions like:

### Basic Level (Must Have)
- Is the environment in a healthy state right now?
- What components are in a degraded or broken state?
- What recent changes might have caused problems?

### Higher Level (Should Have)
- What is the *quality* of this environment, not just whether it is broken?
- Are there known anti-patterns or outdated patterns being used?
- How does the current state compare to the intended design?
- What would "raising the level of craft" look like in specific areas?

### Advanced / Aspirational
- The system can suggest concrete improvements based on usage patterns.
- It can detect configuration drift between machines.
- It can reason about interactions between components (e.g. "your starship prompt is slow because of X, and your zsh startup is impacted because of Y").

## Design Directions to Explore

### 1. Multiple Layers of Diagnostics

We probably want several different "modes" or depths:

- **Quick Health** (`health` or `doctor` command): Fast, focused check for common problems. What a power user would run several times a day.
- **Deep Diagnostic**: The full, thorough report (the spiritual successor to the current dump, but much higher quality).
- **Design Conformance**: Checks how well the current environment matches the intended architecture and principles.
- **Quality / Craft Score** (optional, controversial, potentially very useful): A more opinionated view of how "well made" the setup currently is.

### 2. Structured Output + Beautiful Presentation

Raw text dumps are no longer acceptable as the primary experience.

Options to consider:
- Structured data (JSON/YAML) as the source of truth, with multiple renderers (terminal, markdown report, web view, etc.).
- A TUI (using something like `gum`, `dialog`, custom Go/Rust tool, or even a small Neovim interface).
- Integration with existing tools the user already respects (e.g. something that feels in the same family as Snacks or Trouble in their Neovim setup).

### 3. Extensibility Model

Individual components should be able to register their own health checks easily:
- Zsh modules / rc.d files
- The deploy system
- Specific tool configurations (starship, tmux, yazi, etc.)
- Neovim-related environment health (when relevant)

This is similar to how Neovim health checks work.

### 4. Self-Improvement Orientation

The diagnostics system should not just be a passive reporter. It should actively help the user raise the quality of their environment over time.

This could include:
- Suggestions for replacing outdated patterns
- Detection of "this used to be necessary but isn't anymore"
- Tracking of technical debt in the configuration itself

## Open Questions

- Should the diagnostics tooling live primarily in shell, or should it be a small dedicated tool (Go/Rust) that the shell calls?
- How much should it integrate with Neovim vs stand on its own?
- Do we want any kind of "health score" or gamification, or is that too cute?
- What is the right balance between "always available" (pure shell) and "maximum quality presentation" (external tool or TUI)?

## Success Criteria for the Diagnostics System

You will know we have succeeded when:

- Running the health check feels *useful* rather than dutiful.
- You regularly discover real, non-obvious problems or improvement opportunities through it.
- The output makes you think "this is well made" rather than "here is a bunch of information."
- It would be embarrassing to go back to the old dump-based approach.

This is one of the highest-leverage areas in the entire project because it directly supports the goal of **self-awareness** as a core property of a high-quality personal OS layer.
