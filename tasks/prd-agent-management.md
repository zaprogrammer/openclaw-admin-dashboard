# PRD: Agent Management System

## Introduction

The Agent Management System provides the primary interface for managing OpenClaw AI agents. It displays a scrollable list of all configured agents in a left sidebar and enables core operations like creating, deleting, duplicating, and renaming agents. This is the entry point for all agent configuration workflows.

## Goals

- Display all configured agents with their skill counts in a scrollable sidebar
- Enable quick creation of new agents
- Allow deleting agents with confirmation
- Support cloning existing agents (including all permissions)
- Provide rename functionality for agent identification
- Maintain visual selection state for the currently active agent
- Support 10+ agents without UI degradation

## User Stories

### US-001: Display agent list in sidebar
**Description:** As an admin, I want to see all configured agents in the sidebar so I can navigate between them.

**Acceptance Criteria:**
- [ ] Sidebar displays agent name with icon/avatar
- [ ] Each agent shows skill count badge (e.g., "0 skills", "5 skills")
- [ ] List is scrollable when 5+ agents exist
- [ ] Active agent is highlighted with accent color (#3b82f6)
- [ ] Agent list sorted alphabetically by default
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-002: Create new agent
**Description:** As an admin, I want to create a new agent so I can set up a specialized AI assistant.

**Acceptance Criteria:**
- [ ] "New Agent" button in sidebar header
- [ ] Opens modal/dialog with name input field
- [ ] Agent name required and validated (no duplicates)
- [ ] Default configuration applied (Potato preset, no skills)
- [ ] New agent appears in list immediately
- [ ] New agent becomes active/selected after creation
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-003: Delete agent
**Description:** As an admin, I want to delete an agent I no longer need to clean up the system.

**Acceptance Criteria:**
- [ ] Delete option accessible via context menu or agent options menu
- [ ] Confirmation dialog: "Are you sure you want to delete [agent name]?"
- [ ] Cannot delete if agent is currently running/active
- [ ] Agent config file removed from ~/.openclaw/agents/
- [ ] Sidebar updates immediately after deletion
- [ ] Next agent in list becomes selected
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-004: Duplicate agent
**Description:** As an admin, I want to clone an existing agent so I can quickly create similar agents with the same permissions.

**Acceptance Criteria:**
- [ ] Duplicate option accessible via context menu or agent options menu
- [ ] Prompts for new agent name
- [ ] Copies all configuration: name, description, skills, tools, memory scope
- [ ] New agent appears in list immediately
- [ ] Duplicated agent becomes active/selected
- [ ] Original agent remains unchanged
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-005: Rename agent
**Description:** As an admin, I want to rename an agent so I can update its identity as roles change.

**Acceptance Criteria:**
- [ ] Rename option accessible via context menu or agent options menu
- [ ] Opens modal with current name pre-filled
- [ ] Name required and validated (no duplicates with other agents)
- [ ] Updates both display name and config file name
- [ ] Sidebar updates immediately with new name
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-006: Show agent selection state
**Description:** As an admin, I want to see which agent is currently selected so I know which configuration I'm viewing.

**Acceptance Criteria:**
- [ ] Selected agent highlighted with blue accent (#3b82f6)
- [ ] Selection persists across tab changes
- [ ] Clicking agent updates selection state immediately
- [ ] Only one agent can be selected at a time
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

## Functional Requirements

- FR-1: Sidebar displays all agents from ~/.openclaw/agents/*.yaml
- FR-2: Each agent shows name, icon/avatar, and skill count badge
- FR-3: Agent list supports scrolling when height exceeds viewport
- FR-4: Selected agent visually highlighted with accent color
- FR-5: Create agent generates new YAML file in agents directory
- FR-6: Delete agent removes corresponding YAML file
- FR-7: Duplicate agent copies entire YAML config with new name
- FR-8: Rename agent updates YAML filename and name field
- FR-9: Agent names must be unique (case-sensitive)
- FR-10: Skill count calculated from tools.enabled + skills.enabled arrays

## Non-Goals

- No agent grouping or folder organization
- No drag-and-drop reordering in this version
- No bulk agent operations (handled separately)
- No agent search/filter (agents list is alphabetical)
- No agent archiving or soft-delete
- No agent permissions sharing between users

## Design Considerations

- Sidebar width: 250-300px fixed
- Dark theme colors: Background #0a0a0a, Cards #1a1a1a
- Active selection: #3b82f6 (blue) highlight
- Hover states: subtle brightness increase
- Agent icons: default robot/assistant icons, custom avatars optional
- Skill count badge: small circular or pill-shaped badge
- Smooth transitions for selection state (150ms)

## Technical Considerations

- Agent configs read from ~/.openclaw/agents/*.yaml on startup
- Watch for file changes to auto-update list
- Debounce rapid agent name changes
- Use UUID or timestamp-based temp names for creation until saved
- Validate YAML structure after write operations
- Error handling for invalid agent configs
- WebSocket integration for real-time updates when agents are added/removed externally

## Success Metrics

- Agent list renders in under 100ms with 50+ agents
- Create/delete/duplicate operations complete under 500ms
- No console errors when switching between agents
- Zero data loss during rename operations

## Open Questions

- Should agent list support custom sorting beyond alphabetical?
- Should we show agent status (running/stopped) in the list?
- How should we handle duplicate names if an external process creates them?
