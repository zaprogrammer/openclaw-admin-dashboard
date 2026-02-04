#!/bin/bash
# Ralph Wiggum v2 - Multi-PRD AI agent loop with per-feature progress tracking
#
# Usage:
#   ./ralph-v2.sh [--tool amp|claude|opencode] [--status] [--convert] [--single <prd>] [max_iterations]
#
# Options:
#   --tool amp|claude|opencode   AI tool to use (default: amp)
#   --status                     Show status dashboard and exit
#   --convert                    Convert all PRD markdown files to JSON (populate user stories) and exit
#   --single <prd>               Work on a single PRD by name (filename without extension or safe name)
#   max_iterations               Max agent iterations (default: 10)
#
# PRD files are scanned from both tasks/ and ralph/ directories (prd-*.md pattern)
# State is tracked per-PRD in ralph/.ralph-state/*.json
#
# Examples:
#   ./ralph-v2.sh --status                    # Show all PRDs and progress
#   ./ralph-v2.sh --convert --tool claude     # Convert all PRDs using claude
#   ./ralph-v2.sh --tool claude 20            # Run agent loop with claude, 20 iterations
#   ./ralph-v2.sh --single agent-config-tabs  # Work on a single PRD

set -e

# ─────────────────────────────────────────────────────────────────────────────
# Parse arguments
# ─────────────────────────────────────────────────────────────────────────────

TOOL="amp"
MAX_ITERATIONS=10
MODE="run"  # run | status | convert
SINGLE_PRD=""  # If set, only work on this specific PRD

while [[ $# -gt 0 ]]; do
  case $1 in
    --tool)
      TOOL="$2"
      shift 2
      ;;
    --tool=*)
      TOOL="${1#*=}"
      shift
      ;;
    --status)
      MODE="status"
      shift
      ;;
    --convert)
      MODE="convert"
      shift
      ;;
    --single)
      SINGLE_PRD="$2"
      shift 2
      ;;
    --single=*)
      SINGLE_PRD="${1#*=}"
      shift
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS="$1"
      fi
      shift
      ;;
  esac
done

# Validate tool choice (only needed for run/convert modes)
if [[ "$MODE" != "status" ]]; then
  if [[ "$TOOL" != "amp" && "$TOOL" != "claude" && "$TOOL" != "opencode" ]]; then
    echo "Error: Invalid tool '$TOOL'. Must be 'amp', 'claude', or 'opencode'."
    exit 1
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# Paths
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
ARCHIVE_DIR="$SCRIPT_DIR/archive"
STATE_DIR="$SCRIPT_DIR/.ralph-state"
LAST_PRD_FILE="$SCRIPT_DIR/.last-prd"
TASKS_DIR="$PROJECT_ROOT/tasks"

mkdir -p "$STATE_DIR"
mkdir -p "$ARCHIVE_DIR"

# ─────────────────────────────────────────────────────────────────────────────
# Utility functions
# ─────────────────────────────────────────────────────────────────────────────

generate_safe_filename() {
  local prd_name="$1"
  echo "$prd_name" | sed 's/\.md$//' | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '_' | sed 's/_$//; s/^prd_//'
}

get_current_prd_info() {
  local prd_file="$1"
  if [ -f "$prd_file" ]; then
    local branch_name=$(jq -r '.branchName // empty' "$prd_file" 2>/dev/null || echo "")
    local prd_title=$(jq -r '.title // .name // empty' "$prd_file" 2>/dev/null || echo "")
    echo "${branch_name:-unknown}|${prd_title:-unknown}"
  else
    echo "unknown|unknown"
  fi
}

# Get timestamp in ISO format (portable)
iso_timestamp() {
  date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S'
}

