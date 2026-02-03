# PRD: Skills Management System

## Introduction

The Skills Management System enables admins to install, configure, and manage skills for individual agents. Skills are specialized capabilities (like accounting, scheduling, or data analysis) that extend an agent's functionality beyond basic tools. The system provides a browsable skill list, installation from ClawHub (the skill repository), and per-agent enable/disable controls.

## Goals

- Display all installed skills with descriptions
- Enable/disable skills on a per-agent basis
- Install new skills from ClawHub repository
- Upload custom local skill files
- Update existing skills to latest versions
- Remove unused or unwanted skills
- View skill documentation and requirements
- Show skill count per agent

## User Stories

### US-001: Display installed skills list
**Description:** As an admin, I want to see all installed skills with descriptions so I can understand what capabilities are available.

**Acceptance Criteria:**
- [ ] Skills tab shows list of all installed skills
- [ ] Each skill card displays: name, description, version, status (enabled/disabled)
- [ ] Skills sorted alphabetically by name
- [ ] Search/filter input to find skills quickly
- [ ] Empty state message when no skills installed
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-002: Enable/disable skills per agent
**Description:** As an admin, I want to enable or disable skills for specific agents so each agent has only the capabilities it needs.

**Acceptance Criteria:**
- [ ] Toggle switch next to each skill in agent configuration
- [ ] Enabling skill adds to agent's skills.enabled array
- [ ] Disabling skill removes from agent's skills.enabled array
- [ ] Changes reflected immediately in UI
- [ ] Auto-saved to agent YAML config
- [ ] Hot-reload triggered for active agent
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-003: Install skills from ClawHub
**Description:** As an admin, I want to browse and install skills from ClawHub so I can add new capabilities without manual setup.

**Acceptance Criteria:**
- [ ] "Install from ClawHub" button opens skill browser modal
- [ ] Modal shows searchable list of available skills from repository
- [ ] Each skill shows name, description, author, download count, rating
- [ ] Clicking skill shows details view with documentation
- [ ] "Install" button downloads and installs skill
- [ ] Installation progress indicator shown
- [ ] Success message: "[Skill name] installed successfully"
- [ ] Installed skill appears in skills list
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-004: Upload custom local skills
**Description:** As an admin, I want to upload custom skill files so I can use locally developed or private skills.

**Acceptance Criteria:**
- [ ] "Upload Custom Skill" button opens file picker
- [ ] Accepts .zip, .tar.gz, or directory selection
- [ ] Validates skill structure (must contain skill.yaml)
- [ ] Extracts and installs to skills directory
- [ ] Shows progress indicator during extraction
- [ ] Success message on completion
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-005: Update installed skills
**Description:** As an admin, I want to update skills to latest versions so I get bug fixes and new features.

**Acceptance Criteria:**
- [ ] Skills show "Update available" badge when newer version exists
- [ ] "Update All" button in header to update all outdated skills
- [ ] Individual "Update" button per skill
- [ ] Update confirmation dialog: "Update [skill name] from v1.0 to v1.2?"
- [ ] Download and installation progress shown
- [ ] Success message on completion
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-006: Remove skills
**Description:** As an admin, I want to remove unused skills so I can clean up the system.

**Acceptance Criteria:**
- [ ] "Remove" button next to each skill (red warning color)
- [ ] Confirmation dialog: "Remove [skill name]? This cannot be undone"
- [ ] Warning if skill is enabled for any agent
- [ ] Shows list of affected agents
- [ ] Remove button disabled if skill is system-critical
- [ ] Skill directory removed after confirmation
- [ ] UI updates to remove skill from list
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-007: View skill documentation
**Description:** As an admin, I want to view skill documentation so I can understand how to use it properly.

**Acceptance Criteria:**
- [ ] Clicking skill name or "View Docs" button opens documentation modal
- [ ] Shows skill.yaml content (parsed for readability)
- [ ] Displays description, author, version, requirements
- [ ] Shows dependencies (other skills or tools required)
- [ ] Shows configuration options if applicable
- [ ] Link to external docs if provided
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-008: Browse local skill folders
**Description:** As an admin, I want to browse the local skills directory so I can manage files manually if needed.

**Acceptance Criteria:**
- [ ] "Browse Skills Folder" button opens file explorer
- [ ] Opens ~/.openclaw/skills/ directory
- [ ] Cross-platform support (Windows/macOS/Linux)
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-009: Show skill count per agent
**Description:** As an admin, I want to see how many skills are enabled for each agent so I can quickly assess configuration.

**Acceptance Criteria:**
- [ ] Agent sidebar shows skill count badge (e.g., "5 skills")
- [ ] Count updates when skills are enabled/disabled
- [ ] Zero state shows "0 skills" (gray)
- [ ] Non-zero state shows accent color
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

## Functional Requirements

- FR-1: Read skills from ~/.openclaw/skills/ directory
- FR-2: Each skill must contain skill.yaml with metadata
- FR-3: Agent's skills.enabled array stores enabled skills
- FR-4: Install from ClawHub downloads skill tarball to skills directory
- FR-5: Upload validates skill structure before extraction
- FR-6: Update checks remote version vs installed version
- FR-7: Remove deletes skill directory
- FR-8: Skill documentation read from skill.yaml
- FR-9: Changes to agent skills auto-save and trigger hot-reload

## Non-Goals

- No skill creation or editing within admin panel
- No skill dependencies auto-installation (manual)
- No skill version rollback (only forward updates)
- No skill marketplace or paid skills
- No skill testing/simulation interface

## Design Considerations

- Skill cards: Card background #1a1a1a, border #2a2a2a
- Enabled skills: Blue accent #3b82f6
- Disabled skills: Grayed out
- Update badge: Small orange/yellow pill
- Remove button: Red color (#ef4444) with warning icon
- Search: Input field with magnifying glass icon
- Modal: Full-screen or large dialog for documentation

## Technical Considerations

- Skills stored in ~/.openclaw/skills/[skill-name]/
- skill.yaml structure: name, description, version, author, requirements, dependencies
- ClawHub API endpoint for skill repository
- Download progress tracked via WebSocket or polling
- Validate skill structure: must have skill.yaml, main.js/ts, or equivalent entry point
- Watch skills directory for external changes
- Cache ClawHub skill list to reduce API calls

## Success Metrics

- Skills list loads under 200ms with 50+ skills
- Skill installation completes under 5 seconds for typical skills
- Search filters results in under 100ms
- Zero broken skills after install/update/remove operations

## Open Questions

- Should we show skill usage statistics?
- How should we handle skill conflicts (two skills requiring same resource)?
- Should we support skill dependencies with auto-installation?
