#!/bin/bash

#!/bin/bash

# 1. 處理參數 -d
SPECIFIED_DATE=""
while getopts "d:" opt; do
  case $opt in
    d) SPECIFIED_DATE=$OPTARG ;;
    *) echo "使用方法: $0 -d YYYYMMDD"; exit 1 ;;
  esac
done

# 如果沒提供 -d 參數，預設使用今天
if [ -z "$SPECIFIED_DATE" ]; then
    SPECIFIED_DATE=$(date +%Y%m%d)
fi

CURR_D=$SPECIFIED_DATE
TARGET_DIR="./report/$CURR_D"

# 2. 定義來源路徑
REPORT_SOURCES=(
    "../stock-Quantum/my-code/topology-4-20260209/report"
    "../stock-Quantum/my-code/vietnam/report"
)
STATIC_BASE_SRC="../stock-Quantum/my-code/topology-4-20260209/basic_data/balance-sheet"
STATIC_TARGET_DIR="./basic_data/balance-sheet"

echo "📅 準備更新指定日期：$CURR_D"

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
JQ_CMD="/usr/local/bin/jq"

# --- A. 同步基礎資料到「本地根目錄」(僅限 TXT) ---
# 雖然是更新單日，但通常也會確保基礎資料是最新的
if [ -d "$STATIC_BASE_SRC" ]; then
    echo "📂 正在同步 basic_data/balance-sheet TXT 至本地根目錄..."
    mkdir -p "$STATIC_TARGET_DIR"
    rsync -av --delete \
          --include="*/" \
          --include="*.txt" \
          --exclude="*" \
          "$STATIC_BASE_SRC/" "$STATIC_TARGET_DIR/"
else
    echo "⚠️ 跳過基礎資料：找不到來源 $STATIC_BASE_SRC"
fi

# --- B. 同步指定日期報告 ---
echo "------------------------------------------"
echo "🚀 處理目錄: $TARGET_DIR"

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
fi

for src_base in "${REPORT_SOURCES[@]}"
do
    SOURCE_PATH="$src_base/$CURR_D"
    if [ -d "$SOURCE_PATH" ]; then
        echo "📂 同步從: $SOURCE_PATH"
        # 排除任何可能誤入的資料夾
        rsync -av --exclude="basic_data" --exclude="balance-sheet" "$SOURCE_PATH/" "$TARGET_DIR/"
    else
        echo "⚠️ 來源路徑不存在：$SOURCE_PATH"
    fi
done

# 3. 額外清理與索引更新
rm -rf "$TARGET_DIR/balance-sheet"
rm -rf "$TARGET_DIR/basic_data"

# 清理舊的股號 TXT 並更新 files.json
find "$TARGET_DIR" -maxdepth 1 -type f -name "[0-9]*.txt" -delete
FILE_DATA=$(find "$TARGET_DIR" -maxdepth 4 -type f \( -name "*.html" -o -name "*.txt" \) ! -name "files.json" -printf "%P\n")

if [ -z "$FILE_DATA" ]; then
    echo "[]" > "$TARGET_DIR/files.json"
else
    echo "$FILE_DATA" | $JQ_CMD -R . | $JQ_CMD -s . > "$TARGET_DIR/files.json"
fi

echo "✅ $CURR_D 處理完成"

# --- C. GitHub 同步 ---
echo "------------------------------------------"
# 在腳本的 git add -A 之前加入
find ./report -name "basic_data" -type d -exec rm -rf {} +

echo "🔄 正在上傳至 GitHub..."
git add -A
COMMIT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
git commit -m "Update: Combined reports and sub-dir sync ($COMMIT_TIME)"
git push origin main

echo "✨ 全部完成！"
echo "🌐 GitHub: https://github.com/onbed-hub/my-stock-report"
echo "🌐 網址: https://onbed-hub.github.io/my-stock-report/"

