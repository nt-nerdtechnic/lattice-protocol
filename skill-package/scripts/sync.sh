#!/bin/bash
# JVC (JSON Version Control) - AI-Native Distributed Sync (v3.2 Stable)
# This is the implementation script for the JVC Skill.

# --- Configuration ---
# These should be set in your agent's environment or local_registry.json
WORKSPACE_ROOT="${JVC_WORKSPACE_ROOT:-$HOME/ai_workspace}"
LOCAL_REPO="$WORKSPACE_ROOT/skills"
# Default to the skill's own directory for the local registry if not specified
LOCAL_REGISTRY="${JVC_LOCAL_REGISTRY:-$LOCAL_REPO/jvc-protocol/local_registry.json}"

# 排除名單 (Git-ignore)
SYNC_IGNORE=("COMMIT_HISTORY.md" "*.log" ".DS_Store" "manifest.json" ".lock" "snapshots")
EXCLUDE_ARGS=""
for item in "${SYNC_IGNORE[@]}"; do EXCLUDE_ARGS="$EXCLUDE_ARGS --exclude='$item'"; done

# 取得本地配置
if [ -f "$LOCAL_REGISTRY" ]; then
    MASTER_REPO=$(jq -r '.master_repo_path // empty' "$LOCAL_REGISTRY")
    CONFIRMED=$(jq -r '.confirmed // "false"' "$LOCAL_REGISTRY")
    SYNC_TARGETS=$(jq -r '.sync_targets[]' "$LOCAL_REGISTRY" 2>/dev/null | tr '\n' ' ')
fi

DEFAULT_MASTER_REPO="${JVC_MASTER_REPO:-$HOME/lattice_master}"
MASTER_REPO=${MASTER_REPO:-$DEFAULT_MASTER_REPO}

usage() {
    echo "JVC (JSON Version Control) Protocol Interface"
    echo "Usage: $0 <command> [args]"
    exit 1
}

fetch_master() {
    echo "🔄 JVC Fetch: Scanning Cloud Master manifests..."
    MAP_FILE="$LOCAL_REPO/jvc-protocol/cloud_map_cache.json"
    mkdir -p "$(dirname "$MAP_FILE")"
    echo "{ \"skills\": {} }" > "$MAP_FILE"
    
    if [ ! -d "$MASTER_REPO" ]; then echo "🚨 Error: Master Repo not found."; return 1; fi

    manifests=$(find "$MASTER_REPO" -name "manifest.json")
    for m in $manifests; do
        skill_info=$(cat "$m")
        name=$(echo "$skill_info" | jq -r ".skill_name")
        full_dir=$(dirname "$m")
        rel_path=${full_dir#$MASTER_REPO/}
        
        tmp=$(mktemp)
        jq --arg name "$name" --arg path "$rel_path" --argjson info "$skill_info" \
           ".skills[\$name] = \$info | .skills[\$name].cloud_path = \$path" "$MAP_FILE" > "$tmp" && mv "$tmp" "$MAP_FILE"
    done
    echo "✅ Fetch Complete."
}

get_cloud_info() {
    local s=$1; local cache="$LOCAL_REPO/jvc-protocol/cloud_map_cache.json"
    [ ! -f "$cache" ] && fetch_master > /dev/null
    jq -r ".skills.\"$s\" // empty" "$cache"
}

pull_skill_logic() {
    local s=$1; local cloud_info=$(get_cloud_info "$s")
    [ -z "$cloud_info" ] && return
    local cloud_path=$(echo "$cloud_info" | jq -r ".cloud_path")
    local m_ver=$(echo "$cloud_info" | jq -r ".version")
    echo "  -> Syncing node [$s]..."
    mkdir -p "$LOCAL_REPO/$s"
    eval "rsync -av --delete $EXCLUDE_ARGS \"$MASTER_REPO/$cloud_path/\" \"$LOCAL_REPO/$s/\""
    tmp=$(mktemp); jq ".skills.\"$s\".version = \"$m_ver\"" "$LOCAL_REGISTRY" > "$tmp" && mv "$tmp" "$LOCAL_REGISTRY"
}

case "$1" in
    fetch) fetch_master ;;
    pull) fetch_master > /dev/null
        for t in $SYNC_TARGETS; do
            if [[ "$t" == cat:* ]]; then
                cat_name=${t#cat:}; cache="$LOCAL_REPO/jvc-protocol/cloud_map_cache.json"
                for s in $(jq -r ".skills | to_entries | .[] | select(.value.category == \"$cat_name\") | .key" "$cache"); do pull_skill_logic "$s"; done
            else pull_skill_logic "$t"; fi
        done ;;
    push)
        s=$2; msg=$3; [ -z "$s" ] || [ -z "$msg" ] && exit 1
        cloud_info=$(get_cloud_info "$s"); cloud_path=$(echo "$cloud_info" | jq -r ".cloud_path")
        LOCK_DIR="$MASTER_REPO/$cloud_path/.lock"
        mkdir "$LOCK_DIR" 2>/dev/null || (echo "🚨 Locked" && exit 1)
        old_ver=$(echo "$cloud_info" | jq -r ".version"); new_ver=$(echo "$old_ver" | awk "{print \$1 + 0.1}"); now=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
        mkdir -p "$MASTER_REPO/snapshots"
        tar -czf "$MASTER_REPO/snapshots/${s}_v${old_ver}.tar.gz" -C "$MASTER_REPO" "$cloud_path" 2>/dev/null
        rsync -av "$LOCAL_REPO/$s/" "$MASTER_REPO/$cloud_path/"
        hist_msg="[$now] v$new_ver - $msg"; tmp_m=$(mktemp)
        jq ".version = \"$new_ver\" | .description = \"$msg\" | .last_updated = \"$now\" | .history = ([\"$hist_msg\"] + .history | .[0:10])" "$MASTER_REPO/$cloud_path/manifest.json" > "$tmp_m" && mv "$tmp_m" "$MASTER_REPO/$cloud_path/manifest.json"
        echo "$hist_msg" >> "$MASTER_REPO/$cloud_path/COMMIT_HISTORY.md"
        rm -rf "$LOCK_DIR"; echo "✅ Push Complete." ;;
    *) usage ;;
esac
