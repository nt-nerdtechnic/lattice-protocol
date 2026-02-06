---
version: 4.1
name: JVC (JSON Version Control)
description: 跨機技能同步管理員。AI-Native v3.4 版本，支援依賴管理、環境排除機制 (.jvcignore) 與配置分離。
---

# JVC (JSON Version Control)

JVC 是專為 AI Agent 設計的「JSON 原生版本控管系統」。v3.4 引入了「環境排除機制」與「配置分離」，確保跨機同步時不會覆蓋掉本地特有的環境設置。

## 📋 核心哲學 (Core Philosophy)
1. **JSON 第一公民**：所有狀態、歷史與索引均以 JSON 儲存，所見即所得。
2. **依賴自動化**：透過 Manifest 定義技能間的依賴關係，同步時自動抓取所需環境，構建 AI 生態系。
3. **分散式真理**：每個技能資料夾自帶 `manifest.json`，消除單點故障。
4. **環境適應性**：透過 `.jvcignore` 與配置分離，支持不同硬體環境的差異化設置。

## 核心功能

### 1. JVC 索引重建 (Fetch)
- **指令**：`bash skills/skill-sync-manager/scripts/sync.sh fetch`
- **邏輯**：掃描雲端節點，動態產出技能地圖。

### 2. 智慧同步與依賴處理 (Pull)
- **指令**：`bash skills/skill-sync-manager/scripts/sync.sh pull`
- **邏輯**：自動解析 `dependencies` 並遞迴同步所有必要技能。

### 3. 智慧推送 (Push)
- **指令**：`bash skills/skill-sync-manager/scripts/sync.sh push <skill> "描述"`
- **流程**：獲取 JVC 鎖 -> 建立快照 -> 遞增版本 -> 更新 Manifest。

### 4. 環境排除機制 (Exclusion Logic)
- **功能**：支援 `.jvcignore` 檔案，防止特定檔案被同步覆蓋。
- **套用順序**：
    1. 內建安全排除 (如 `config.json`, `registry.json`, `.lock`)。
    2. 全局排除：`skills/skill-sync-manager/.jvcignore`。
    3. 技能排除：`skills/<skill_name>/.jvcignore`。
    4. 根目錄排除：`.jvcignore`。

## 實作架構
- **Dependency Tracking**: 在 `manifest.json` 中定義依賴鏈。
- **Atomic Locking**: 防止多機協作競爭。
- **Config Separation**: 
    - `config.json`: 本地環境設置（不參與同步）。
    - `registry.json`: 本地技能版本紀錄。

---
## 自主優化紀錄
- [2026-02-06] 升級 v3.4：**Environment Adaptability Update**。實作 `.jvcignore` 機制與配置分離 (`config.json` / `registry.json`)，解決跨機同步覆蓋本地路徑的問題。
- [2026-02-06] 升級 v3.3：**Ecosystem Update**。實作「依賴管理 (Dependency Tracking)」機制，同步時自動處理技能依賴鏈。
- [2026-02-06] 升級 v3.2：正式定名為 JVC。
