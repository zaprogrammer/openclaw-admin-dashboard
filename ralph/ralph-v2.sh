#!/bin/bash
# Ralph Wiggum - Long-running AI agent loop with per-PRD progress tracking
# Usage: 
# ./ralph.sh [--tool amp|claude|opencode] [max_iterations]
#
# # Check status of all PRDs
#   ls -la .ralph-state/
#   for f in .ralph-state/*.json; do echo "$(basename $f): $(jq -r '.status' $f)"; done

set -e

# Parse arguments
TOOL="amp"  # Default to amp for backwards compatibility
MAX_ITERATIONS=10

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
    *)
      # Assume it's max_iterations if it's a number
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS="$1"
      fi
      shift
      ;;
  esac
done

# Validate tool choice
if [[ "$TOOL" != "amp" && "$TOOL" != "claude" && "$TOOL" != "opencode" ]]; then
  echo "Error: Invalid tool '$TOOL'. Must be 'amp', 'claude', or 'opencode'."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
ARCHIVE_DIR="$SCRIPT_DIR/archive"
STATE_DIR="$SCRIPT_DIR/.ralph-state"
LAST_PRD_FILE="$SCRIPT_DIR/.last-prd"
TASKS_DIR="$SCRIPT_DIR/../tasks"  # PRD markdown files location

# Create state directory for tracking PRD-specific files
mkdir -p "$STATE_DIR"
mkdir -p "$ARCHIVE_DIR"

# Function to generate safe filename from PRD name
generate_safe_filename() {
  local prd_name="$1"
  # Convert to lowercase, replace spaces/special chars with underscores, remove .md extension if present
  echo "$prd_name" | sed 's/\.md$//' | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '_' | sed 's/_$//; s/^prd_//'
}

# Function to get current PRD info
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