# Switch to the correct git branch for a PRD, creating from main if needed
switch_to_branch() {
  local target_branch="$1"
  local current_branch
  current_branch=$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo "")

  if [ "$current_branch" == "$target_branch" ]; then
    echo "  Already on branch: $target_branch"
    return 0
  fi

  echo "  Switching branch: $current_branch -> $target_branch"

  # Stash any uncommitted changes
  local stash_result
  stash_result=$(git -C "$PROJECT_ROOT" stash 2>&1) || true

  # Try checkout existing branch, or create from main
  if git -C "$PROJECT_ROOT" rev-parse --verify "$target_branch" >/dev/null 2>&1; then
    git -C "$PROJECT_ROOT" checkout "$target_branch" 2>&1 || {
      echo "  Warning: Failed to checkout $target_branch"
      # Pop stash if we stashed
      [[ "$stash_result" != *"No local changes"* ]] && git -C "$PROJECT_ROOT" stash pop 2>/dev/null || true
      return 1
    }
  else
    # Determine base branch (main or master)
    local base_branch="main"
    if ! git -C "$PROJECT_ROOT" rev-parse --verify "main" >/dev/null 2>&1; then
      base_branch="master"
    fi
    echo "  Creating new branch $target_branch from $base_branch"
    git -C "$PROJECT_ROOT" checkout -b "$target_branch" "$base_branch" 2>&1 || {
      echo "  Warning: Failed to create branch $target_branch"
      [[ "$stash_result" != *"No local changes"* ]] && git -C "$PROJECT_ROOT" stash pop 2>/dev/null || true
      return 1
    }
  fi

  # Pop stash onto new branch if we stashed
  if [[ "$stash_result" != *"No local changes"* ]]; then
    git -C "$PROJECT_ROOT" stash pop 2>/dev/null || {
      echo "  Warning: Stash pop had conflicts. Check git stash list."
    }
  fi

  return 0
}

# Count user stories in a state JSON
count_stories() {
  local json_file="$1"
  jq '[.userStories // [] | length, [.userStories[]? | select(.passes==true)] | length] | "\(.[0])|\(.[1])"' -r "$json_file" 2>/dev/null || echo "0|0"
}

# ─────────────────────────────────────────────────────────────────────────────
# Scan for PRD markdown files in BOTH tasks/ and ralph/ directories
# ─────────────────────────────────────────────────────────────────────────────

scan_prd_files() {
  local -a files=()
  local -A seen_basenames=()

  for search_dir in "$TASKS_DIR" "$SCRIPT_DIR"; do
    if [ -d "$search_dir" ]; then
      while IFS= read -r file; do
        local bn
        bn=$(basename "$file")
        # Deduplicate by basename (tasks/ takes priority)
        if [ -z "${seen_basenames[$bn]:-}" ]; then
          seen_basenames[$bn]=1
          files+=("$file")
        fi
      done < <(find "$search_dir" -maxdepth 1 -name "prd-*.md" -type f 2>/dev/null | sort)
    fi
  done

  printf '%s\n' "${files[@]}"
}

# ─────────────────────────────────────────────────────────────────────────────
# STATUS MODE: Show dashboard and exit
# ─────────────────────────────────────────────────────────────────────────────

