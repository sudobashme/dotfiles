# OpenClaw + Grok Integration

This setup lets the two powerful agent systems work together on your Mac.

## Why integrate?

- **OpenClaw** strengths: TUI, multi-agent orchestration, memory system (daily + long-term), channels (iMessage etc.), MCP/ACP bridging, flows/canvas, plugin skills, own agent personality (AGENTS.md, SOUL.md, etc.).
- **This Grok TUI** strengths: Deep local tool access (full filesystem read/write, arbitrary commands, grep, todo tracking, subagents with personas like implementer/reviewer, plan mode, skills system, ACP/MCP native, direct project context).

Together: Use OpenClaw as the "orchestrator / nice interface / memory layer", and delegate heavy local work (editing configs, running deploys, diagnostics, code changes) to this Grok instance which has privileged local access and all the custom skills we've built for your Personal OS Layer.

OpenClaw already has excellent native support for Grok models via the xAI provider (see your `openclaw.json` — grok-4.3 etc. are configured and set as primary in agents defaults).

The integration below adds the *local* Grok (this one) as a first-class option via ACP.

## Setup (already partially done)

We added convenient aliases in your dotfiles zsh config (`rc.d/250_aliases.zsh`):

- `oc` → openclaw
- `oc-tui` / `oct` → openclaw tui (the main interface)
- `oc-grok` [cwd] → openclaw acp client --server grok --server-args "agent stdio" --cwd "$cwd"
- `oc-grok-here` → oc-grok .
- `oc-with-grok` → launches TUI with a reminder
- `oc-mcp`, `oc-agents`, `oc-doctor` etc. for management

- `grok-acp` → grok agent stdio (for other ACP clients)

After sourcing your zsh (or new shell), these should be available. They were added to the dotfiles so they deploy with everything else.

## How to use the bridge

1. In a terminal (tmux pane recommended):

   ```bash
   oc-grok-here
   ```

   This starts an interactive ACP client in OpenClaw that spawns `grok agent stdio` as the backend.

   You'll get Grok's full local capabilities (edits, commands, our skills, subagents, plan mode, the Personal OS Layer work) presented through OpenClaw's ACP interface.

2. For the full OpenClaw experience:

   ```bash
   oc-tui
   ```

   Inside it, you can still use the cloud Grok models (already configured in your OpenClaw), or switch contexts to the bridged local one via the acp client.

3. Run Grok directly when you want the native TUI:

   ```bash
   grok
   ```

   Or `grok agent stdio` if another tool wants to consume it as ACP server.

## Recommended tmux workflow

Since you use tmux heavily:

- Pane 1: `oc-tui` (OpenClaw orchestrator, memory, channels)
- Pane 2: `oc-grok-here` (local Grok bridge for heavy lifting on current project)
- Pane 3: plain `grok` or direct `nvim` on the project

You can also run `openclaw acp client --server grok --server-args "agent stdio" --cwd ~/path/to/specific/project` for project-specific sessions.

## Deeper integration ideas

- **MCP bridging**: Both support MCP. Use `openclaw mcp` to manage servers, and Grok's built-in MCP support (see our current servers like grok_com_github). You can make tools available across both.
- **Shared memory/docs**: OpenClaw's workspace (`~/.openclaw/workspace`) has AGENTS.md, MEMORY.md, etc. We can symlink or copy relevant parts of our Personal OS Layer design docs into it, or configure OpenClaw agents to load from your dotfiles.
- **ACP for Neovim**: Since you prefer Neovim, Grok's ACP also works with clients like avante.nvim or CodeCompanion. You could have OpenClaw + Grok + Neovim all talking via ACP/MCP.
- **Custom skills**: Develop skills that work in both (Grok skills are markdown in .grok/skills; OpenClaw has plugin-skills).

## Current state of your OpenClaw

- Heavily pre-configured for Grok models (many variants listed, xai/grok-4.3 as default alias "Grok").
- xai, imessage, duckduckgo plugins enabled.
- Local gateway on port 18789.
- Own workspace with personality files.

