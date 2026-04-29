#!/bin/bash

# 接收參數，例如 report/20260428
CURR_D=${1:-"$(date +%Y%m%d)"}

# 設定日期
#CURR_D=$(date +%Y%m%d)
SOURCE_DIR="../stock-Quantum/my-code/topology-4-20260209/report/$CURR_D"
TARGET_DIR="./report/$CURR_D"

echo "🚀 開始執行深度分流同步 (日期: $CURR_D)..."

# 檢查來源是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ 找不到來源目錄: $SOURCE_DIR"
    exit 1
fi

# 建立目標目錄
mkdir -p "$TARGET_DIR"

# --- 核心修正點：使用遞迴複製 ---
echo "📂 正在從 $SOURCE_DIR 同步完整目錄結構至 $TARGET_DIR ..."

# 使用 cp -a (archive 模式，包含子目錄且保留權限)
cp -a "$SOURCE_DIR/." "$TARGET_DIR/"

# 或者使用更專業的 rsync (推薦)
# rsync -av --delete "$SOURCE_DIR/" "$TARGET_DIR/"

# --- 重新產生 files.json (確保路徑掃描深度足夠) ---
echo "🔍 正在更新檔案清單 (掃描深度 3)..."
# 確保找得到 live/6/xxx.txt 這種三層結構
find "$TARGET_DIR" -maxdepth 4 -type f \( -name "*.html" -o -name "*.txt" \) \
    ! -name "files.json" -printf "%P\n" | \
    jq -R . | jq -s . > "$TARGET_DIR/files.json"

echo "✅ files.json 更新完成"

# --- Git 同步 ---
git add .
git commit -m "Update: Recursive reports for $CURR_D ($(date +%H:%M:%S))"
git push origin main

echo "✨ 完整同步完成！"

