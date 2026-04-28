#!/bin/bash
# 接收參數，例如 report/20260428
TARGET_DIR=${1:-"report/$(date +%Y%m%d)"}

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 錯誤: 目錄 $TARGET_DIR 不存在"
    exit 1
fi

echo "🔍 正在掃描 $TARGET_DIR 內的檔案..."

# 修正重點：從根目錄出發，並使用 -printf "%P\n" 
# 這樣輸出的路徑會是 "bor-live.html" 或 "live/0/2330.txt"
# 但這些路徑是相對於 $TARGET_DIR 的
find "$TARGET_DIR" -maxdepth 3 -type f \( -name "*.html" -o -name "*.txt" \) \
    ! -name "files.json" -printf "%P\n" | \
    jq -R . | jq -s . > "$TARGET_DIR/files.json"

echo "✅ files.json 已更新於 $TARGET_DIR"
