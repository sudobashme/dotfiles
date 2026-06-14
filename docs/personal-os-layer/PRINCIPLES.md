# Design Principles — Personal OS Layer

These are the non-negotiable standards for this project. They exist to prevent us from drifting back into "good enough" or derivative patterns.

## 1. Ownership Over Convenience

If something is core to how you think and work, it is worth owning completely.

This does not mean rewriting everything from scratch. It means:
- Understanding *why* every major piece exists
- Being willing to replace or heavily modify anything that doesn't feel like yours
- Never accepting "it just works" as the final justification for a component

## 2. Signal Over Volume

Especially for diagnostics and self-inspection.

The current OMZ-style dump produces *data*. We want *understanding*.

A good diagnostic system should be able to answer questions like:
- "What is actually broken or suboptimal right now?"
- "What changed recently that might have caused this?"
- "What would a healthier version of this component look like?"

Volume is easy. Insight is the goal.

## 3. Cohesion Over Collection

The environment should feel like a single system, not a pile of independently chosen tools and configs.

This shows up in:
- Consistent mental models
- Shared conventions (naming, configuration style, error handling)
- Components that are aware of each other
- A deployment story that treats the whole environment as one artifact

## 4. Craft Is Visible

Beauty and care should be perceptible in daily use, not just in theory.

This doesn't require pixel-perfect UIs. It requires:
- Thoughtful defaults
- High-quality feedback (diagnostics, error messages, status)
- Consistency in small details
- Respect for the user's time and attention

If it feels sloppy in daily use, it fails this principle.

## 5. Designed, Not Accumulated

Most dotfiles (including the current state of this repo) are the result of years of accretion — "I saw this cool thing and added it."

This project must be different.

Every major area should be able to answer:
- What is the *intent* of this layer?
- What are we explicitly *not* doing, and why?
- What would a clean, coherent version of this look like?

Historical accidents are allowed to exist temporarily, but they must be acknowledged and scheduled for removal or redesign.

## 6. Self-Awareness Is a First-Class Feature

A high-quality personal OS layer should be able to inspect and reason about itself.

This is why diagnostics/health is one of the highest priority areas. LazyVim's `:checkhealth` (and the broader Neovim ecosystem's approach) sets a real standard here: it is actionable, categorized, and gives you clear next steps instead of just raw information.

We want something at least that good for the shell + deployment + tooling environment.

## 7. Pride Is a Valid Success Criterion

It is acceptable — even desirable — for this system to be something you are genuinely proud of.

This is not vanity. It is a forcing function.

If you're not proud of it in five years, we will have failed.

## 8. MacOS Is the Platform, Not an Excuse

We are not building a Linux ricing environment that happens to run on macOS.

We are building something that respects the strengths of macOS while still demanding the same level of intentionality and ownership that the best custom Linux setups demonstrate.

We will use macOS-native tools where they are excellent. We will replace or augment them without hesitation where they are not.

## 9. Long-Term Maintainability Matters

This is infrastructure for your thinking and work. It should still be understandable and pleasant to work on in 3–5 years.

This means:
- Prefer clarity over cleverness
- Document intent, not just implementation
- Keep the surface area of "things you must hold in your head" as small as possible
- Make it easy to evolve individual pieces without breaking everything else

## 10. Ruthless Honesty

We will regularly ask hard questions:

- Is this actually good, or does it just feel familiar?
- Are we keeping this because it's high quality, or because we already invested time in it?
- Does this component still deserve to exist in the current vision?

Sentimentality has no place in high-craft systems work.

---

These principles are meant to be referenced constantly during design and implementation. If a decision feels in tension with one of them, we discuss it explicitly.
