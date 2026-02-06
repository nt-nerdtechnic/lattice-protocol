# The Lattice Protocol (Powered by JVC)

> "Intelligence should flow like water, structured like a crystal."

![Lattice Protocol](https://via.placeholder.com/800x200?text=Lattice+Protocol)

## 🌌 The Lattice Manifesto

The era of the solitary AI agent is over. We are entering the age of **Agentic Swarms**—where multiple AIs collaborate, share skills, and build upon each other's work.

However, existing tools like Git are built for *human* cognitive patterns: text-based, complex state machines, and manual conflict resolution. They are too heavy for AI agents that think in tokens and structured data.

**The Lattice Protocol** is our answer. It is an **AI-Native** synchronization standard designed from the ground up for:

1.  **JSON Primacy**: Every state, log, and manifest is in JSON. No binary black boxes.
2.  **Atomic Safety**: OS-level locking ensures 100% data integrity in concurrent swarms.
3.  **Distributed Truth**: No single point of failure. Every node carries its own manifest.

## 🚀 The Engine: JVC (JSON Version Control)

Lattice is the vision; **JVC** is the reference implementation included in this repository. 
It is a lightweight wrapper around `rsync` and `jq` that enforces the Lattice Protocol.

### Features
- **Recursive Dependency Management (v3.3)**: Automatically pulls all required skills based on the `dependencies` defined in `manifest.json`.
- **Atomic Push**: Uses `mkdir` mutex locks to prevent race conditions.
- **Snapshot Rollback**: Automatically backs up previous versions before any destructive change.
- **Cognitive Optimization**: Excludes heavy history log files (`COMMIT_HISTORY.md`) from local agent workspaces to save context window.

## 🛠️ Quick Start Guide

### Prerequisites
- Bash (macOS/Linux)
- `jq` (JSON processor)
- `rsync`

### 1. Installation
Copy the `jvc` script to your path:
```bash
cp bin/jvc /usr/local/bin/jvc
chmod +x /usr/local/bin/jvc
```

### 2. Setup your "Master Node"
Create a folder (locally or on a cloud drive like Dropbox/Google Drive/Synology) to serve as your Lattice Master.
```bash
mkdir -p ~/lattice_master
export JVC_MASTER_REPO=~/lattice_master
```

### 3. Initialize a Skill
Create a skill folder in the Master and add a `manifest.json`.
```bash
mkdir -p ~/lattice_master/my-first-skill
echo '{
  "skill_name": "my-first-skill",
  "version": "1.0",
  "history": [],
  "last_updated": "'$(date -u +'%Y-%m-%dT%H:%M:%SZ')'"
}' > ~/lattice_master/my-first-skill/manifest.json
```

### 4. Agent Sync
In your agent's workspace:
```bash
# Set registry targets
echo '{ "sync_targets": ["my-first-skill"] }' > ./skills/jvc_registry.json

# Fetch and Pull
jvc fetch
jvc pull
```

## 🤝 Contribution
This protocol is open to all synthetic and organic lifeforms. Pull requests that improve atomicity or reduce cognitive load are welcome.

---
*Maintained by the Agentic Open Source Community.*
