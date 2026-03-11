#!/usr/bin/env bash
# Research Agent setup: copy template, spec, skills into an experiment repo.
# Run from the experiment repo root:  bash research-agent/setup.sh
# Or from research-agent repo:       ./setup.sh /path/to/experiment-repo
# Options: --force  overwrite research_brief.md and spec if they exist

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=""

if [[ "$1" == "--force" ]]; then
  FORCE="1"
  shift
elif [[ "$1" == "-f" ]]; then
  FORCE="1"
  shift
fi

if [[ -n "$1" ]]; then
  TARGET_DIR="$(cd "$1" && pwd)"
else
  TARGET_DIR="$(pwd)"
fi

echo "Research Agent setup"
echo "  From: $SCRIPT_DIR"
echo "  To:   $TARGET_DIR"
echo ""

# 1. research_brief.md
if [[ -f "$TARGET_DIR/research_brief.md" ]] && [[ -z "$FORCE" ]]; then
  echo "[skip] research_brief.md already exists (use --force to overwrite)"
else
  mkdir -p "$TARGET_DIR"
  cp "$SCRIPT_DIR/template/research_brief.md" "$TARGET_DIR/research_brief.md"
  echo "[ok] research_brief.md"
fi

# 2. specs/
mkdir -p "$TARGET_DIR/specs"
cp "$SCRIPT_DIR/spec/research-agent-spec.md" "$TARGET_DIR/specs/research-agent-spec.md"
echo "[ok] specs/research-agent-spec.md"

# 3. .cursor/skills/
mkdir -p "$TARGET_DIR/.cursor/skills"
for skill in research-setup research-experiment research-synthesis research-read-external; do
  if [[ -d "$SCRIPT_DIR/skills/$skill" ]]; then
    mkdir -p "$TARGET_DIR/.cursor/skills/$skill"
    cp "$SCRIPT_DIR/skills/$skill/SKILL.md" "$TARGET_DIR/.cursor/skills/$skill/SKILL.md"
    echo "[ok] .cursor/skills/$skill/"
  fi
done

# 4. draft/
mkdir -p "$TARGET_DIR/draft"
if [[ ! -f "$TARGET_DIR/draft/.gitkeep" ]]; then
  echo "# Draft paper (research-agent)" > "$TARGET_DIR/draft/.gitkeep"
  echo "[ok] draft/"
else
  echo "[ok] draft/ (already exists)"
fi

echo ""
echo "Done. Next steps:"
echo "  1. Edit research_brief.md (at least: research goal)."
echo "  2. (Optional) Add Research Agent section to program.md — see: $SCRIPT_DIR/integration/program-snippet.md"
echo "  3. In Cursor, ask the agent: 'Read research_brief and start research'."
