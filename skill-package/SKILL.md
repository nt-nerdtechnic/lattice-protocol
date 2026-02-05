---
version: 1.0
name: JVC-Protocol
description: Distributed Skill Sync Manager. AI-Native version using JVC architecture.
---

# JVC Protocol (JSON Version Control)

This skill enables an AI Agent to synchronize its capabilities across multiple machines using a decentralized JSON manifest system.

## 📋 Core Philosophy
1. **JSON Primacy**: All state and history are stored in JSON.
2. **Distributed Truth**: Each skill folder carries its own `manifest.json`.
3. **Atomic Safety**: OS-level locking ensures data integrity.

## 核心功能
### 1. Fetch
`bash scripts/sync.sh fetch`
### 2. Pull
`bash scripts/sync.sh pull`
### 3. Push
`bash scripts/sync.sh push <skill_name> "message"`

---
*Open Sourced by NT AI Team.*
