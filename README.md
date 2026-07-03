# agent-templates

Reusable starter kit for Claude Code multi-agent orchestration: per-domain
subagent definitions (`.claude/agents/*.md`) and a `CLAUDE.md` template,
meant to be copied into a project repo and adapted there.

## Structure

```
agent-templates/
├── README.md
├── CLAUDE.md.template        # orchestration rules for the lead session
├── copy-template.sh          # bootstraps a target repo from a domain
├── docs/
│   ├── usage.md              # full usage guide
│   └── agent-file-format.md # how the .claude/agents/*.md files are structured
├── mobile/.claude/agents/     rn-ui-dev, rn-state-nav-dev, rn-reviewer
├── backend/.claude/agents/    api-dev, backend-reviewer
└── website/.claude/agents/    web-dev, web-reviewer
```

## Quick start

```bash
./copy-template.sh <mobile|backend|website> /path/to/target-repo
cd /path/to/target-repo
graphify . && graphify claude install && graphify hook install
```

See [`docs/usage.md`](docs/usage.md) for the full guide — the two-tier
global/project agent system, what the script does under the hood, the
Graphify integration, and how to add a new domain. See
[`docs/agent-file-format.md`](docs/agent-file-format.md) for how the
`.claude/agents/*.md` files themselves are structured (frontmatter fields,
what each one means).
