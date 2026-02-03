# PRD: Monitoring and Analytics Dashboard

## Introduction

The Monitoring and Analytics Dashboard (Phase 2) provides visibility into agent activity, tool usage statistics, failed permission attempts, and cost tracking. This enables administrators to understand how agents are being used, identify security issues, and optimize resource allocation. The dashboard complements the configuration management with operational insights.

## Goals

- Display tool usage statistics per agent
- Show failed permission attempts for security auditing
- Provide agent activity timeline
- Track API usage costs per agent
- Monitor agent health and performance
- Export analytics data for reporting
- Filter and drill down by agent, time range, or metric

## User Stories

### US-001: Tool usage statistics
**Description:** As an admin, I want to see tool usage statistics so I can understand which tools are most/least used.

**Acceptance Criteria:**
- [ ] Bar chart showing tool usage count per tool
- [ ] Filter by agent (all agents or specific agent)
- [ ] Time range selector: last hour, 24 hours, 7 days, 30 days
- [ ] Table showing detailed usage: tool name, count, last used timestamp
- [ ] Sortable columns (count, last used)
- [ ] Zero usage tools highlighted for potential cleanup
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-002: Failed permission attempts
**Description:** As a security auditor, I want to see failed permission attempts so I can identify potential security issues.

**Acceptance Criteria:**
- [ ] Table showing denied tool access attempts
- [ ] Columns: timestamp, agent, tool attempted, reason (disabled, not granted, etc.)
- [ ] Severity indicator (red for critical tools, yellow for others)
- [ ] Filter by agent, tool, or severity
- [ ] "Investigate" button opens agent configuration at relevant tool
- [ ] Export log as CSV
- [ ] Retention: 30 days
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-003: Agent activity timeline
**Description:** As an admin, I want to see an agent activity timeline so I can understand when and how agents are being used.

**Acceptance Criteria:**
- [ ] Timeline view with events over time
- [ ] Event types: session start/end, tool usage, skill activation, errors
- [ ] Filter by agent or event type
- [ ] Zoom in/out controls for time range
- [ ] Hover over events shows details
- [ ] Click on event jumps to relevant configuration
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-004: Cost tracking per agent
**Description:** As an admin, I want to track API costs per agent so I can budget and optimize resource usage.

**Acceptance Criteria:**
- [ ] Table showing cost per agent: agent name, total cost, cost by service (OpenAI, web search, etc.)
- [ ] Time range selector: daily, weekly, monthly, custom
- [ ] Pie chart showing cost breakdown by service
- [ ] Bar chart showing cost over time per agent
- [ ] Budget alerts: warning when approaching limit, error when exceeded
- [ ] Configure budget per agent in agent settings
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-005: Agent health monitoring
**Description:** As an admin, I want to monitor agent health so I can identify and troubleshoot issues.

**Acceptance Criteria:**
- [ ] Status dashboard showing all agents: healthy, degraded, unhealthy
- [ ] Health metrics: uptime, error rate, average response time
- [ ] Color-coded status: green (healthy), yellow (degraded), red (unhealthy)
- [ ] Error logs viewer with stack traces
- [ ] Auto-refresh every 30 seconds
- [ ] Click agent to view detailed health info
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-006: Export analytics data
**Description:** As an admin, I want to export analytics data so I can create custom reports or share with stakeholders.

**Acceptance Criteria:**
- [ ] "Export" button on each analytics view
- [ ] Export formats: CSV, JSON, PDF (for reports)
- [ ] Select date range and metrics to export
- [ ] Preview before export
- [ ] Email export option (optional)
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-007: Real-time activity feed
**Description:** As an admin, I want a real-time activity feed so I can see what agents are doing right now.

**Acceptance Criteria:**
- [ ] Live feed showing recent events (last 5 minutes)
- [ ] Auto-updates via WebSocket
- [ ] Events: tool usage, session start/end, errors
- [ ] Filter by agent or event type
- [ ] Pause/resume feed
- [ ] Click event to jump to details
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-008: Analytics dashboard overview
**Description:** As an admin, I want an overview dashboard showing key metrics so I can quickly assess system health.

**Acceptance Criteria:**
- [ ] Summary cards at top: total active agents, tool usage today, cost this month, errors today
- [ ] Mini charts for quick trend visualization
- [ ] Clicking card drills into detailed view
- [ ] Time since last update shown
- [ ] Refresh button
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

## Functional Requirements

- FR-1: Collect and store tool usage events (tool name, agent, timestamp)
- FR-2: Collect failed permission attempts (agent, tool, reason, timestamp)
- FR-3: Collect agent activity events (session start/end, skill activation, errors)
- FR-4: Track API costs by agent and service
- FR-5: Monitor agent health metrics (uptime, error rate, response time)
- FR-6: Provide filtering by agent, time range, and metric type
- FR-7: Export data in multiple formats
- FR-8: Real-time updates via WebSocket

## Non-Goals

- No predictive analytics or machine learning
- No automated alerts beyond budget warnings (can be added later)
- No integration with external monitoring tools (Datadog, New Relic)
- No historical data beyond 90 days (configurable)

## Design Considerations

- Dashboard layout: Cards at top, charts below, tables at bottom
- Charts: Use Chart.js or Recharts for visualizations
- Color coding: Green for success/healthy, yellow for warnings, red for errors
- Real-time feed: Scrolling list with newest at top
- Activity timeline: Horizontal or vertical timeline based on space

## Technical Considerations

- Analytics data stored in ~/.openclaw/analytics/ or SQLite database
- Metrics collected via Gateway events
- WebSocket for real-time updates
- Aggregation queries for time-based stats
- Chart libraries: Chart.js or Recharts
- Export libraries: PapaParse (CSV), jsPDF (PDF)

## Success Metrics

- Dashboard loads under 2 seconds
- Charts render under 500ms
- Real-time feed updates within 1 second of event
- Export completes within 5 seconds for 10,000 records

## Open Questions

- How much historical data should we retain by default?
- Should we support custom dashboards or widgets?
- Should we integrate with external monitoring tools?