# Archive previous run if PRD changed
if [ -f "$STATE_DIR/current-prd.json" ] && [ -f "$LAST_PRD_FILE" ]; then
  CURRENT_PRD_INFO=$(get_current_prd_info "$STATE_DIR/current-prd.json")
  CURRENT_BRANCH=$(echo "$CURRENT_PRD_INFO" | cut -d'|' -f1)
  LAST_PRD=$(cat "$LAST_PRD_FILE" 2>/dev/null || echo "")
  
  if [ -n "$LAST_PRD" ] && [ "$CURRENT_PRD_INFO" != "$LAST_PRD" ]; then
    LAST_BRANCH=$(echo "$LAST_PRD" | cut -d'|' -f1)
    DATE=$(date +%Y-%m-%d-%H%M%S)
    # Strip "ralph/" prefix from branch name for folder
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^ralph/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"
    
    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    
    # Archive all PRD JSONs from state directory
    cp "$STATE_DIR"/*.json "$ARCHIVE_FOLDER/" 2>/dev/null || true
    [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
    echo "   Archived to: $ARCHIVE_FOLDER"
    
    # Reset progress file for new run
    echo "# Ralph Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "Active PRD: $CURRENT_BRANCH" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
  fi
fi

# Scan for PRD markdown files in tasks/
echo "Scanning for PRD markdown files in tasks/..."
PRD_MD_FILES=()

# Check if tasks directory exists
if [ -d "$TASKS_DIR" ]; then
  # Find all prd-*.md files in tasks/
  while IFS= read -r file; do
    PRD_MD_FILES+=("$file")
  done < <(find "$TASKS_DIR" -maxdepth 1 -name "prd-*.md" -type f 2>/dev/null | sort)
else
  echo "Warning: Tasks directory not found at $TASKS_DIR"
  echo "Falling back to SCRIPT_DIR for PRD files"
  while IFS= read -r file; do
    PRD_MD_FILES+=("$file")
  done < <(find "$SCRIPT_DIR" -maxdepth 1 -name "prd-*.md" -type f 2>/dev/null | sort)
fi

if [ ${#PRD_MD_FILES[@]} -eq 0 ]; then
  echo "Warning: No PRD markdown files found (prd-*.md)"
  echo "Expected location: $TASKS_DIR/"
fi

# Create or update JSON for each PRD markdown file
echo ""
echo "Managing PRD state files..."
for md_file in "${PRD_MD_FILES[@]}"; do
  # Generate base name from markdown file
  base_name=$(basename "$md_file" .md)
  safe_name=$(generate_safe_filename "$base_name")
  prd_json="$STATE_DIR/${safe_name}.json"
  
  # If JSON doesn't exist, create initial structure
  if [ ! -f "$prd_json" ]; then
    echo "  + Creating new PRD state: ${safe_name}.json"
    
    # Extract a readable feature name from the filename
    # e.g., prd-agent-config-tabs -> agent-config-tabs
    feature_name=$(echo "$base_name" | sed 's/^prd-//')
    
    cat > "$prd_json" << EOF
{
  "id": "$(date +%s)-$(openssl rand -hex 4 2>/dev/null || echo $$)",
  "title": "$feature_name",
  "sourceMarkdown": "$md_file",
  "sourceFilename": "$(basename "$md_file")",
  "branchName": "ralph/${feature_name}",
  "status": "pending",
  "createdAt": "$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')",
  "updatedAt": "$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')",
  "iterations": 0,
  "tasks": [],
  "completedTasks": [],
  "lastTool": "",
  "metadata": {}
}
EOF
  else
    # Update the source path in case it moved
    jq --arg md "$md_file" --arg fn "$(basename "$md_file")" '.sourceMarkdown = $md | .sourceFilename = $fn' "$prd_json" > "$prd_json.tmp" && mv "$prd_json.tmp" "$prd_json" 2>/dev/null || true
    status=$(jq -r '.status // "unknown"' "$prd_json" 2>/dev/null || echo "unknown")
    echo "  ✓ Found existing PRD state: ${safe_name}.json (status: $status)"
  fi
done

echo ""

# Determine which PRD to work on (first pending/in-progress, or most recently updated)
CURRENT_PRD_JSON=""

# Priority 1: Find in-progress PRD
for json_file in "$STATE_DIR"/*.json; do
  if [ -f "$json_file" ]; then
    status=$(jq -r '.status // "unknown"' "$json_file" 2>/dev/null || echo "unknown")
    if [ "$status" == "in-progress" ]; then
      CURRENT_PRD_JSON="$json_file"
      echo "Resuming in-progress PRD: $(basename "$json_file" .json)"
      break
    fi
  fi
done

# Priority 2: Find first pending PRD
if [ -z "$CURRENT_PRD_JSON" ]; then
  for json_file in "$STATE_DIR"/*.json; do
    if [ -f "$json_file" ]; then
      status=$(jq -r '.status // "unknown"' "$json_file" 2>/dev/null || echo "unknown")
      if [ "$status" == "pending" ]; then
        CURRENT_PRD_JSON="$json_file"
        echo "Starting new PRD: $(basename "$json_file" .json)"
        break
      fi
    fi
  done
fi

# Priority 3: Use the most recently updated non-completed one
if [ -z "$CURRENT_PRD_JSON" ]; then
  for json_file in $(ls -t "$STATE_DIR"/*.json 2>/dev/null); do
    if [ -f "$json_file" ]; then
      status=$(jq -r '.status // "unknown"' "$json_file" 2>/dev/null || echo "unknown")
      if [ "$status" != "completed" ]; then
        CURRENT_PRD_JSON="$json_file"
        echo "Resuming PRD: $(basename "$json_file" .json) (status: $status)"
        break
      fi
    fi
  done
fi

# If all completed or no PRDs exist, use the most recent one
if [ -z "$CURRENT_PRD_JSON" ]; then
  CURRENT_PRD_JSON=$(ls -t "$STATE_DIR"/*.json 2>/dev/null | head -n1)
  if [ -n "$CURRENT_PRD_JSON" ]; then
    echo "All PRDs completed. Reopening: $(basename "$CURRENT_PRD_JSON" .json)"
    # Reset status to allow reprocessing if needed
    jq '.status = "pending"' "$CURRENT_PRD_JSON" > "$CURRENT_PRD_JSON.tmp" && mv "$CURRENT_PRD_JSON.tmp" "$CURRENT_PRD_JSON"
  fi
fi

# If still no PRD found, exit with error
if [ -z "$CURRENT_PRD_JSON" ] || [ ! -f "$CURRENT_PRD_JSON" ]; then
  echo "Error: No PRD state files found. Please ensure PRD markdown files exist in $TASKS_DIR/"
  exit 1
fi

# Set up current PRD symlink for easy access
ln -sf "$CURRENT_PRD_JSON" "$STATE_DIR/current-prd.json" 2>/dev/null || true

# Track current PRD
CURRENT_PRD_INFO=$(get_current_prd_info "$CURRENT_PRD_JSON")
echo "$CURRENT_PRD_INFO" > "$LAST_PRD_FILE"
CURRENT_BRANCH=$(echo "$CURRENT_PRD_INFO" | cut -d'|' -f1)
CURRENT_TITLE=$(echo "$CURRENT_PRD_INFO" | cut -d'|' -f2)

# Create human-readable symlink to current active PRD
SAFE_CURRENT_NAME=$(generate_safe_filename "$CURRENT_TITLE")
ln -sf "$CURRENT_PRD_JSON" "$SCRIPT_DIR/current-prd.json" 2>/dev/null || true

# Also create a prd.json symlink for backwards compatibility with old tools
ln -sf "$CURRENT_PRD_JSON" "$SCRIPT_DIR/prd.json" 2>/dev/null || true

# Initialize progress file if it doesn't exist
if [ ! -f "$PROGRESS_FILE" ]; then
  echo "# Ralph Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
fi

# Add current PRD to progress log
echo "" >> "$PROGRESS_FILE"
echo "=== Working on: $CURRENT_TITLE (Branch: $CURRENT_BRANCH) ===" >> "$PROGRESS_FILE"
echo "PRD JSON: $(basename "$CURRENT_PRD_JSON")" >> "$PROGRESS_FILE"
echo "Source: $(jq -r '.sourceFilename // "unknown"' "$CURRENT_PRD_JSON")" >> "$PROGRESS_FILE"
echo "Started: $(date)" >> "$PROGRESS_FILE"

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                   Ralph Wiggum - AI Agent Loop                ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  Tool:           $TOOL"
echo "║  Max iterations: $MAX_ITERATIONS"
echo "║  Active PRD:     $CURRENT_TITLE"
echo "║  Branch:         $CURRENT_BRANCH"
echo "║  State file:     $(basename "$CURRENT_PRD_JSON")"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Update status to in-progress
jq '.status = "in-progress" | .updatedAt = "'$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')'"' "$CURRENT_PRD_JSON" > "$CURRENT_PRD_JSON.tmp" && mv "$CURRENT_PRD_JSON.tmp" "$CURRENT_PRD_JSON"

completed_prds=0
total_prds=$(ls -1 "$STATE_DIR"/*.json 2>/dev/null | wc -l)

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "==============================================================="
  echo "  Ralph Iteration $i of $MAX_ITERATIONS ($TOOL)"
  echo "  PRD: $CURRENT_TITLE ($completed_prds/$total_prds completed)"
  echo "==============================================================="

  # Prepare prompt based on current PRD
  PROMPT_FILE="$SCRIPT_DIR/prompt.md"
  if [[ "$TOOL" == "claude" || "$TOOL" == "opencode" ]]; then
    PROMPT_FILE="$SCRIPT_DIR/CLAUDE.md"
  fi
  
  # Get the source markdown file for this PRD
  SOURCE_MD=$(jq -r '.sourceMarkdown // ""' "$CURRENT_PRD_JSON")
  
  # Create enhanced temp prompt with PRD context
  TEMP_PROMPT=$(mktemp)
  {
    echo "# Ralph Agent Context"
    echo "Current PRD: $CURRENT_TITLE"
    echo "Branch: $CURRENT_BRANCH"
    echo "State File: $(basename "$CURRENT_PRD_JSON")"
    echo "Iteration: $i of $MAX_ITERATIONS"
    echo "Tool: $TOOL"
    echo ""
    echo "## Source PRD"
    if [ -n "$SOURCE_MD" ] && [ -f "$SOURCE_MD" ]; then
      cat "$SOURCE_MD"
    else
      echo "Warning: Source PRD file not found at $SOURCE_MD"
    fi
    echo ""
    echo "## Agent Instructions"
    cat "$PROMPT_FILE" 2>/dev/null || echo "No additional prompt file found at $PROMPT_FILE"
  } > "$TEMP_PROMPT"

  # Run the selected tool with the ralph prompt
  OUTPUT=""
  if [[ "$TOOL" == "amp" ]]; then
    echo "[Running: amp --dangerously-allow-all]"
    OUTPUT=$(cat "$TEMP_PROMPT" | amp --dangerously-allow-all 2>&1 | tee /dev/stderr) || true
  elif [[ "$TOOL" == "claude" ]]; then
    echo "[Running: claude --dangerously-skip-permissions --print]"
    OUTPUT=$(claude --dangerously-skip-permissions --print < "$TEMP_PROMPT" 2>&1 | tee /dev/stderr) || true
  elif [[ "$TOOL" == "opencode" ]]; then
    echo "[Running: opencode run --agent build --model ...]"
    OUTPUT=$(opencode run --agent build --model zai-coding-plan/glm-4.7 "$(cat "$TEMP_PROMPT")" 2>&1 | tee /dev/stderr) || true
  fi
  
  # Cleanup temp prompt
  rm -f "$TEMP_PROMPT"
  
  # Update iteration count and last tool used
  jq --arg tool "$TOOL" '.iterations += 1 | .lastTool = $tool | .updatedAt = "'$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')'"' "$CURRENT_PRD_JSON" > "$CURRENT_PRD_JSON.tmp" && mv "$CURRENT_PRD_JSON.tmp" "$CURRENT_PRD_JSON"
  
  # Save output snippet to progress log
  echo "" >> "$PROGRESS_FILE"
  echo "--- Iteration $i ($(date)) ---" >> "$PROGRESS_FILE"
  echo "$OUTPUT" | tail -n 20 >> "$PROGRESS_FILE" 2>/dev/null || true
  
  # Check for completion signal
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "✓ PRD completed: $CURRENT_TITLE"
    jq '.status = "completed" | .completedAt = "'$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')'"' "$CURRENT_PRD_JSON" > "$CURRENT_PRD_JSON.tmp" && mv "$CURRENT_PRD_JSON.tmp" "$CURRENT_PRD_JSON"
    
    echo "Completed at iteration $i of $MAX_ITERATIONS" | tee -a "$PROGRESS_FILE"
    
    # Check if there are more pending PRDs
    completed_prds=$((completed_prds + 1))
    NEXT_PRD=""
    for json_file in "$STATE_DIR"/*.json; do
      if [ -f "$json_file" ] && [ "$json_file" != "$CURRENT_PRD_JSON" ]; then
        status=$(jq -r '.status // "unknown"' "$json_file" 2>/dev/null || echo "unknown")
        if [[ "$status" == "pending" || "$status" == "in-progress" ]]; then
          NEXT_PRD="$json_file"
          break
        fi
      fi
    done
    
    if [ -n "$NEXT_PRD" ]; then
      echo ""
      echo ">>> Moving to next PRD..."
      CURRENT_PRD_JSON="$NEXT_PRD"
      CURRENT_PRD_INFO=$(get_current_prd_info "$CURRENT_PRD_JSON")
      CURRENT_BRANCH=$(echo "$CURRENT_PRD_INFO" | cut -d'|' -f1)
      CURRENT_TITLE=$(echo "$CURRENT_PRD_INFO" | cut -d'|' -f2)
      SAFE_CURRENT_NAME=$(generate_safe_filename "$CURRENT_TITLE")
      
      # Update symlinks
      ln -sf "$CURRENT_PRD_JSON" "$STATE_DIR/current-prd.json"
      ln -sf "$CURRENT_PRD_JSON" "$SCRIPT_DIR/current-prd.json"
      ln -sf "$CURRENT_PRD_JSON" "$SCRIPT_DIR/prd.json"
      
      echo "$CURRENT_PRD_INFO" > "$LAST_PRD_FILE"
      
      # Update progress log
      echo "" >> "$PROGRESS_FILE"
      echo "=== Working on: $CURRENT_TITLE (Branch: $CURRENT_BRANCH) ===" >> "$PROGRESS_FILE"
      echo "PRD JSON: $(basename "$CURRENT_PRD_JSON")" >> "$PROGRESS_FILE"
      echo "Started: $(date)" >> "$PROGRESS_FILE"
      
      # Update status to in-progress
      jq '.status = "in-progress" | .updatedAt = "'$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')'"' "$CURRENT_PRD_JSON" > "$CURRENT_PRD_JSON.tmp" && mv "$CURRENT_PRD_JSON.tmp" "$CURRENT_PRD_JSON"
      
      continue
    else
      echo ""
      echo "╔═══════════════════════════════════════════════════════════════╗"
      echo "║              🎉 Ralph completed all PRDs! 🎉                  ║"
      echo "╠═══════════════════════════════════════════════════════════════╣"
      echo "║  Total completed: $completed_prds"
      echo "╚═══════════════════════════════════════════════════════════════╝"
      exit 0
    fi
  fi
  
  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Current PRD: $CURRENT_TITLE ($(jq -r '.status' "$CURRENT_PRD_JSON"))"
echo "Check $PROGRESS_FILE for status."
echo "State files location: $STATE_DIR/"
echo ""
echo "To continue working on this PRD, run: ./ralph.sh --tool $TOOL"
exit 1