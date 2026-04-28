#!/bin/bash
TARGET_DIR=${1:-"report/$(date +%Y%m%d)"}

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 錯誤: 目錄 $TARGET_DIR 不存在"
    exit 1
fi

echo "🔍 正在掃描 $TARGET_DIR 及其子目錄..."

# 使用 find 掃描兩層子目錄，並紀錄相對路徑
# 例如輸出：live/0/2330-live.txt
cd "$TARGET_DIR"
find . -maxdepth 3 -type f \( -name "*.html" -o -name "*.txt" \) \
    ! -name "files.json" -printf "%P\n" | \
    jq -R . | jq -s . > "files.json"

echo "✅ files.json 產生完成 (含子目錄路徑)。"

echo "---"
echo "全部處理完成！"

