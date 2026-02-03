# PRD: Tool Access Control System

## Introduction

The Tool Access Control System is the core feature of the OpenClaw Admin Panel. It enables granular permission management for each agent's tool access through a comprehensive interface with toggle controls, quick presets, and category organization. This implements the principle of least privilege by ensuring agents only have access to tools explicitly granted to them.

## Goals

- Display all available tools organized by category with enabled/disabled states
- Provide one-click preset templates (Potato, Coding, Messaging, Full) for quick configuration
- Enable precise tool-level permission control via toggle switches
- Show dynamic tool count (e.g., "17/24 tools enabled")
- Support hot-reload of tool permissions without Gateway restart
- Warn before enabling dangerous tools (exec, write, etc.)
- Prevent disabling session_status (required for basic function)

## User Stories

### US-001: Display tool categories and tools
**Description:** As an admin, I want to see all available tools organized by category so I can understand an agent's capabilities.

**Acceptance Criteria:**
- [ ] Tools displayed in expandable categories: Fs, Runtime, Web, Memory, Sessions, UI, Messaging
- [ ] Each tool shows name, description, and toggle switch
- [ ] Enabled tools show toggle in ON state (colored)
- [ ] Disabled tools show toggle in OFF state (gray)
- [ ] Tool count displayed: "X/Y tools enabled" at top
- [ ] Categories show count (e.g., "Fs - 2/4")
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-002: Toggle tool permissions
**Description:** As an admin, I want to enable/disable individual tools so I can precisely control agent capabilities.

**Acceptance Criteria:**
- [ ] Toggle switch controls individual tool access
- [ ] Enabling tool adds to tools.enabled array, removes from tools.disabled
- [ ] Disabling tool removes from tools.enabled, adds to tools.disabled
- [ ] Changes reflect in tool count immediately
- [ ] session_status cannot be disabled (toggle disabled or always-on)
- [ ] Changes auto-saved to agent YAML config
- [ ] Hot-reload triggered for active agents (no restart needed)
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-003: Apply quick presets
**Description:** As an admin, I want to apply one-click presets so I can quickly configure agents for common use cases.

**Acceptance Criteria:**
- [ ] Four preset buttons: Potato, Coding, Messaging, Full
- [ ] Potato preset enables only session_status
- [ ] Coding preset enables: read, write, edit, exec, sessions, memory tools
- [ ] Messaging preset enables: message, tts, session_status
- [ ] Full preset enables all available tools
- [ ] Full preset shows warning: "Are you sure? This grants full access"
- [ ] Applying preset updates all tool toggles immediately
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-004: Warn before dangerous tools
**Description:** As an admin, I want warnings before enabling dangerous tools so I can make informed security decisions.

**Acceptance Criteria:**
- [ ] Warning dialog when enabling: exec, write, edit, apply_patch
- [ ] Dialog shows: "Enable [tool name]? This tool can modify files and execute commands"
- [ ] Dialog has "Cancel" and "Enable Anyway" buttons
- [ ] Warning persists per session (can be dismissed)
- [ ] exec has strongest warning (red alert)
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-005: Expand/collapse tool categories
**Description:** As an admin, I want to expand/collapse categories so I can focus on relevant tools.

**Acceptance Criteria:**
- [ ] Clicking category header toggles expand/collapse
- [ ] Expanded state shows all tools in category
- [ ] Collapsed state shows only category name and count
- [ ] State persists for each category during session
- [ ] Smooth animation (200ms) for expand/collapse
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-006: Search/filter tools
**Description:** As an admin, I want to search for tools by name so I can quickly find specific permissions.

**Acceptance Criteria:**
- [ ] Search input field at top of Tools tab
- [ ] Real-time filtering as user types
- [ ] Matches tool names and descriptions
- [ ] Highlights matching text in results
- [ ] Shows "No tools found" when no matches
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-007: Bulk enable/disable by category
**Description:** As an admin, I want to enable/disable all tools in a category at once for faster configuration.

**Acceptance Criteria:**
- [ ] "Enable All" button in each category header
- [ ] "Disable All" button in each category header
- [ ] Buttons only visible on category hover or via dropdown
- [ ] Enable All activates all toggles in category
- [ ] Disable All deactivates all toggles in category (except session_status)
- [ ] Confirmation dialog for Disable All: "Disable all tools in [category]?"
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

## Functional Requirements

- FR-1: Read and display tool permissions from agent YAML config (tools.enabled and tools.disabled arrays)
- FR-2: Toggle switches enable/disable individual tool access
- FR-3: Tool count calculated dynamically from tools.enabled array length
- FR-4: Presets map to predefined tool lists
- FR-5: session_status always enabled (cannot be toggled off)
- FR-6: Changes saved to agent config immediately after toggle
- FR-7: Hot-reload triggered via Gateway API or config watcher
- FR-8: Dangerous tools show confirmation before enabling
- FR-9: Categories defined: Fs (read, write, edit, apply_patch), Runtime (exec, process), Web (web_search, web_fetch), Memory (memory_search, memory_get), Sessions (sessions_list, sessions_history, sessions_send, sessions_spawn, session_status, agents_list), UI (browser, canvas), Messaging (message, tts)
- FR-10: Tool registry validated against OpenClaw Gateway's actual tool list

## Non-Goals

- No custom tool creation or registration (tools are fixed)
- No conditional tool permissions (time-based, rate-limited)
- No tool dependency management (tools are independent)
- No tool usage analytics in this version
- No tool testing or simulation within admin panel

## Design Considerations

- Tool cards: Card background #1a1a1a, hover #2a2a2a
- Toggle switch: Blue (#3b82f6) when ON, Gray when OFF
- Category headers: Bold text with expand/collapse chevron
- Tool descriptions: Small gray text below tool name
- Warning dialogs: Modal with red border for dangerous actions
- Tool count badge: Large number at top, e.g., "17/24"
- Smooth transitions: 150ms for toggles, 200ms for expand/collapse

## Technical Considerations

- Tool permissions stored in agent YAML: tools.enabled and tools.disabled arrays
- Validate tool names against Gateway's tool registry
- Debounce rapid toggles (300ms) to reduce config writes
- WebSocket connection to Gateway for hot-reload signal
- Fallback: force reload if hot-reload fails
- Tool categories defined in admin panel config (extensible)
- Cache tool list from Gateway on startup

## Success Metrics

- Tool list renders with 50+ tools under 200ms
- Toggle operation completes under 100ms
- Preset application completes under 500ms
- Zero Gateway restarts needed for tool changes
- Admins can configure agents with average 10 tools under 30 seconds

## Open Questions

- Should we support custom presets saved by users?
- How should we handle tools that exist in Gateway but not in our predefined list?
- Should we show tool usage logs or last-used timestamps?