if [[ "$MODE" == "status" ]]; then
  echo ""
  echo "Ralph PRD Status Dashboard"
  echo "=========================="
  echo ""

  total=0
  completed=0
  in_progress=0
  pending=0

  for json_file in "$STATE_DIR"/*.json; do
    [ -f "$json_file" ] || continue
    [[ "$(basename "$json_file")" == "current-prd.json" ]] && continue

    total=$((total + 1))
    title=$(jq -r '.title // "unknown"' "$json_file")
    status=$(jq -r '.status // "unknown"' "$json_file")
    iters=$(jq -r '.iterations // 0' "$json_file")
    branch=$(jq -r '.branchName // "unknown"' "$json_file")
    story_counts=$(count_stories "$json_file")
    total_stories=$(echo "$story_counts" | cut -d'|' -f1)
    done_stories=$(echo "$story_counts" | cut -d'|' -f2)

    # Status icon
    case "$status" in
      completed)   icon="[done]"; completed=$((completed + 1)) ;;
      in-progress) icon="[WIP] "; in_progress=$((in_progress + 1)) ;;
      pending)     icon="[    ]"; pending=$((pending + 1)) ;;
      *)           icon="[ ?? ]" ;;
    esac

    # Stories info
    if [ "$total_stories" -gt 0 ]; then
      stories_info="$done_stories/$total_stories stories"
    else
      stories_info="no stories yet"
    fi

    printf "  %s %-30s %s  (%d iters)\n" "$icon" "$title" "$stories_info" "$iters"
    printf "        branch: %s\n" "$branch"
  done

  echo ""
  echo "---"
  printf "  Total: %d | Completed: %d | In Progress: %d | Pending: %d\n" "$total" "$completed" "$in_progress" "$pending"
  echo ""

  if [ $total -eq 0 ]; then
    echo "  No PRD state files found."
    echo "  Add prd-*.md files to tasks/ or ralph/ and run: ./ralph-v2.sh"
  fi

  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Scan and create/update state files for all PRD markdown files
# ─────────────────────────────────────────────────────────────────────────────

echo "Scanning for PRD markdown files in tasks/ and ralph/..."
PRD_MD_FILES=()
while IFS= read -r file; do
  [ -n "$file" ] && PRD_MD_FILES+=("$file")
done < <(scan_prd_files)

if [ ${#PRD_MD_FILES[@]} -eq 0 ]; then
  echo "Error: No PRD markdown files found (prd-*.md)"
  echo "Expected locations: $TASKS_DIR/ or $SCRIPT_DIR/"
  exit 1
fi

echo "  Found ${#PRD_MD_FILES[@]} PRD file(s)"
echo ""
echo "Managing PRD state files..."

NEW_PRDS=()
for md_file in "${PRD_MD_FILES[@]}"; do
  base_name=$(basename "$md_file" .md)
  safe_name=$(generate_safe_filename "$base_name")
  prd_json="$STATE_DIR/${safe_name}.json"

  if [ ! -f "$prd_json" ]; then
    feature_name=$(echo "$base_name" | sed 's/^prd-//')
    echo "  + Creating new PRD state: ${safe_name}.json"

    cat > "$prd_json" << EOF
{
  "id": "$(date +%s)-$(openssl rand -hex 4 2>/dev/null || echo $$)",
  "title": "$feature_name",
  "sourceMarkdown": "$md_file",
  "sourceFilename": "$(basename "$md_file")",
  "branchName": "ralph/${feature_name}",
  "status": "pending",
  "createdAt": "$(iso_timestamp)",
  "updatedAt": "$(iso_timestamp)",
  "iterations": 0,
  "tasks": [],
  "completedTasks": [],
  "lastTool": "",
  "metadata": {},
  "userStories": []
}
EOF
    NEW_PRDS+=("$prd_json")
  else
    # Update source path in case it moved
    jq --arg md "$md_file" --arg fn "$(basename "$md_file")" \
      '.sourceMarkdown = $md | .sourceFilename = $fn' "$prd_json" > "$prd_json.tmp" \
      && mv "$prd_json.tmp" "$prd_json" 2>/dev/null || true
    status=$(jq -r '.status // "unknown"' "$prd_json" 2>/dev/null || echo "unknown")
    story_counts=$(count_stories "$prd_json")
    total_stories=$(echo "$story_counts" | cut -d'|' -f1)

    # Track PRDs that exist but have no user stories yet
    if [ "$total_stories" -eq 0 ]; then
      NEW_PRDS+=("$prd_json")
    fi

    echo "  = Existing: ${safe_name}.json (status: $status, stories: $total_stories)"
  fi
done

echo ""

# ─────────────────────────────────────────────────────────────────────────────
# AUTO-CONVERT: Populate user stories for PRDs that don't have them yet
# ─────────────────────────────────────────────────────────────────────────────

convert_prd_to_json() {
  local prd_json="$1"
  local source_md
  source_md=$(jq -r '.sourceMarkdown // ""' "$prd_json")
  local title
  title=$(jq -r '.title // "unknown"' "$prd_json")

  if [ -z "$source_md" ] || [ ! -f "$source_md" ]; then
    echo "    Warning: Source markdown not found for $title"
    return 1
  fi

  echo "    Converting: $title ..."

  # Build the conversion prompt
  local convert_prompt
  convert_prompt=$(cat << 'PROMPT_END'
You are converting a PRD markdown file to a structured JSON array of user stories.

RULES:
- Each story must be completable in ONE iteration (small, focused)
- Order by dependency (schema -> backend -> UI)
- Every story MUST have "Typecheck passes" in acceptanceCriteria
- UI stories MUST have "Verify in browser using dev-browser skill" in acceptanceCriteria
- IDs are sequential: US-001, US-002, etc.
- All stories start with "passes": false

OUTPUT FORMAT - Return ONLY a valid JSON array, no markdown fences, no explanation:
[
  {
    "id": "US-001",
    "title": "Story title",
    "description": "As a [user], I want [feature] so that [benefit]",
    "acceptanceCriteria": ["criterion 1", "Typecheck passes"],
    "priority": 1,
    "passes": false,
    "notes": ""
  }
]

Here is the PRD markdown to convert:

PROMPT_END
  )

  local full_prompt="${convert_prompt}
$(cat "$source_md")"

  local json_output=""
  local TEMP_CONVERT
  TEMP_CONVERT=$(mktemp)
  echo "$full_prompt" > "$TEMP_CONVERT"

  if [[ "$TOOL" == "amp" ]]; then
    json_output=$(cat "$TEMP_CONVERT" | amp --dangerously-allow-all 2>/dev/null) || true
  elif [[ "$TOOL" == "claude" ]]; then
    json_output=$(claude --dangerously-skip-permissions --print < "$TEMP_CONVERT" 2>/dev/null) || true
  elif [[ "$TOOL" == "opencode" ]]; then
    json_output=$(opencode run --agent build --model zai-coding-plan/glm-4.7 "$(cat "$TEMP_CONVERT")" 2>/dev/null) || true
  fi

  rm -f "$TEMP_CONVERT"

  # Try to extract JSON array from output (handle markdown fences, extra text)
  local cleaned_output
  cleaned_output=$(echo "$json_output" | sed -n '/^\[/,/^\]/p' | head -500)

  # If sed didn't find a bare array, try stripping markdown fences
  if [ -z "$cleaned_output" ]; then
    cleaned_output=$(echo "$json_output" | sed -n '/```json/,/```/p' | sed '1d;$d')
  fi
  if [ -z "$cleaned_output" ]; then
    cleaned_output=$(echo "$json_output" | sed -n '/```/,/```/p' | sed '1d;$d')
  fi

  # Validate it's a JSON array
  if echo "$cleaned_output" | jq 'type == "array"' >/dev/null 2>&1; then
    local story_count
    story_count=$(echo "$cleaned_output" | jq 'length')

    # Merge into the state JSON
    jq --argjson stories "$cleaned_output" \
      '.userStories = $stories | .updatedAt = "'"$(iso_timestamp)"'"' \
      "$prd_json" > "$prd_json.tmp" && mv "$prd_json.tmp" "$prd_json"

    echo "    Added $story_count user stories to $(basename "$prd_json")"
    return 0
  else
    echo "    Warning: Failed to parse AI output as JSON array for $title"
    echo "    The agent will parse the markdown on first iteration instead."
    return 1
  fi
}

# Convert mode: convert all and exit
if [[ "$MODE" == "convert" ]]; then
  echo "Converting PRD markdown files to structured JSON..."
  echo ""

  converted=0
  skipped=0
  failed=0

  for json_file in "$STATE_DIR"/*.json; do
    [ -f "$json_file" ] || continue
    [[ "$(basename "$json_file")" == "current-prd.json" ]] && continue

    story_counts=$(count_stories "$json_file")
    total_stories=$(echo "$story_counts" | cut -d'|' -f1)
    title=$(jq -r '.title // "unknown"' "$json_file")

    if [ "$total_stories" -gt 0 ]; then
      echo "  Skipping $title ($total_stories stories already exist)"
      skipped=$((skipped + 1))
      continue
    fi

    if convert_prd_to_json "$json_file"; then
      converted=$((converted + 1))
    else
      failed=$((failed + 1))
    fi
  done

  echo ""
  echo "Conversion complete: $converted converted, $skipped skipped, $failed failed"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# RUN MODE: Auto-convert new PRDs that have no user stories
# ─────────────────────────────────────────────────────────────────────────────

if [ ${#NEW_PRDS[@]} -gt 0 ]; then
  echo "Auto-converting ${#NEW_PRDS[@]} PRD(s) without user stories..."
  for prd_json in "${NEW_PRDS[@]}"; do
    convert_prd_to_json "$prd_json" || true
  done
  echo ""
fi

# ─────────────────────────────────────────────────────────────────────────────
# Archive previous run if PRD changed
# ─────────────────────────────────────────────────────────────────────────────

if [ -f "$STATE_DIR/current-prd.json" ] && [ -f "$LAST_PRD_FILE" ]; then
  CURRENT_PRD_INFO=$(get_current_prd_info "$STATE_DIR/current-prd.json")
  LAST_PRD=$(cat "$LAST_PRD_FILE" 2>/dev/null || echo "")

  if [ -n "$LAST_PRD" ] && [ "$CURRENT_PRD_INFO" != "$LAST_PRD" ]; then
    LAST_BRANCH=$(echo "$LAST_PRD" | cut -d'|' -f1)
    DATE=$(date +%Y-%m-%d-%H%M%S)
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^ralph/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    cp "$STATE_DIR"/*.json "$ARCHIVE_FOLDER/" 2>/dev/null || true
    [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
    echo "  Archived to: $ARCHIVE_FOLDER"

    echo "# Ralph Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# Select current PRD to work on
# ─────────────────────────────────────────────────────────────────────────────

CURRENT_PRD_JSON=""

# Priority 0: Single PRD mode (if --single specified)
if [ -n "$SINGLE_PRD" ]; then
  echo "Single PRD mode: searching for '$SINGLE_PRD'..."

  # Normalize the PRD name to match safe naming in JSON files
  SINGLE_SAFE_NAME=$(echo "$SINGLE_PRD" | sed 's/\.md$//' | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '_' | sed 's/^prd_//' | sed 's/_$//')

  # Try to find by safe name
  if [ -f "$STATE_DIR/${SINGLE_SAFE_NAME}.json" ]; then
    CURRENT_PRD_JSON="$STATE_DIR/${SINGLE_SAFE_NAME}.json"
    echo "Found PRD: $(basename "$CURRENT_PRD_JSON" .json)"
  else
    # Try exact match with json extension
    if [ -f "$STATE_DIR/${SINGLE_PRD}.json" ]; then
      CURRENT_PRD_JSON="$STATE_DIR/${SINGLE_PRD}.json"
      echo "Found PRD: $(basename "$CURRENT_PRD_JSON" .json)"
    else
      # List available PRDs for user
      echo ""
      echo "Error: PRD '$SINGLE_PRD' not found."
      echo ""
      echo "Available PRDs:"
      for json_file in "$STATE_DIR"/*.json; do
        [ -f "$json_file" ] || continue
        [[ "$(basename "$json_file")" == "current-prd.json" ]] && continue
        title=$(jq -r '.title // "unknown"' "$json_file")
        echo "  - $(basename "$json_file" .json) (title: $title)"
      done
      echo ""
      echo "Use ./ralph-v2.sh --status to see all PRDs."
      exit 1
    fi
  fi

  # Skip the rest of the priority logic
  if [ -n "$CURRENT_PRD_JSON" ]; then
    echo "Single PRD mode activated. Will work on: $(jq -r '.title' "$CURRENT_PRD_JSON")"
  fi
fi

# Priority 1: Find in-progress PRD (only if not in single mode)
if [ -z "$CURRENT_PRD_JSON" ]; then
  for json_file in "$STATE_DIR"/*.json; do
    [ -f "$json_file" ] || continue
    [[ "$(basename "$json_file")" == "current-prd.json" ]] && continue
    status=$(jq -r '.status // "unknown"' "$json_file" 2>/dev/null || echo "unknown")
    if [ "$status" == "in-progress" ]; then
      CURRENT_PRD_JSON="$json_file"
      echo "Resuming in-progress PRD: $(basename "$json_file" .json)"
      break
    fi
  done
fi

# Priority 2: Find first pending PRD
if [ -z "$CURRENT_PRD_JSON" ]; then
  for json_file in "$STATE_DIR"/*.json; do
    [ -f "$json_file" ] || continue
    [[ "$(basename "$json_file")" == "current-prd.json" ]] && continue
    status=$(jq -r '.status // "unknown"' "$json_file" 2>/dev/null || echo "unknown")
    if [ "$status" == "pending" ]; then
      CURRENT_PRD_JSON="$json_file"
      echo "Starting new PRD: $(basename "$json_file" .json)"
      break
    fi
  done
fi

# Priority 3: Most recently updated non-completed
if [ -z "$CURRENT_PRD_JSON" ]; then
  for json_file in $(ls -t "$STATE_DIR"/*.json 2>/dev/null); do
    [ -f "$json_file" ] || continue
    [[ "$(basename "$json_file")" == "current-prd.json" ]] && continue
    status=$(jq -r '.status // "unknown"' "$json_file" 2>/dev/null || echo "unknown")
    if [ "$status" != "completed" ]; then
      CURRENT_PRD_JSON="$json_file"
      echo "Resuming PRD: $(basename "$json_file" .json) (status: $status)"
      break
    fi
  done
fi

# Priority 4: All completed — report and exit
if [ -z "$CURRENT_PRD_JSON" ]; then
  echo ""
  echo "All PRDs are completed! Nothing to do."
  echo "Run ./ralph-v2.sh --status to see the dashboard."
  echo "Add new prd-*.md files to tasks/ or ralph/ to continue."
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Set up current PRD context
# ─────────────────────────────────────────────────────────────────────────────

ln -sf "$CURRENT_PRD_JSON" "$STATE_DIR/current-prd.json" 2>/dev/null || true
ln -sf "$CURRENT_PRD_JSON" "$SCRIPT_DIR/current-prd.json" 2>/dev/null || true
ln -sf "$CURRENT_PRD_JSON" "$SCRIPT_DIR/prd.json" 2>/dev/null || true

CURRENT_PRD_INFO=$(get_current_prd_info "$CURRENT_PRD_JSON")
echo "$CURRENT_PRD_INFO" > "$LAST_PRD_FILE"
CURRENT_BRANCH=$(echo "$CURRENT_PRD_INFO" | cut -d'|' -f1)
CURRENT_TITLE=$(echo "$CURRENT_PRD_INFO" | cut -d'|' -f2)

# Initialize progress file
if [ ! -f "$PROGRESS_FILE" ]; then
  echo "# Ralph Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
fi

echo "" >> "$PROGRESS_FILE"
echo "=== Working on: $CURRENT_TITLE (Branch: $CURRENT_BRANCH) ===" >> "$PROGRESS_FILE"
echo "PRD JSON: $(basename "$CURRENT_PRD_JSON")" >> "$PROGRESS_FILE"
echo "Source: $(jq -r '.sourceFilename // "unknown"' "$CURRENT_PRD_JSON")" >> "$PROGRESS_FILE"
echo "Started: $(date)" >> "$PROGRESS_FILE"

# Count PRDs for display
completed_prds=0
total_prds=0
for jf in "$STATE_DIR"/*.json; do
  [ -f "$jf" ] || continue
  [[ "$(basename "$jf")" == "current-prd.json" ]] && continue
  total_prds=$((total_prds + 1))
  s=$(jq -r '.status // ""' "$jf" 2>/dev/null || echo "")
  [ "$s" == "completed" ] && completed_prds=$((completed_prds + 1))
done

story_counts=$(count_stories "$CURRENT_PRD_JSON")
total_stories=$(echo "$story_counts" | cut -d'|' -f1)
done_stories=$(echo "$story_counts" | cut -d'|' -f2)

echo ""
echo "================================================================="
echo "  Ralph Wiggum v2 - Multi-PRD AI Agent Loop"
echo "================================================================="
echo "  Tool:           $TOOL"
echo "  Max iterations: $MAX_ITERATIONS"
echo "  Mode:           $([ -n "$SINGLE_PRD" ] && echo "SINGLE PRD" || echo "BATCH (all PRDs)")"
echo "  Active PRD:     $CURRENT_TITLE"
echo "  Branch:         $CURRENT_BRANCH"
echo "  Stories:        $done_stories/$total_stories complete"
echo "  PRDs:           $completed_prds/$total_prds completed"
echo "  State file:     $(basename "$CURRENT_PRD_JSON")"
echo "================================================================="
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Switch to the correct git branch
# ─────────────────────────────────────────────────────────────────────────────

switch_to_branch "$CURRENT_BRANCH"

# Update status to in-progress
jq '.status = "in-progress" | .updatedAt = "'"$(iso_timestamp)"'"' \
  "$CURRENT_PRD_JSON" > "$CURRENT_PRD_JSON.tmp" && mv "$CURRENT_PRD_JSON.tmp" "$CURRENT_PRD_JSON"

# ─────────────────────────────────────────────────────────────────────────────
# Main agent loop
# ─────────────────────────────────────────────────────────────────────────────

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "==============================================================="
  echo "  Ralph Iteration $i of $MAX_ITERATIONS ($TOOL)"
  echo "  PRD: $CURRENT_TITLE ($completed_prds/$total_prds PRDs done)"
  echo "==============================================================="

  # Determine prompt file
  PROMPT_FILE="$SCRIPT_DIR/prompt.md"
  if [[ "$TOOL" == "claude" || "$TOOL" == "opencode" ]]; then
    # Use project-root CLAUDE.md (the agent instructions)
    PROMPT_FILE="$PROJECT_ROOT/CLAUDE.md"
  fi

  # Get the source markdown file
  SOURCE_MD=$(jq -r '.sourceMarkdown // ""' "$CURRENT_PRD_JSON")

  # Build enhanced prompt with full PRD context
  TEMP_PROMPT=$(mktemp)
  {
    echo "# Ralph Agent Context"
    echo ""
    echo "Current PRD: $CURRENT_TITLE"
    echo "Branch: $CURRENT_BRANCH"
    echo "State File: $(basename "$CURRENT_PRD_JSON")"
    echo "State File Path: $CURRENT_PRD_JSON"
    echo "Iteration: $i of $MAX_ITERATIONS"
    echo "Tool: $TOOL"
    echo ""
    echo "## Source PRD"
    echo ""
    if [ -n "$SOURCE_MD" ] && [ -f "$SOURCE_MD" ]; then
      cat "$SOURCE_MD"
    else
      echo "Warning: Source PRD file not found at $SOURCE_MD"
    fi
    echo ""
    echo "## Agent Instructions"
    echo ""
    cat "$PROMPT_FILE" 2>/dev/null || echo "No prompt file found at $PROMPT_FILE"
  } > "$TEMP_PROMPT"

  # Run the agent
  OUTPUT=""
  if [[ "$TOOL" == "amp" ]]; then
    echo "[Running: amp --dangerously-allow-all]"
    OUTPUT=$(cat "$TEMP_PROMPT" | amp --dangerously-allow-all 2>&1 | tee /dev/stderr) || true
  elif [[ "$TOOL" == "claude" ]]; then
    echo "[Running: claude --dangerously-skip-permissions --print]"
    OUTPUT=$(claude --dangerously-skip-permissions --print < "$TEMP_PROMPT" 2>&1 | tee /dev/stderr) || true
  elif [[ "$TOOL" == "opencode" ]]; then
    echo "[Running: opencode run --agent build]"
    OUTPUT=$(opencode run --agent build --model zai-coding-plan/glm-4.7 "$(cat "$TEMP_PROMPT")" 2>&1 | tee /dev/stderr) || true
  fi

  rm -f "$TEMP_PROMPT"

  # Update iteration count
  jq --arg tool "$TOOL" '.iterations += 1 | .lastTool = $tool | .updatedAt = "'"$(iso_timestamp)"'"' \
    "$CURRENT_PRD_JSON" > "$CURRENT_PRD_JSON.tmp" && mv "$CURRENT_PRD_JSON.tmp" "$CURRENT_PRD_JSON"

  # Append to progress log
  echo "" >> "$PROGRESS_FILE"
  echo "--- Iteration $i ($(date)) ---" >> "$PROGRESS_FILE"
  echo "$OUTPUT" | tail -n 20 >> "$PROGRESS_FILE" 2>/dev/null || true

  # ─── Check for completion signal ─────────────────────────────────
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo ">> PRD completed: $CURRENT_TITLE"
    jq '.status = "completed" | .completedAt = "'"$(iso_timestamp)"'"' \
      "$CURRENT_PRD_JSON" > "$CURRENT_PRD_JSON.tmp" && mv "$CURRENT_PRD_JSON.tmp" "$CURRENT_PRD_JSON"

    echo "Completed at iteration $i" | tee -a "$PROGRESS_FILE"
    completed_prds=$((completed_prds + 1))

    # ─── Commit any remaining changes on this branch ─────────────
    git -C "$PROJECT_ROOT" add -A 2>/dev/null || true
    git -C "$PROJECT_ROOT" diff --cached --quiet 2>/dev/null || \
      git -C "$PROJECT_ROOT" commit -m "chore: complete PRD $CURRENT_TITLE" 2>/dev/null || true

    # ─── Check if single PRD mode ───────────────────────────────
    if [ -n "$SINGLE_PRD" ]; then
      echo ""
      echo "================================================================="
      echo "  Single PRD mode - $CURRENT_TITLE completed!"
      echo "================================================================="
      exit 0
    fi

    # ─── Find next pending PRD ───────────────────────────────────
    NEXT_PRD=""
    for json_file in "$STATE_DIR"/*.json; do
      [ -f "$json_file" ] || continue
      [[ "$(basename "$json_file")" == "current-prd.json" ]] && continue
      [ "$json_file" == "$CURRENT_PRD_JSON" ] && continue
      status=$(jq -r '.status // "unknown"' "$json_file" 2>/dev/null || echo "unknown")
      if [[ "$status" == "pending" || "$status" == "in-progress" ]]; then
        NEXT_PRD="$json_file"
        break
      fi
    done

    if [ -n "$NEXT_PRD" ]; then
      echo ""
      echo ">>> Moving to next PRD..."
      CURRENT_PRD_JSON="$NEXT_PRD"
      CURRENT_PRD_INFO=$(get_current_prd_info "$CURRENT_PRD_JSON")
      CURRENT_BRANCH=$(echo "$CURRENT_PRD_INFO" | cut -d'|' -f1)
      CURRENT_TITLE=$(echo "$CURRENT_PRD_INFO" | cut -d'|' -f2)

      # Update symlinks
      ln -sf "$CURRENT_PRD_JSON" "$STATE_DIR/current-prd.json"
      ln -sf "$CURRENT_PRD_JSON" "$SCRIPT_DIR/current-prd.json"
      ln -sf "$CURRENT_PRD_JSON" "$SCRIPT_DIR/prd.json"
      echo "$CURRENT_PRD_INFO" > "$LAST_PRD_FILE"

      # Switch git branch
      switch_to_branch "$CURRENT_BRANCH"

      # Update progress log
      echo "" >> "$PROGRESS_FILE"
      echo "=== Working on: $CURRENT_TITLE (Branch: $CURRENT_BRANCH) ===" >> "$PROGRESS_FILE"
      echo "PRD JSON: $(basename "$CURRENT_PRD_JSON")" >> "$PROGRESS_FILE"
      echo "Started: $(date)" >> "$PROGRESS_FILE"

      # Update status
      jq '.status = "in-progress" | .updatedAt = "'"$(iso_timestamp)"'"' \
        "$CURRENT_PRD_JSON" > "$CURRENT_PRD_JSON.tmp" && mv "$CURRENT_PRD_JSON.tmp" "$CURRENT_PRD_JSON"

      continue
    else
      echo ""
      echo "================================================================="
      echo "  Ralph completed all PRDs!"
      echo "  Total completed: $completed_prds/$total_prds"
      echo "================================================================="
      exit 0
    fi
  fi

  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Current PRD: $CURRENT_TITLE ($(jq -r '.status' "$CURRENT_PRD_JSON"))"
echo ""
echo "Check status:    ./ralph-v2.sh --status"
echo "Continue work:   ./ralph-v2.sh --tool $TOOL"
echo "Progress log:    $PROGRESS_FILE"
exit 1
