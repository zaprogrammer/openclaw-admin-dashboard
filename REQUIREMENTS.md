---

Project Brief: OpenClaw Admin Panel
Overview
Build a web-based admin dashboard for OpenClaw that provides granular permission management for multiple AI agents. The system implements principle of least privilege - each agent gets only the tools and skills it needs for its specific role.

Core Philosophy
Zero-trust agent architecture: An accountant agent shouldn't access your home assistant; a customer support agent shouldn't access your NAS. Each agent is "nerfed" by default and explicitly granted only necessary capabilities.

---

Technical Requirements
Stack Recommendations
Frontend: React/Next.js or Vue/Nuxt (modern, component-based)
Styling: TailwindCSS (for the dark theme shown in screenshot)
Backend: Node.js/Express or integrate directly with OpenClaw Gateway
Real-time: WebSocket for live agent status updates
Port: Default 18789 (shown in screenshot)

Architecture
Admin server runs locally alongside OpenClaw Gateway
Reads/writes OpenClaw agent configurations (likely YAML/JSON)
Hot-reload capability - changes apply without full restart when possible
Connection status indicator (green "Connected" badge)

---

Feature Specifications
Agent Management (Left Sidebar)
Agent List Display:
Agent name with icon/avatar
Skill count badge (e.g., "0 skills")
Visual selection state (highlighted when active)
Scrollable list for 5+ agents

Agent Operations:
Create new agent
Delete agent
Duplicate agent (clone permissions)
Rename agent

Example agents from screenshot:
main, Dwight, Gilfoyle, Darlene, Dr. Cox, David Goggins, Kevin, Saul Goodman

---
Agent Configuration Tabs
Tab Navigation:
🧑 Soul - Agent personality/identity
👤 User - User context/profile access
🤝 Agents - Inter-agent communication permissions
🧠 Memory - Memory file access scope
🛠️ Tools - Tool permissions (main view)
📦 Skills - Skill installation/management

---

Tool Access Control (Main Feature)
#### Tool Counter
Display: 17/24 tools enabled (dynamic count)
#### Quick Presets (One-click templates)
🥔 Potato       - Minimal (only sessions_status)
💻 Coding       - Files, exec, sessions, memory
💬 Messaging    - Message + sessions
🚀 Full         - Everything


#### Granular Tool Categories

Fs (Filesystem) - 0/4
read - Read file contents
write - Create or overwrite files
edit - Make precise edits to files
apply_patch - Apply patches (OpenAI models)

Runtime - 0/2
exec - Run shell commands
process - Manage background exec sessions

Web - 0/2
web_search - Search the web (Brave API)
web_fetch - Fetch and extract web content

Memory - 0/2
memory_search - Semantic search MEMORY.md + memory/*
memory_get - Read memory snippets

Sessions - 1/6
sessions_list - List other sessions (OFF)
sessions_history - Fetch history for another session (OFF)
sessions_send - Send to another session (OFF)
sessions_spawn - Spawn sub-agent (OFF)
session_status - Show session status (ON) ✓
agents_list - List available agents (OFF)

UI - 0/2
browser - Control web browser
canvas - Control node canvases

Messaging - 0/2
message - Send messages via channels
tts - Text-to-speech

Other potential categories:
Cron (scheduling)
Gateway (config/restart)
Nodes (paired devices)
Image (vision models)

---
Skills Management Tab
Skills Display:
Installed skills list
Skill descriptions
Enable/disable per agent
Install new skills from ClawHub
Local skill folder browser

Skill Actions:
Install from ClawHub
Upload custom skill
Update skill
Remove skill
View skill documentation

---
UI/UX Requirements
Dark Theme (as shown):
Background: #0a0a0a / #1a1a1a
Cards: #1f1f1f / #2a2a2a
Accent: Blue (#3b82f6) for active states
Text: White/gray hierarchy

Interactive Elements:
Toggle switches for tool permissions
Smooth transitions
Visual feedback on changes
Confirmation dialogs for destructive actions

Top Bar:
Agent count indicator: 🔮 8 agents
Refresh button
Restart Gateway button (with confirmation)
Connection status badge

---

Configuration Data Model
agents:
  saul-goodman:
    name: "Saul Goodman"
    description: "slick defense lawyer, persuasive and witty..."
    skills:
      enabled: []
    tools:
      enabled:
        - session_status
      disabled:
        - read
        - write
        - edit
        - exec
        # ... etc
    memory:
      scope: 
        - IDENTITY.md
        - USER.md
      deny:
        - MEMORY.md  # Restrict sensitive memory


---
Security Features
Access Control:
Admin password/token protection
Local-only binding option (127.0.0.1)
Optional whitelist IPs
Rate limiting
Audit log of permission changes

Safety Rails:
Warn before enabling dangerous tools (exec, write)
"Are you sure?" for Full preset
Cannot disable session_status (always required for basic function)
Auto-save with rollback capability

---
Integration Points
OpenClaw Gateway Integration:
Read current agent configs
Validate tool names against OpenClaw's actual tool registry
Apply changes via Gateway API or config file hot-reload
Subscribe to agent events (heartbeats, errors)

Config Location:
Primary: ~/.openclaw/config.yaml or ~/.clawdbot/config.yaml
Agent profiles: ~/.openclaw/agents/*.yaml
Admin panel config: ~/.openclaw/admin.yaml

---

User Workflows
Scenario 1: Creating a specialist agent
Click "New Agent" → Name it "Accountant"
Select "Potato" preset (minimal)
Go to Skills tab → Install "accounting" skill
Go to Tools tab → Enable memory_search, memory_get, web_fetch
Save → Agent is ready with scoped permissions

Scenario 2: Debugging why agent can't do something
Select agent from sidebar
See tool count: 5/24 tools enabled
Scan categories to find missing tool
Toggle on required tool
Changes apply immediately

Scenario 3: Audit agent capabilities
Select agent
See all enabled tools at a glance
Export permissions as JSON/YAML
Compare with other agents

---

Advanced Features (Phase 2)
Conditional Permissions:
Time-based access (e.g., exec only during business hours)
Rate limits per tool (e.g., max 10 web_fetch per hour)
Approval workflows (agent requests permission, admin approves)

Multi-User:
Role-based admin access
Agent ownership
Shared agents with different tool scopes per user
Monitoring Dashboard:
Tool usage statistics
Failed permission attempts
Agent activity timeline
Cost tracking per agent (API usage)

Bulk Operations:
Select multiple agents → Apply preset
Export/import agent configs
Template library

---

Testing Requirements
Unit Tests:
Config parser/validator
Permission checker logic
Preset application

Integration Tests:
Gateway communication
Hot-reload verification
Tool enable/disable propagation

E2E Tests:
Create agent → Configure tools → Verify in OpenClaw session
Apply preset → Verify all tools match expected state

---

Documentation
User Guide:
"Getting Started" - First agent setup
Preset explanations (when to use each)
Tool reference (what each tool does, risks)
Security best practices

Developer Guide:
Architecture overview
Adding new tool categories
Custom preset creation
Plugin system for extensions

---

Success Criteria
✅ Admin can create 10+ agents with different tool combinations
✅ Changes apply without Gateway restart (hot-reload)
✅ UI clearly shows which tools are enabled at a glance
✅ Presets work reliably (Potato, Coding, Messaging, Full)
✅ No agent can access tools not explicitly granted
✅ Audit log captures all permission changes
✅ Zero performance impact on OpenClaw runtime

---

Example Starting Command
# After building the admin panel
openclaw admin start --port 18789

# Or integrated into main config
openclaw gateway start --admin-panel true
---