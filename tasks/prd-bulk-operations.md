# PRD: Bulk Operations System

## Introduction

The Bulk Operations System (Phase 2) enables administrators to perform actions on multiple agents simultaneously, significantly improving efficiency when managing large numbers of agents. This includes selecting multiple agents, applying presets to all, exporting/importing configurations, and using templates for quick agent creation.

## Goals

- Select multiple agents for batch operations
- Apply presets to multiple agents at once
- Export agent configurations in bulk
- Import agent configurations in bulk
- Create and use agent templates
- Preview changes before applying bulk actions
- Undo bulk operations

## User Stories

### US-001: Multi-agent selection
**Description:** As an admin, I want to select multiple agents so I can perform batch operations.

**Acceptance Criteria:**
- [ ] Checkbox appears next to each agent in sidebar
- [ ] "Select All" and "Deselect All" buttons
- [ ] Selected agents visually highlighted
- [ ] Selection counter shows "X agents selected"
- [ ] Selection persists across tab navigation
- [ ] Selection lost when switching agents (must re-select)
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-002: Apply preset to multiple agents
**Description:** As an admin, I want to apply a preset to multiple selected agents so I can quickly configure many agents.

**Acceptance Criteria:**
- [ ] When multiple agents selected, preset buttons show "Apply to X agents"
- [ ] Clicking preset shows confirmation dialog: "Apply [preset] to X agents?"
- [ ] Preview shows which tools will be enabled/disabled
- [ ] Confirmation lists affected agents
- [ ] Progress bar shows application status
- [ ] Success message: "Applied [preset] to X agents"
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-003: Bulk export agent configurations
**Description:** As an admin, I want to export multiple agent configurations so I can backup or share them.

**Acceptance Criteria:**
- [ ] "Export Selected" button appears when agents selected
- [ ] Export format options: JSON, YAML, ZIP (individual files)
- [ ] Include metadata checkbox (export date, admin panel version)
- [ ] Preview dialog shows export contents
- [ ] File download initiated after confirmation
- [ ] Export filename format: agents-export-YYYYMMDD-HHMMSS.json
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-004: Bulk import agent configurations
**Description:** As an admin, I want to import multiple agent configurations so I can quickly restore or migrate agents.

**Acceptance Criteria:**
- [ ] "Import Agents" button in sidebar header
- [ ] File picker accepts: .json, .yaml, .zip
- [ ] Parse and validate imported configs
- [ ] Preview dialog shows agents to be imported
- [ ] Handle conflicts: "Skip duplicates", "Overwrite", "Rename" options
- [ ] Progress bar shows import status
- [ ] Success message: "Imported X agents"
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-005: Create agent templates
**Description:** As an admin, I want to save agent configurations as templates so I can quickly create similar agents.

**Acceptance Criteria:**
- [ ] "Save as Template" button in agent configuration
- [ ] Template name and description fields
- [ ] Template stored in ~/.openclaw/templates/[template-name].yaml
- [ ] Templates listed in "Templates" section
- [ ] "Create from Template" option in New Agent dialog
- [ ] Templates include: tool permissions, skills, memory scope
- [ ] Excludes: agent name, user-specific data
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-006: Manage templates
**Description:** As an admin, I want to view, edit, and delete templates so I can maintain a library of agent configurations.

**Acceptance Criteria:**
- [ ] "Templates" button in sidebar
- [ ] Templates page lists all saved templates
- [ ] Each template shows name, description, date created
- [ ] "Edit" button opens template editor
- [ ] "Delete" button removes template with confirmation
- [ ] "Duplicate" button creates copy of template
- [ ] "Use Template" creates new agent from template
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-007: Preview bulk changes
**Description:** As an admin, I want to preview changes before applying bulk operations so I can avoid mistakes.

**Acceptance Criteria:**
- [ ] Preview dialog shown before bulk action
- [ ] Preview lists all affected agents
- [ ] Preview shows before/after state for each agent
- [ ] Highlight tools that will be added/removed
- [ ] "Confirm" and "Cancel" buttons
- [ ] Preview modal can be dismissed
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-008: Undo bulk operations
**Description:** As an admin, I want to undo bulk operations so I can recover from mistakes.

**Acceptance Criteria:**
- [ ] After bulk operation, "Undo" button appears (temporary)
- [ ] Undo restores agents to previous state
- [ ] Undo available for 60 seconds after operation
- [ ] Undo only works if no subsequent changes made
- [ ] Success message: "Undid last bulk operation"
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-009: Bulk enable/disable tools
**Description:** As an admin, I want to enable or disable specific tools across multiple agents so I can quickly adjust permissions.

**Acceptance Criteria:**
- [ ] With multiple agents selected, "Bulk Tool Actions" menu appears
- [ ] "Enable Tool" dropdown shows all available tools
- [ ] "Disable Tool" dropdown shows currently enabled tools
- [ ] Preview dialog shows which agents will be affected
- [ ] Progress bar shows operation status
- [ ] Success message: "Enabled [tool] on X agents"
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-010: Compare agent configurations
**Description:** As an admin, I want to compare multiple agents so I can understand differences in their configurations.

**Acceptance Criteria:**
- [ ] "Compare" option when 2-5 agents selected
- [ ] Side-by-side comparison view
- [ ] Diff highlighting: green for additions, red for removals
- [ ] Compare sections: tools, skills, memory, soul
- [ ] Jump to section buttons for easy navigation
- [ ] Export comparison as HTML or PDF
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

## Functional Requirements

- FR-1: Support selecting multiple agents via checkboxes
- FR-2: Apply presets to multiple selected agents
- FR-3: Export multiple agent configs to JSON, YAML, or ZIP
- FR-4: Import agent configs from JSON, YAML, or ZIP
- FR-5: Create and manage agent templates
- FR-6: Preview changes before bulk operations
- FR-7: Undo bulk operations within 60 seconds
- FR-8: Bulk enable/disable tools across selected agents
- FR-9: Compare agent configurations side-by-side

## Non-Goals

- No bulk agent deletion (requires individual confirmation per agent for safety)
- No version control integration for templates
- No sharing templates with other users

## Design Considerations

- Selection checkboxes: Small, clickable area
- Selected state: Blue highlight + checkmark
- Bulk action buttons: Appears in sticky header when agents selected
- Preview dialog: Large modal with scrollable content
- Progress bar: Shows percentage completed with agent count

## Technical Considerations

- Selection state managed in component or store
- Batch operations use Promise.all with progress tracking
- Export/import libraries: js-yaml for YAML, JSZip for ZIP
- Diff library: diff for comparing configs
- Template storage: ~/.openclaw/templates/
- Backup created before bulk operations for undo

## Success Metrics

- Bulk preset application completes under 2 seconds for 10 agents
- Export of 50 agents completes under 5 seconds
- Import of 50 agents completes under 5 seconds
- Preview dialog renders under 500ms

## Open Questions

- Should we support scheduling bulk operations?
- Should we allow bulk renaming with pattern matching?
- Should templates be exportable/importable for sharing?
