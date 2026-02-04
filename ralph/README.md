# Ralph & PRD Skills Workflow

This document describes the workflow for using the `/prd` and `/ralph` skills to manage features in this project.

## Overview

The system uses two complementary skills:

- **`/prd` skill** — Generates PRD markdown files (authoring phase)
- **`/ralph` skill** — Converts PRDs to structured JSON for the agent loop (processing phase)

## `/prd` Skill (Authoring)

Generates one PRD markdown file at a time. This is the authoring step — you'd run it once per feature.

**Usage:**
```
/prd
```

**Process:**
1. You describe a feature
2. The skill asks clarifying questions
3. It outputs `tasks/prd-[feature-name].md`

**Example:**
```
/prd  →  tasks/prd-auth.md
/prd  →  tasks/prd-dashboard.md
/prd  →  tasks/prd-notifications.md
```

**Important:** Each feature benefits from its own clarifying questions and scoping conversation. The skill generates one PRD at a time intentionally.

## `/ralph` Skill (Conversion)

Converts PRD markdown files to structured JSON state files that the agent loop works with.

### Single Mode
Converts one PRD markdown file to JSON:
```
/ralph convert this PRD
```
→ Converts `tasks/prd-*.md` or `ralph/prd-*.md` → `.ralph-state/[name].json` with user stories

### Batch Mode
Converts all PRDs in one go:
```
/ralph convert all PRDs
```
→ Scans `tasks/` and `ralph/` for all `prd-*.md` files
→ Skips ones that already have stories
→ Converts the rest

## ralph-v2.sh Script

The orchestrator script provides additional capabilities:

### Auto-Conversion
During a normal run, it automatically converts any PRDs missing user stories before starting the agent loop:
```bash
./ralph-v2.sh --tool claude 20
```

### Explicit Conversion
Batch convert all PRDs and exit:
```bash
./ralph-v2.sh --convert --tool claude
```

### Single PRD Mode
Work on a specific PRD only (instead of processing all PRDs):
```bash
./ralph-v2.sh --single agent-config-tabs --tool claude 20
```

The PRD name can be:
- The filename without extension (e.g., `agent-config-tabs`)
- The safe name from `.ralph-state/` (e.g., `agent_config_tabs`)
- With or without `.json` extension

### Status Dashboard
Show all PRDs and their progress:
```bash
./ralph-v2.sh --status
```

## Complete Workflow

```bash
# 1. Author PRDs (one at a time via /prd skill)
/prd  →  tasks/prd-auth.md
/prd  →  tasks/prd-dashboard.md
/prd  →  tasks/prd-notifications.md

# 2. Convert to JSON (pick one approach)
/ralph convert all PRDs          # batch via skill
./ralph-v2.sh --convert --tool claude  # batch via script
# OR just skip this — ralph-v2.sh auto-converts on run

# 3. Run the agent loop
# Option A: Process all PRDs sequentially (default)
./ralph-v2.sh --tool claude 20

# Option B: Work on a single PRD only
./ralph-v2.sh --single agent-config-tabs --tool claude 20
```

## Directory Structure

```
ralph/
├── .ralph-state/          # JSON state files for each PRD
│   ├── agent_config_tabs.json
│   └── ...
├── .last-prd              # Tracks current PRD
├── prd.json               # Symlink to current PRD state
├── current-prd.json       # Symlink to current PRD state
├── progress.txt           # Progress log and codebase patterns
├── ralph-v2.sh            # Orchestrator script
└── README.md              # This file

tasks/
└── prd-*.md               # PRD markdown files (source)

ralph/prd-*.md             # Alternative PRD location
```

## Execution Modes

### Batch Mode (Default)
The agent works through all PRDs sequentially:
```bash
./ralph-v2.sh --tool claude 20
```

When a PRD completes, it automatically switches to the next pending PRD.

### Single PRD Mode
Work on one specific PRD only:
```bash
./ralph-v2.sh --single agent-config-tabs --tool claude 20
```

When the specified PRD completes, the agent exits (doesn't move to next PRD).

### Status Check
View all PRDs and their current status:
```bash
./ralph-v2.sh --status
```

## Key Points

- **Single authoring**: `/prd` generates one PRD at a time with questions
- **Batch conversion**: `/ralph` can convert multiple PRDs to JSON at once
- **Auto-conversion**: The agent loop auto-converts PRDs before starting
- **Flexible execution**: Process all PRDs sequentially or focus on one at a time

## See Also

- `ralph/progress.txt` — Contains codebase patterns and learnings from iterations
- `ralph/ralph-v2.sh` — The orchestrator script implementation
