# PRD: OpenClaw Gateway Integration

## Introduction

The OpenClaw Gateway Integration enables the admin panel to communicate with the OpenClaw Gateway system, reading current agent configurations, validating tool names against the tool registry, applying configuration changes, and subscribing to agent events. This integration is the bridge between the admin UI and the underlying OpenClaw system, ensuring that all changes are properly synchronized and hot-reloaded.

## Goals

- Read current agent configurations from Gateway or config files
- Validate tool names against Gateway's tool registry
- Apply configuration changes via Gateway API or config file hot-reload
- Subscribe to agent events (heartbeats, errors) for real-time updates
- Maintain bidirectional sync between admin panel and Gateway
- Handle connection failures gracefully with recovery
- Support both file-based and API-based configuration methods

## User Stories

### US-001: Load agent configurations on startup
**Description:** As the admin panel, I want to load all agent configurations from Gateway so the UI shows the current state.

**Acceptance Criteria:**
- [ ] Read agent configs from ~/.openclaw/agents/*.yaml
- [ ] Parse YAML and validate structure
- [ ] Populate agent list in sidebar
- [ ] Load tool registry from Gateway API
- [ ] Display error message if config directory not found
- [ ] Loading spinner shown during startup
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-002: Validate tool names against registry
**Description:** As the admin panel, I want to validate that tool names match the Gateway's registry so invalid tools are rejected.

**Acceptance Criteria:**
- [ ] Fetch tool registry from Gateway API on startup
- [ ] Cache tool list locally for offline use
- [ ] Validate tool names when adding to tools.enabled or tools.disabled
- [ ] Show error if tool name not found in registry
- [ ] Graceful handling if Gateway API unavailable
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-003: Apply configuration changes via Gateway API
**Description:** As the admin panel, I want to apply changes via Gateway API so configurations are updated immediately.

**Acceptance Criteria:**
- [ ] POST updated agent config to Gateway API endpoint
- [ ] API validates config before applying
- [ ] Success response triggers hot-reload signal
- [ ] Error response shows validation failure details
- [ ] Retry logic for transient failures (max 3 attempts)
- [ ] Fallback to file-based write if API fails
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-004: Hot-reload agent configurations
**Description:** As the admin panel, I want to trigger hot-reload so agents pick up configuration changes without restart.

**Acceptance Criteria:**
- [ ] Send hot-reload signal to Gateway WebSocket
- [ ] Gateway acknowledges receipt of hot-reload
- [ ] UI shows success message: "Configuration reloaded"
- [ ] Agent heartbeat verifies config change applied
- [ ] Timeout after 10 seconds with error if no acknowledgment
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-005: Subscribe to agent events
**Description:** As the admin panel, I want to subscribe to Gateway events so I see real-time agent status updates.

**Acceptance Criteria:**
- [ ] WebSocket connection to Gateway event stream
- [ ] Receive heartbeat events (agent alive status)
- [ ] Receive error events (agent failures)
- [ ] Receive config change events (external modifications)
- [ ] Update UI in real-time based on events
- [ ] Reconnect automatically on disconnect
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-006: Handle connection failures
**Description:** As the admin panel, I want to handle Gateway connection failures gracefully so the UI remains usable.

**Acceptance Criteria:**
- [ ] Show "Disconnected" status badge when Gateway unreachable
- [ ] Queue changes locally if Gateway offline
- [ ] Apply queued changes when connection restored
- [ ] Reconnection attempt every 5 seconds
- [ ] Max reconnection attempts: 10
- [ ] Manual "Reconnect" button available
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-007: File-based configuration fallback
**Description:** As the admin panel, I want to write configs directly to files if Gateway API unavailable so changes aren't lost.

**Acceptance Criteria:**
- [ ] Detect if Gateway API is unresponsive
- [ ] Switch to file-based writes to ~/.openclaw/agents/
- [ ] Notify user: "Saved to file (Gateway unavailable)"
- [ ] Continue monitoring for Gateway availability
- [ ] Switch back to API when Gateway returns
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-008: Watch for external configuration changes
**Description:** As the admin panel, I want to detect external config changes so I can sync with Gateway state.

**Acceptance Criteria:**
- [ ] File watcher monitors ~/.openclaw/agents/*.yaml
- [ ] Debounce file change events (500ms)
- [ ] Reload changed agent config from file
- [ ] Update UI to reflect changes
- [ ] Show notification: "Configuration updated externally"
- [ ] Handle merge conflicts (user changes + external changes)
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-009: Restart Gateway
**Description:** As an admin, I want to restart the Gateway so configuration changes take effect if hot-reload fails.

**Acceptance Criteria:**
- [ ] "Restart Gateway" button in top bar
- [ ] Confirmation dialog: "Restart Gateway? This will interrupt all active agents"
- [ ] Send restart command to Gateway API
- [ ] Show progress indicator during restart
- [ ] Update status badge to "Disconnected" during restart
- [ ] Reconnect automatically when Gateway back online
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-010: Read Gateway metadata
**Description:** As the admin panel, I want to read Gateway metadata so I can display system information.

**Acceptance Criteria:**
- [ ] Fetch Gateway version from API
- [ ] Display version in footer or about section
- [ ] Fetch supported tool categories and counts
- [ ] Fetch active session count
- [ ] Cache metadata for 60 seconds
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

## Functional Requirements

- FR-1: Load agent configurations from ~/.openclaw/agents/*.yaml
- FR-2: Validate tool names against Gateway's tool registry
- FR-3: Apply config changes via Gateway API or file write
- FR-4: Trigger hot-reload via Gateway WebSocket
- FR-5: Subscribe to Gateway events (heartbeats, errors, config changes)
- FR-6: Graceful handling of connection failures
- FR-7: File-based fallback when API unavailable
- FR-8: Watch for external config changes
- FR-9: Restart Gateway on demand
- FR-10: Read and display Gateway metadata

## Non-Goals

- No direct agent control (start/stop agents is handled by Gateway)
- No agent session management
- No agent performance monitoring
- No direct communication with agents (only via Gateway)

## Design Considerations

- WebSocket connection for real-time events
- Status badge showing connection health
- Retry logic with exponential backoff
- Offline mode with queuing
- File watcher for external changes
- Fallback mechanisms for API failures

## Technical Considerations

- WebSocket endpoint: ws://localhost:18789/ws/events
- REST API endpoint: http://localhost:18789/api/v1/*
- Tool registry endpoint: GET /api/v1/tools
- Agent config endpoint: GET/POST /api/v1/agents/:name
- Hot-reload endpoint: POST /api/v1/reload
- Restart endpoint: POST /api/v1/restart
- Use axios or fetch for HTTP requests
- Use native WebSocket or ws client
- Chokidar or fs.watch for file changes

## Success Metrics

- Initial load completes under 2 seconds
- Configuration changes apply under 1 second
- Hot-reload acknowledgment under 500ms
- WebSocket reconnects within 5 seconds
- Zero data loss during Gateway outages

## Open Questions

- Should we support multiple Gateway instances?
- How should we handle version mismatches between admin panel and Gateway?
- Should we cache tool registry offline for extended periods?
