# PRD: Documentation

## Introduction

The Documentation provides comprehensive guides for both users and developers of the OpenClaw Admin Panel. User guides help admins set up agents, understand presets, and follow security best practices. Developer guides explain the architecture, how to extend the system, and add new features. Clear documentation is critical for adoption and successful use of the system.

## Goals

- Create user-friendly getting started guide
- Document preset explanations and use cases
- Provide comprehensive tool reference
- Document security best practices
- Create developer architecture overview
- Document how to add new tool categories
- Explain custom preset creation
- Document plugin system for extensions
- Provide examples and code snippets
- Keep documentation up-to-date with code changes

## User Stories

### US-001: Getting started guide
**Description:** As a new user, I want a getting started guide so I can quickly set up my first agent.

**Acceptance Criteria:**
- [ ] Step-by-step tutorial for first agent creation
- [ ] Screenshots or diagrams for key steps
- [ ] Common pitfalls and how to avoid them
- [ ] "What next?" section with links to advanced topics
- [ ] Estimated time to complete (e.g., "10 minutes")
- [ ] Prerequisites listed clearly
- [ ] Troubleshooting section
- [ ] Markdown format with syntax highlighting
- [ ] Review for clarity and accuracy

### US-002: Preset explanations
**Description:** As an admin, I want documentation explaining when to use each preset so I can make informed decisions.

**Acceptance Criteria:**
- [ ] Potato preset: Explain minimal use case (basic Q&A)
- [ ] Coding preset: Explain when needed (development tasks)
- [ ] Messaging preset: Explain when needed (communication bots)
- [ ] Full preset: Explain risks and when justified
- [ ] Comparison table of presets
- [ ] Example scenarios for each preset
- [ ] Security considerations for each preset
- [ ] Markdown format

### US-003: Tool reference
**Description:** As an admin, I want a tool reference so I can understand what each tool does and the risks involved.

**Acceptance Criteria:**
- [ ] Each tool documented with: name, description, purpose, risks
- [ ] Tools organized by category
- [ ] Risk level indicator (low, medium, high, critical)
- [ ] Examples of when to use each tool
- [ ] Alternative tools for safer options
- [ ] Cross-references to related tools
- [ ] Markdown format with tables
- [ ] Searchable or tagged for easy lookup

### US-004: Security best practices
**Description:** As an admin, I want security best practices so I can configure agents safely.

**Acceptance Criteria:**
- [ ] Principle of least privilege explained
- [ ] Guidelines for tool selection
- [ ] How to review agent permissions
- [ ] Regular security audit checklist
- [ ] Common mistakes to avoid
- [ ] How to detect and respond to unauthorized access
- [ ] Backup and recovery procedures
- [ ] Markdown format with checklists

### US-005: Architecture overview
**Description:** As a developer, I want an architecture overview so I can understand how the system works.

**Acceptance Criteria:**
- [ ] High-level system diagram
- [ ] Component descriptions (frontend, backend, Gateway integration)
- [ ] Data flow between components
- [ ] Technology stack overview
- [ ] Directory structure explanation
- [ ] Key design decisions and rationale
- [ ] Markdown format with diagrams (Mermaid or ASCII)

### US-006: Adding new tool categories
**Description:** As a developer, I want a guide for adding new tool categories so I can extend the system.

**Acceptance Criteria:**
- [ ] Step-by-step instructions for adding category
- [ ] Code examples for category definition
- [ ] How to update UI to show new category
- [ ] How to validate tools in new category
- [ ] How to include in presets
- [ ] Testing guidelines for new category
- [ ] Markdown format with code blocks

### US-007: Custom preset creation
**Description:** As an advanced user, I want to create custom presets so I can save frequently used tool configurations.

**Acceptance Criteria:**
- [ ] How to create preset in config file
- [ ] Preset file format and structure
- [ ] How to include custom preset in UI
- [ ] Examples of useful custom presets
- [ ] How to share presets with other users
- [ ] Markdown format with YAML examples

### US-008: Plugin system documentation
**Description:** As a developer, I want plugin system docs so I can extend the admin panel with custom functionality.

**Acceptance Criteria:**
- [ ] Plugin architecture overview
- [ ] How to create a plugin
- [ ] Plugin lifecycle (register, initialize, cleanup)
- [ ] Available hooks and events
- [ ] API for interacting with admin panel
- [ ] Example plugins with code
- [ ] How to distribute and install plugins
- [ ] Markdown format with TypeScript examples

### US-009: API reference
**Description:** As a developer, I want API documentation so I can programmatically interact with the admin panel.

**Acceptance Criteria:**
- [ ] All REST API endpoints documented
- [ ] Request/response examples for each endpoint
- [ ] WebSocket events documented
- [ ] Authentication requirements
- [ ] Error codes and meanings
- [ ] Rate limiting information
- [ ] OpenAPI/Swagger spec optional
- [ ] Markdown or OpenAPI format

### US-010: Troubleshooting guide
**Description:** As a user, I want a troubleshooting guide so I can resolve common issues.

**Acceptance Criteria:**
- [ ] Common error messages and solutions
- [ ] Connection issues (Gateway unreachable)
- [ ] Configuration errors (invalid YAML)
- [ ] Hot-reload failures
- [ ] Permission issues
- [ ] Performance problems
- [ ] Debugging steps
- [ ] When to ask for help
- [ ] Markdown format with error codes

## Functional Requirements

- FR-1: All documentation in Markdown format
- FR-2: Documentation in docs/ directory
- FR-3: User docs in docs/user/
- FR-4: Developer docs in docs/developer/
- FR-5: Code examples included where relevant
- FR-6: Screenshots or diagrams for complex topics
- FR-7: Documentation synced with code releases
- FR-8: Table of contents in each major doc

## Non-Goals

- No video tutorials (can be added later)
- No interactive tutorials
- No localization in this version (English only)

## Design Considerations

- Clean, readable Markdown with proper formatting
- Code blocks with syntax highlighting
- Diagrams using Mermaid or ASCII art
- Screenshots for UI-heavy sections
- Consistent formatting across all docs
- Clear headings and subheadings
- Links between related sections

## Technical Considerations

- Documentation site generator: MkDocs, Docusaurus, or VitePress
- Versioning: Document versions for different releases
- Search: Algolia or built-in search
- CI: Build docs on every PR to catch broken links
- Examples: Live code examples where possible

## Success Metrics

- Documentation covers all major features
- Zero broken links in documentation
- Code examples are copy-paste runnable
- Users can complete getting started guide without external help

## Open Questions

- Should we host documentation on a separate site?
- Should we include API docs in user docs or separate?
- Should we support community contributions to docs?
