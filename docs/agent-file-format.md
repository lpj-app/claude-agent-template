# Agent File Format

How the files in `.claude/agents/` are structured, field by field.

## Location & naming

- `<repo>/.claude/agents/*.md` — project-level, shared via git, only
  visible in that repo.
- `~/.claude/agents/*.md` — user-level, applies to every repo automatically
  (see [`usage.md`](usage.md) for when to use which).
- The filename should match the `name:` field (e.g. `rn-reviewer.md` →
  `name: rn-reviewer`).
- If a project-level and a user-level file share the same `name`, the
  project-level one wins.

## Structure

Each file is YAML frontmatter, then a Markdown body:

```markdown
---
name: rn-reviewer
description: Reviews code for quality, consistency, and adherence to the concept. Use after every implementation. Does not write feature code itself.
tools: Read, Grep, Glob, Bash
model: inherit
---
You are a senior reviewer. You read changed code, check it against the
concept, run lint/typecheck/tests (if available), and return a concrete
list of issues. You do not change code yourself.
```

## Frontmatter fields

**`name`** (required)
Kebab-case identifier, must match the filename.

**`description`** (required)
Not shown to anyone — it's read only by the lead session to decide *which*
subagent to delegate to and *when*. This is the single field that
determines whether delegation works at all, so make it specific: state what
the worker is for and, ideally, what it's explicitly *not* for (see how
`rn-ui-dev.md` says "use for views/styling" while `rn-state-nav-dev.md`
says "use for routing/stores" — the split in the wording is what keeps the
lead from picking the wrong one). A vague one-liner leads to no delegation
or the wrong worker getting picked.

**`tools`** (optional)
Comma-separated list of tool names the subagent is allowed to use (e.g.
`Read, Write, Edit, Glob, Grep, Bash`, plus any MCP tool names). If omitted,
the subagent inherits every tool the parent session has access to.

This is the actual enforcement mechanism in these templates, not just
documentation: every `*-reviewer.md` file lists only `Read, Grep, Glob,
Bash` — no `Write`/`Edit` — so the reviewer is *physically* unable to
change code, no matter what it's asked to do. That's the review gate from
the orchestration flow in `CLAUDE.md.template`.

**`model`** (optional)
One of `sonnet`, `opus`, `haiku`, `fable`, `inherit`, or a full model id
(e.g. `claude-opus-4-8`). `inherit` (the default used in these templates)
runs the subagent on whatever model the lead session is using. Pin a
cheaper model (e.g. `haiku`) for high-volume, low-complexity workers if you
want to cut cost — keep the lead itself on a stronger model.

## Body (the system prompt)

Everything after the closing `---` is the subagent's system prompt. It's
the *only* context the subagent starts with — it does not see the lead's
conversation, the user's original request, or what other subagents are
doing. Keep it to: role, explicit scope boundaries (what this worker must
*not* touch — the most useful line for avoiding overlap between workers),
and what "done" looks like. The lead is responsible for handing over the
actual task details (file paths, concept excerpt) at delegation time —
don't try to bake project specifics into the prompt itself.

## No nested delegation

None of these template files grant a `Task`/`Agent` tool, and the
`tools:` lists are kept explicit rather than omitted. That's intentional:
it keeps the mental model flat — one lead delegates to workers, workers
execute and report back, nothing spawns further subagents of its own. Keep
it that way unless you have a specific reason to go deeper; recursive
delegation multiplies cost and makes failures much harder to trace.
