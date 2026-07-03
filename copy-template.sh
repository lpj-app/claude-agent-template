#!/usr/bin/env bash
# Copies the agent templates for a domain into a target repo.
# Existing files are NEVER overwritten, only added.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: $0 <domain> <target-repo-path>"
    echo "Available domains:"
    for d in "$SCRIPT_DIR"/*/; do
        name="$(basename "$d")"
        [ -d "$d/.claude/agents" ] && echo "  - $name"
    done
    exit 1
}

[ $# -eq 2 ] || usage

DOMAIN="$1"
TARGET="$2"
SRC="$SCRIPT_DIR/$DOMAIN"

if [ ! -d "$SRC/.claude/agents" ]; then
    echo "Unknown domain '$DOMAIN'."
    usage
fi

if [ ! -d "$TARGET" ]; then
    echo "Target path '$TARGET' does not exist."
    exit 1
fi

mkdir -p "$TARGET/.claude/agents"

for f in "$SRC/.claude/agents/"*.md; do
    dest="$TARGET/.claude/agents/$(basename "$f")"
    if [ -e "$dest" ]; then
        echo "skipped (already exists): $dest"
    else
        cp "$f" "$dest"
        echo "copied: $dest"
    fi
done

if [ -e "$TARGET/CLAUDE.md" ]; then
    echo "CLAUDE.md already exists in '$TARGET' - not overwritten."
    echo "Manually merge the relevant sections from $SCRIPT_DIR/CLAUDE.md.template."
else
    cp "$SCRIPT_DIR/CLAUDE.md.template" "$TARGET/CLAUDE.md"
    echo "created: $TARGET/CLAUDE.md"
fi

echo ""
echo "Done. If graphify is not yet set up in '$TARGET':"
echo "  cd $TARGET && graphify . && graphify claude install && graphify hook install"
