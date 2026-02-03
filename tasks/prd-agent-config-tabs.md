# PRD: Agent Configuration Tabs System

## Introduction

The Agent Configuration Tabs System provides the navigation structure for managing different aspects of an agent's identity and capabilities. The tabs (Soul, User, Agents, Memory, Tools, Skills) organize configuration into logical sections, allowing admins to efficiently navigate between personality settings, user context, inter-agent permissions, memory scope, tool access, and skill management.

## Goals

- Provide clear tab navigation for all agent configuration aspects
- Enable seamless switching between configuration sections
- Maintain tab state and unsaved changes
- Show active tab with visual indicator
- Display tab-specific content with appropriate controls
- Support tab reordering or customization (optional)

## User Stories

### US-001: Display tab navigation
**Description:** As an admin, I want to see all configuration tabs so I can navigate to different agent settings.

**Acceptance Criteria:**
- [ ] Tab bar displayed below top header, spanning full width of main content area
- [ ] Six tabs: Soul, User, Agents, Memory, Tools, Skills
- [ ] Each tab shows icon and label
- [ ] Active tab highlighted with blue accent (#3b82f6) and bottom border
- [ ] Inactive tabs show gray color (#6b7280)
- [ ] Hover effect on inactive tabs (slightly brighter)
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-002: Navigate between tabs
**Description:** As an admin, I want to click tabs to switch between configuration sections so I can manage different aspects of the agent.

**Acceptance Criteria:**
- [ ] Clicking tab switches content immediately
- [ ] Active tab updates to clicked tab
- [ ] Content area updates with tab-specific controls
- [ ] Smooth transition animation (150ms fade)
- [ ] URL updates to reflect active tab (e.g., /agents/saul-goodman?tab=tools)
- [ ] Browser back/forward navigation works with tabs
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-003: Soul tab content
**Description:** As an admin, I want to configure agent personality and identity in the Soul tab so the agent has appropriate behavior and tone.

**Acceptance Criteria:**
- [ ] Name field: Text input for agent name
- [ ] Description field: Textarea for agent personality and behavioral instructions
- [ ] System prompt field: Textarea for system-level instructions
- [ ] Save button (auto-save also enabled)
- [ ] Character limit indicators (e.g., "500/1000 characters")
- [ ] Changes auto-saved to agent YAML
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-004: User tab content
**Description:** As an admin, I want to configure which user context/profile the agent can access so the agent has appropriate information about the user.

**Acceptance Criteria:**
- [ ] User context file selector
- [ ] List of available user profiles from ~/.openclaw/users/
- [ ] Checkbox to enable/disable user context access
- [ ] Scope selector: All files, Specific files, No access
- [ ] Specific files list with checkboxes
- [ ] Changes auto-saved to agent YAML
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-005: Agents tab content
**Description:** As an admin, I want to configure which other agents this agent can communicate with so I can control inter-agent interactions.

**Acceptance Criteria:**
- [ ] List of all other agents
- [ ] Toggle switch per agent: Can communicate / Cannot communicate
- [ ] "Select All" and "Deselect All" buttons
- [ ] Search/filter input for agents list
- [ ] Visual grouping: Allowed agents, Blocked agents
- [ ] Changes auto-saved to agent YAML
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-006: Memory tab content
**Description:** As an admin, I want to configure which memory files the agent can access so I can control what information the agent knows.

**Acceptance Criteria:**
- [ ] Memory scope list with checkboxes
- [ ] Default files: IDENTITY.md, USER.md, MEMORY.md
- [ ] Additional memory files from ~/.openclaw/memory/
- [ ] Deny list for restricted files
- [ ] File browser to add custom memory files
- [ ] Preview pane showing file contents when clicked
- [ ] Changes auto-saved to agent YAML
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-007: Tools tab content
**Description:** As an admin, I want to configure tool permissions in the Tools tab so I can control which tools the agent can use.

**Acceptance Criteria:**
- [ ] Tool count display: "X/Y tools enabled"
- [ ] Quick preset buttons: Potato, Coding, Messaging, Full
- [ ] Expandable tool categories (Fs, Runtime, Web, Memory, Sessions, UI, Messaging)
- [ ] Toggle switches per tool
- [ ] Search/filter input for tools
- [ ] Warning dialogs for dangerous tools
- [ ] Changes auto-saved and hot-reloaded
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-008: Skills tab content
**Description:** As an admin, I want to manage skills in the Skills tab so I can install and configure agent capabilities.

**Acceptance Criteria:**
- [ ] List of all installed skills
- [ ] Toggle switch per skill for this agent
- [ ] "Install from ClawHub" button
- [ ] "Upload Custom Skill" button
- [ ] "Update All" button
- [ ] Search/filter input for skills
- [ ] Skill documentation view
- [ ] Changes auto-saved and hot-reloaded
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-009: Maintain unsaved changes
**Description:** As an admin, I want to see if I have unsaved changes when switching tabs so I don't lose configuration.

**Acceptance Criteria:**
- [ ] Visual indicator (dot) on tabs with unsaved changes
- [ ] Warning dialog when switching tabs with unsaved changes: "You have unsaved changes. Leave anyway?"
- [ ] "Stay" and "Leave" options
- [ ] Auto-save option reduces warnings (enabled by default)
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-010: Persist tab selection
**Description:** As an admin, I want my last-used tab to be remembered when I return to an agent so I can resume work quickly.

**Acceptance Criteria:**
- [ ] Last active tab saved to localStorage per agent
- [ ] When selecting agent, previously active tab opens by default
- [ ] Tabs persist across browser sessions
- [ ] Default tab is Tools if no prior selection
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

## Functional Requirements

- FR-1: Tab navigation bar displayed with six tabs
- FR-2: Tabs correspond to agent configuration sections
- FR-3: Clicking tab switches content area to corresponding section
- FR-4: Active tab visually highlighted
- FR-5: URL query param tracks active tab
- FR-6: Each tab has specific form controls and inputs
- FR-7: Changes auto-saved to agent YAML (300ms debounce)
- FR-8: Unsaved changes tracked per tab
- FR-9: Tab selection persisted in localStorage

## Non-Goals

- No nested tabs or sub-tabs
- No tab reordering in this version
- No keyboard shortcuts for tab navigation (can be added later)
- No tab pinning or favorites

## Design Considerations

- Tab bar height: 48px fixed
- Tab background: #1a1a1a
- Active tab: #3b82f6 accent color with 2px bottom border
- Tab icons: Emoji or SVG icons (🧑 Soul, 👤 User, 🤝 Agents, 🧠 Memory, 🛠️ Tools, 📦 Skills)
- Tab text: Medium weight, 14px
- Content area: Full remaining height with scrolling
- Smooth transitions: 150ms fade for tab switches

## Technical Considerations

- Tab state managed in component state
- URL query param: ?tab=tools
- localStorage key: last-tab-[agent-id]
- Debounce auto-save to 300ms to avoid excessive writes
- Validation before saving (required fields, valid formats)
- Error handling for failed saves

## Success Metrics

- Tab switch completes under 100ms
- No lost data when switching between tabs
- Auto-save triggers correctly after 300ms of inactivity
- Zero console errors during tab navigation

## Open Questions

- Should we support custom tabs or plugins?
- Should we show configuration validation status per tab?
- Should tabs support keyboard shortcuts (1-6 keys)?
