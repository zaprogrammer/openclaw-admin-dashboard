# PRD: Testing Framework

## Introduction

The Testing Framework ensures the OpenClaw Admin Panel functions correctly through comprehensive unit tests, integration tests, and end-to-end tests. This framework validates core functionality including config parsing, permission checking, preset application, Gateway communication, and hot-reload behavior. Automated testing prevents regressions and ensures code quality.

## Goals

- Unit tests for config parser and validator
- Unit tests for permission checker logic
- Unit tests for preset application
- Integration tests for Gateway communication
- Integration tests for hot-reload verification
- Integration tests for tool enable/disable propagation
- E2E tests for agent creation, configuration, and verification
- E2E tests for preset application
- Test coverage of 80%+ for core code
- Continuous integration with automated test runs

## User Stories

### US-001: Config parser unit tests
**Description:** As a developer, I want unit tests for the config parser so I can ensure agent YAML files are read correctly.

**Acceptance Criteria:**
- [ ] Test parsing valid agent configs
- [ ] Test handling missing required fields
- [ ] Test invalid YAML syntax
- [ ] Test empty configs
- [ ] Test arrays (tools.enabled, tools.disabled, skills.enabled)
- [ ] Test nested objects (memory.scope)
- [ ] Mock file system for isolated testing
- [ ] Test coverage > 90% for parser code
- [ ] Tests run in under 100ms
- [ ] Typecheck passes

### US-002: Permission checker unit tests
**Description:** As a developer, I want unit tests for permission checking logic so I can ensure agents only have granted access.

**Acceptance Criteria:**
- [ ] Test tool access granted for tools in tools.enabled
- [ ] Test tool access denied for tools in tools.disabled
- [ ] Test tool access denied for unlisted tools
- [ ] Test required tools (session_status) always granted
- [ ] Test agent-to-agent communication permissions
- [ ] Test memory file access permissions
- [ ] Test skill enablement checks
- [ ] Test coverage > 90% for permission checker
- [ ] Tests run in under 100ms
- [ ] Typecheck passes

### US-003: Preset application unit tests
**Description:** As a developer, I want unit tests for preset application so presets apply the correct tool sets.

**Acceptance Criteria:**
- [ ] Test Potato preset enables only session_status
- [ ] Test Coding preset enables correct tools
- [ ] Test Messaging preset enables correct tools
- [ ] Test Full preset enables all tools
- [ ] Test preset overwrites existing config
- [ ] Test preset preserves unlisted tools in tools.disabled
- [ ] Test coverage > 90% for preset logic
- [ ] Tests run in under 100ms
- [ ] Typecheck passes

### US-004: Gateway communication integration tests
**Description:** As a developer, I want integration tests for Gateway communication so the admin panel interacts correctly with Gateway.

**Acceptance Criteria:**
- [ ] Test reading agent configs from Gateway API
- [ ] Test writing agent configs to Gateway API
- [ ] Test fetching tool registry from Gateway
- [ ] Test hot-reload signal to Gateway
- [ ] Test WebSocket event subscription
- [ ] Test error handling for Gateway failures
- [ ] Mock Gateway server for isolated testing
- [ ] Tests run in under 5 seconds
- [ ] Typecheck passes

### US-005: Hot-reload integration tests
**Description:** As a developer, I want integration tests for hot-reload so config changes apply without Gateway restart.

**Acceptance Criteria:**
- [ ] Test hot-reload signal sent after config change
- [ ] Test Gateway acknowledges hot-reload
- [ ] Test agent picks up config change after hot-reload
- [ ] Test timeout handling if no acknowledgment
- [ ] Test retry logic for failed hot-reload
- [ ] Mock Gateway for isolated testing
- [ ] Tests run in under 2 seconds
- [ ] Typecheck passes

### US-006: Tool enable/disable propagation tests
**Description:** As a developer, I want integration tests for tool enable/disable so changes propagate correctly.

**Acceptance Criteria:**
- [ ] Test enabling tool updates config and sends hot-reload
- [ ] Test disabling tool updates config and sends hot-reload
- [ ] Test bulk enable/disable operations
- [ ] Test preset application triggers hot-reload
- [ ] Test config file watcher detects changes
- [ ] Mock Gateway for isolated testing
- [ ] Tests run in under 2 seconds
- [ ] Typecheck passes

### US-007: E2E test: Create and configure agent
**Description:** As a developer, I want E2E tests for agent creation so the full workflow works correctly.

**Acceptance Criteria:**
- [ ] Test create new agent from UI
- [ ] Test agent appears in sidebar
- [ ] Test configure tools via toggle switches
- [ ] Test apply preset
- [ ] Test enable/disable skills
- [ ] Test save and verify config file updated
- [ ] Test hot-reload triggered
- [ ] Use Playwright or Cypress for E2E testing
- [ ] Tests run in under 10 seconds
- [ ] Typecheck passes

### US-008: E2E test: Apply preset and verify
**Description:** As a developer, I want E2E tests for preset application so presets work end-to-end.

**Acceptance Criteria:**
- [ ] Test create agent with minimal config
- [ ] Test apply Coding preset
- [ ] Test verify tools match Coding preset
- [ ] Test verify in OpenClaw session (mock)
- [ ] Test revert to Potato preset
- [ ] Test verify tools match Potato preset
- [ ] Use Playwright or Cypress for E2E testing
- [ ] Tests run in under 10 seconds
- [ ] Typecheck passes

### US-009: E2E test: Multi-agent operations
**Description:** As a developer, I want E2E tests for multi-agent operations so bulk actions work correctly.

**Acceptance Criteria:**
- [ ] Test create 5 agents
- [ ] Test select all agents
- [ ] Test apply preset to all agents
- [ ] Test verify all agents updated
- [ ] Test export all agents
- [ ] Test delete selected agents
- [ ] Use Playwright or Cypress for E2E testing
- [ ] Tests run in under 15 seconds
- [ ] Typecheck passes

### US-010: Test coverage reporting
**Description:** As a developer, I want test coverage reports so I can identify untested code.

**Acceptance Criteria:**
- [ ] Coverage threshold: 80% for core code
- [ ] Coverage report generated after test run
- [ ] HTML report with clickable file links
- [ ] Uncovered lines highlighted in report
- [ ] CI pipeline fails if coverage below threshold
- [ ] Coverage badge in README
- [ ] Typecheck passes

## Functional Requirements

- FR-1: Unit tests for all core functions (parser, validator, checker)
- FR-2: Integration tests for Gateway communication and hot-reload
- FR-3: E2E tests for key user workflows
- FR-4: Test coverage of 80%+ for production code
- FR-5: Tests run on every pull request
- FR-6: Tests run on main branch commits
- FR-7: Tests complete in under 1 minute for full suite

## Non-Goals

- No performance tests in this version (can be added later)
- No load tests or stress tests
- No security penetration tests

## Technical Considerations

- Test framework: Jest or Vitest for unit/integration tests
- E2E framework: Playwright or Cypress
- Mocking: Sinon or built-in Jest mocks
- Coverage tool: c8 or Istanbul
- CI integration: GitHub Actions or GitLab CI
- Test data: Fixtures in tests/fixtures/ directory

## Success Metrics

- Unit test suite passes in under 30 seconds
- Integration test suite passes in under 30 seconds
- E2E test suite passes in under 1 minute
- Overall coverage > 80%
- Zero flaky tests (must be deterministic)

## Open Questions

- Should we include visual regression tests?
- Should we test with actual OpenClaw Gateway or always mock?
- Should we include accessibility testing (a11y)?