The bridge above gives you the best of both: OpenClaw's infrastructure + this Grok's local power and our ongoing Personal OS Layer customizations (diagnostics, deploy, principles, etc.).

## Next steps we can take

- Test the `oc-grok-here` alias in a fresh shell.
- Set up a dedicated OpenClaw agent/workspace for the Personal OS Layer project.
- Expose some of our Grok skills/MCP servers into OpenClaw.
- Configure OpenClaw's main agent to prefer the local bridged Grok for certain tasks.
- Clean up any old OpenClaw completions or stray configs from the initial grok installer.

Let me know which direction to take first.

## Current Status (as of testing)

The `oc-grok-here` bridge starts the ACP connection successfully ("some love").

However, you may see errors like:
- "Method not found": _x.ai/settings/update
- RequestError: Invalid params

This is because OpenClaw's ACP client sends/receives some xAI-specific extension methods (for settings, tips, announcements, etc.) that the local `grok agent stdio` ACP server doesn't fully implement (it's primarily for standard ACP + basic x.ai extensions used in editor integrations).

It may still allow basic interaction in some cases, or it may error out after handshake.

**Practical advice for now:**
- Use `oc-tui` for OpenClaw's agent/TUI features (it will use the Grok models configured in its providers via API).
- Use the native `grok` command in a separate pane for the full local tool-powered experience (this is currently the most reliable way to get "you" 's full capabilities).
- The ACP bridge is experimental/partial due to protocol differences.

We can improve this over time by:
- Using MCP for tool sharing instead of (or in addition to) ACP.
- Developing a small adapter if needed.
- Or just enjoying the two tools side-by-side, which is very effective with tmux.

If you run `oc-grok-here` and share the exact errors/output you see, we can debug further.

The aliases are live after shell reload.

## User Test Result (June 2026)

When running `oc-grok-here`:

```
Starting OpenClaw ACP client bridged to local Grok (cwd: .)...
This runs Grok's ACP server under the hood for full local tool access.

🦞 OpenClaw 2026.5.7 (eeef486) — I'm like tmux: confusing at first, then suddenly you can't live without me.

error: unrecognized subcommand 'agent stdio'

  tip: a similar subcommand exists: 'agent'

Usage: grok [OPTIONS] [PROMPT] [COMMAND]

For more information, try '--help'.
Error: ACP connection closed
```

**Analysis:**
- The subcommand error was due to argument passing (fixed by creating `~/.local/bin/grok-acp` wrapper that hardcodes `grok agent stdio` and ignores extra args passed by OpenClaw).
- After fix, it progresses to the JSON-RPC error:
  ```
  Error handling notification { ... method: '_x.ai/settings/update' ... }
  { code: -32601, message: '"Method not found": _x.ai/settings/update' ... }
  RequestError: Invalid params
  ```

This confirms the partial integration: ACP connection initiates, but OpenClaw sends xAI-specific methods (settings, tips, etc.) that the local Grok stdio ACP server does not support.

**Recommendation in current setup:**
Use the tools side-by-side rather than bridged for now.

The helpers (oc-grok etc.) are still present for experimentation or future improvement via MCP.

## Latest Test Result (user report + reproduction)

Running `oc-grok-here` now produces:

```
Starting OpenClaw ACP client bridged to local Grok (cwd: .)...
This runs Grok's ACP server under the hood for full local tool access.

🦞 OpenClaw 2026.5.7 (eeef486) — I'm like tmux: confusing at first, then suddenly you can't live without me.

Error handling notification {
  jsonrpc: '2.0',
  method: '_x.ai/settings/update',
  params: { ... lots of Grok UI settings, tips, announcements ... }
} {
  code: -32601,
  message: '"Method not found": _x.ai/settings/update',
  data: { method: '_x.ai/settings/update' }
}
RequestError: Invalid params
```

(ACP connection then closes.)

**Root cause diagnosis:**
- The `grok-acp` wrapper successfully makes `grok agent stdio` the ACP server (no more "unrecognized subcommand" error).
- OpenClaw's ACP client starts talking to it.
- But OpenClaw immediately sends a proprietary `_x.ai/settings/update` notification (with Grok-specific UI state, tips, announcements, subscription info, etc.).
- The local `grok agent stdio` (standard ACP for editors/integrations) does not implement these xAI extension methods.
- Result: method-not-found error → connection closed.

This is a protocol incompatibility between OpenClaw's ACP client (tuned for the full Grok cloud/web/app experience) and Grok's local stdio ACP server.

The integration currently gets "some love" (connection + protocol start) but errors on the custom extensions.

**Updated recommendation:**
For the highest reliability and "getting the job done":

- Use `oc-tui` (OpenClaw) in one tmux pane — it already has excellent built-in support for Grok models via the xAI provider in your config.
- Use plain `grok` in another pane for the full local power (tools, subagents, skills, plan mode, direct editing of your Personal OS Layer, etc.).

We can add tmux helpers or a launch script if you want a one-command "both at once" setup.

MCP bridging is a promising next avenue for *tool* sharing without requiring full ACP session compatibility.

The current aliases remain for experimentation.

## Fresh Reproduction (exact paste you just sent)

```sh
~ is 📦 v0.1.0 via  v22.14.0 via 🦀 v1.95.0 
󰄛 ❯ oc-grok-here
Starting OpenClaw ACP client bridged to local Grok (cwd: .)...
This runs Grok's ACP server under the hood for full local tool access.
Note: Some xAI-specific extensions may cause protocol warnings/errors (partial integration).

🦞 OpenClaw 2026.5.7 (eeef486) — WhatsApp automation without the "please accept our new privacy policy".

Error handling notification {
  jsonrpc: '2.0',
  method: '_x.ai/settings/update',
  params: {
    show_resolved_model: false,
    sharing_enabled: false,
    session_picker_grouped: null,
    tips: [
      'Use @ to attach files like @src/main.rs.',
      'Use @! for hidden or ignored files: @!.github/workflows.',
      'Generate images and videos with /imagine',
      'Press Ctrl+O to toggle auto-approve mode.',
      'Use Shift+Tab to cycle between modes, like Plan mode.',
      'Ask your Agent to search X or the web.',
      'Press Ctrl+G to background a running terminal command.',
      'Start Grok in a fresh worktree with `-w`; add `-r <session-id>` to resume an existing session there.',
      'Try Composer 2.5 from the /model menu',
      'Use Ctrl+Enter to interject messages. Or just Enter to queue messages.'
    ],
    announcements: [ [Object] ],
    gate_message: null,
    gate_url: null,
    gate_label: null,
    allow_access: true,
    subscription_tier_display: 'X Premium+'
  }
} {
  code: -32601,
  message: '"Method not found": _x.ai/settings/update',
  data: { method: '_x.ai/settings/update' }
}
RequestError: Invalid params
```

**Same root cause as before (now with the wrapper and the note in the function):**

The `grok-acp` wrapper works — no more subcommand error.

OpenClaw's ACP client successfully starts the local Grok stdio server.

But then OpenClaw fires the `_x.ai/settings/update` notification (the one that carries all the Grok UI chrome: tips, announcements, subscription info, etc.).

The local `grok agent stdio` does not implement that method → JSON-RPC error → connection closed.

This is the "some love but errors" state. The ACP layer connects, the protocol starts, then the proprietary xAI extension kills it.

We have the note printed by the alias now, which is why you see the "Note: Some xAI-specific extensions..." line.

**Current recommended reality (the part that actually delivers value):**

- `oc-tui` (or `oct`, `os-layer`) → OpenClaw TUI using its native Grok model support (the stuff already in your `openclaw.json`).
- Plain `grok` in another pane for the real local power (tools, subagents, skills, plan mode, everything we've been building for the Personal OS Layer).

The `launch-os-layer` / `os-layer` script exists precisely to make the side-by-side cheap and pleasant (especially in tmux).

The ACP bridge aliases are still there as an experiment, but they hit this wall.

If you want, we can:
- Make `oc-grok-here` print a clearer "this is known to be partial, here's the side-by-side command instead" and then just launch `grok`.
- Clean up the experimental aliases.
- Pivot to MCP bridging for tool sharing (different protocol, potentially less friction).
- Or just document this as "known limitation" and move on to the next piece of the layer (diagnostics, deploy script, etc.).

What would you like to do with this?
## os-layer / launch-os-layer improvements (latest)

The launcher script at `~/.local/bin/launch-os-layer` (aliased as `os-layer`) was updated with:

- Full paths to `grok` and `openclaw` (avoids PATH inheritance problems in the tmux child pane).
- Proper use of `$TMUX_PANE` to select the original pane after split (more reliable than hard-coded `-t 0`).
- `-c "#{pane_current_path}"` on the split so the new pane starts in the same directory.
- Defensive checks for the binaries.
- `set -euo pipefail` for safer execution.
- Clearer non-tmux fallback message.

This should resolve common "os-layer has issues" problems like:
- Commands not found in the split pane.
- Wrong pane ending up with openclaw tui.
- Losing the current working directory.

Run `os-layer` while inside tmux to get a clean horizontal split: one pane with openclaw tui, the other with grok.

(If you still see problems, paste the exact error/output and we'll iterate.)

The `launch-os-layer` script is now also tracked in the repo at `bin/launch-os-layer` (so it becomes part of your versioned Personal OS Layer). The live one in `~/.local/bin/` is what the `os-layer` alias uses.

If you want your deploy to manage `~/.local/bin/launch-os-layer`, you can add a symlink step for it (similar to how other tools are handled).

## os-layer / launch-os-layer (latest improvements)

The launcher has been significantly hardened:

- Full hardcoded paths to avoid any PATH resolution issues in tmux child panes or different shell contexts.
- Uses `$TMUX_PANE` (the pane ID where the launcher is running) for reliable `select-pane` after split (previous versions used brittle `-t 0`).
- Split uses `-c "#{pane_current_path}"` to preserve the working directory in the Grok pane.
- Added binary existence checks and `set -euo pipefail`.
- Cleaner code and comments.
- The script is now tracked in the repo at `bin/launch-os-layer` (so it's part of your versioned Personal OS Layer and can be deployed/linked via your deploy.zsh if desired).

The `os-layer` alias runs it.

Run `os-layer` while inside tmux to get the side-by-side.

If it still has issues, paste the exact output or describe (e.g. "split happens but grok pane is empty", "focus is on the Grok pane instead of OpenClaw", "commands not found", "no split at all", etc.).

We can easily add features like:
- `--vertical` or `--horizontal` flag.
- 3-pane layout (OpenClaw | Grok | nvim on the docs or AGENTS.md).
- Auto `cd` to `~/` or the dotfiles or the personal-os-layer docs.
- Pre-load context (e.g. tell Grok "you are helping with the Personal OS Layer project, load the docs...").
- Kitty-specific splits if you want to avoid tmux for the launch.

The current recommendation is the side-by-side without the ACP bridge, as the bridge causes the agent error state you're seeing in the OpenClaw TUI.

The garbled output and "connected | error" with the grok-4.3 model is almost certainly from attempting the bridge, which poisons the session with the method-not-found.

To recover the OpenClaw TUI/agent:
- Try `openclaw doctor` for health checks + fixes.
- `openclaw status`
- `openclaw sessions` (list and kill bad sessions if possible).
- `openclaw agents` (manage agents).
- Restart gateway if needed (`openclaw gateway` or the daemon commands).
- Worst case `openclaw reset` (backs up first if possible).

For the terminal corruption/garble: after exiting the TUI, run `reset` or `stty sane` in your shell.

Let me know the specific issues with `os-layer` (or the current OpenClaw state), and we'll fix them immediately. This is all part of crafting your personal OS layer the way you want.
