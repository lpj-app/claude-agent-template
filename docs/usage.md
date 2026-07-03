# Usage

## What this is

Starter templates for Claude Code subagents (`.claude/agents/*.md`) and a
matching `CLAUDE.md`, organized per domain (`mobile`, `backend`, `website`).
They get **copied** into a project repo and then adapted there — this repo is
not kept in sync with the target repos via a submodule or symlink. Once
copied, a project's agents are free to diverge from the template.

## Two-tier agent system

Claude Code reads subagents from two places:

- `~/.claude/agents/` — **global**, applies automatically to every repo you
  work in. Put genuinely generic workers here (e.g. a general code reviewer,
  a test runner) once, so you don't duplicate them across projects.
- `<repo>/.claude/agents/` — **project-local**, shared with your team via
  git. This is where the domain-specific workers from this template repo
  land (`rn-ui-dev`, `api-dev`, `web-dev`, ...) — they only make sense for
  one kind of project, so they belong per-repo, not global.

## Bootstrapping a project repo

```bash
./copy-template.sh <mobile|backend|website> <target-repo-path>
```

This:
1. Copies every `<domain>/.claude/agents/*.md` into
   `<target-repo-path>/.claude/agents/` — files that already exist at the
   destination are **skipped**, never overwritten.
2. Creates `<target-repo-path>/CLAUDE.md` from `CLAUDE.md.template` if none
   exists yet. If one already exists, it's left alone — merge the relevant
   sections in by hand.
3. Prints a reminder for the Graphify bootstrap step (see below).

Run it once per project. After that, edit the copied files directly in the
target repo — there's no further link back to this template repo.

## Graphify integration

Each project repo should have its own knowledge graph so the lead session
can query the codebase instead of grepping blind. Set it up once per repo:

```bash
graphify . && graphify claude install && graphify hook install
```

- `graphify .` builds the initial graph.
- `graphify claude install` wires instructions into the repo's `CLAUDE.md`
  telling the lead to check the graph before answering codebase questions.
- `graphify hook install` adds a post-commit hook that incrementally rebuilds
  the graph after code changes (`graphify --update` under the hood) — no
  manual full rebuild needed.

The `CLAUDE.md.template` in this repo already includes a step telling the
lead to run `graphify . --update` after delegating implementation work, as a
belt-and-suspenders complement to the hook.

## Adding a new domain

1. Create `<new-domain>/.claude/agents/*.md` following the existing
   dev + reviewer pattern (one or more implementers with `Read, Write, Edit,
   Glob, Grep, Bash`, one read-only reviewer with `Read, Grep, Glob, Bash`
   and no write access).
2. That's it — `copy-template.sh` lists and copies from any subfolder that
   contains a `.claude/agents/` directory, so no script changes are needed.

## Agent file format

For the exact structure of the `.claude/agents/*.md` files themselves —
which frontmatter fields exist, what each one means, and how the
`tools:` list is used as an actual enforcement mechanism (not just
documentation) — see [`agent-file-format.md`](agent-file-format.md).
