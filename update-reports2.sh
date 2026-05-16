#!/bin/bash

# 設定更新天數
DAYS_TO_UPDATE=${1:-1}

# 1. 定義路徑
REPORT_SOURCES=(
    "../stock-Quantum/my-code/topology-4-20260209/report"
    "../stock-Quantum/my-code/vietnam/report"
)

# 基礎資料來源 (絕對路徑)
STATIC_BASE_SRC="../stock-Quantum/my-code/topology-4-20260209/basic_data/balance-sheet"
# 基礎資料目標 (Local 根目錄)
STATIC_TARGET_DIR="./basic_data/balance-sheet"

# ✨ 新增：圖片來源與目標根目錄
IMG_BASE_SRC="../stock-Quantum/my-code/topology-4-20260209/analysis_data"
IMG_TARGET_DIR="./analysis_data"

# ✨ 新增：basic_data/0520 的來源與目標路徑
STATIC_0520_SRC="../stock-Quantum/my-code/topology-4-20260209/basic_data/0520"
STATIC_0520_DIR="./basic_data/0520"

echo "📅 準備更新報告與同步基礎資料..."

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
JQ_CMD="/usr/local/bin/jq"

# --- A. 同步基礎資料到「本地根目錄」(僅限 TXT) ---
if [ -d "$STATIC_BASE_SRC" ]; then
    echo "📂 正在同步 basic_data/balance-sheet TXT 至本地根目錄: $STATIC_TARGET_DIR"
    mkdir -p "$STATIC_TARGET_DIR"

    # 用 rsync 精確同步 TXT，這不會動到 report 目錄
    rsync -av --delete \
          --include="*/" \
          --include="*.txt" \
          --exclude="*" \
          "$STATIC_BASE_SRC/" "$STATIC_TARGET_DIR/"
    echo "✅ 基礎資料同步完成"
else
    echo "⚠️ 找不到基礎資料來源：$STATIC_BASE_SRC"
fi

# 🔥 新增：同步 basic_data/0520 資料夾的所有檔案
if [ -d "$STATIC_0520_SRC" ]; then
    echo "📂 正在同步 basic_data/0520 資料夾至本地根目錄: $STATIC_0520_DIR"
    mkdir -p "$STATIC_0520_DIR"
    
    # 完整同步 0520 內的所有檔案與子目錄
    rsync -av --delete "$STATIC_0520_SRC/" "$STATIC_0520_DIR/"
    echo "✅ 基礎資料 0520 同步完成"
else
    echo "⚠️ 找不到 0520 資料夾來源：$STATIC_0520_SRC"
fi

# --- B. 同步日期報告 ---
for (( i=0; i<$DAYS_TO_UPDATE; i++ ))
do
    CURR_D=$(date -d "$i days ago" +%Y%m%d)
    TARGET_DIR="./report/$CURR_D"

    echo "------------------------------------------"
    echo "🚀 處理日期: $CURR_D"

    mkdir -p "$TARGET_DIR"

    for src_base in "${REPORT_SOURCES[@]}"
    do
        SOURCE_PATH="$src_base/$CURR_D"
        if [ -d "$SOURCE_PATH" ]; then
            echo "📂 同步報告 (排除任何 basic/balance 目錄): $SOURCE_PATH"
            # ✨ 關鍵排除：不搬運 basic_data，也不搬運可能誤入的 balance-sheet
            rsync -av --exclude="basic_data" --exclude="balance-sheet" "$SOURCE_PATH/" "$TARGET_DIR/"
        fi
    done

    # 2. ✨ 新增：同步對應日期的 summary_combined_*.png 圖片
    # 使用前一天的日期來對應（例如 16 號處理 15 號的圖片）
    # 如果你的圖片命名邏輯跟 CURR_D 是一致的，請把下面的 PREV_D 直接改成 CURR_D 即可
    DAYS_AGO=$((i + 1))
    PREV_D=$(date -d "$DAYS_AGO days ago" +%Y%m%d)
    IMG_NAME="summary_combined_${PREV_D}.png"
    SRC_IMG_PATH="$IMG_BASE_SRC/$IMG_NAME"

    if [ -f "$SRC_IMG_PATH" ]; then
        echo "📸 發現分析圖片，正在複製到本地 analysis_data/ 目錄..."
        mkdir -p "$IMG_TARGET_DIR"
        cp -a "$SRC_IMG_PATH" "$IMG_TARGET_DIR/"
        echo "✅ 圖片 $IMG_NAME 同步成功"
    else
        echo "ℹ️ 未發現對應圖片: $SRC_IMG_PATH (跳過)"
    fi

    # 3. 額外清理：萬一之前留下了錯誤的目錄，直接砍掉
    rm -rf "$TARGET_DIR/balance-sheet"
    rm -rf "$TARGET_DIR/basic_data"

    # 4. 索引更新
    find "$TARGET_DIR" -maxdepth 1 -type f -name "[0-9]*.txt" -delete
    FILE_DATA=$(find "$TARGET_DIR" -maxdepth 4 -type f \( -name "*.html" -o -name "*.txt" \) ! -name "files.json" -printf "%P\n")
    echo "$FILE_DATA" | $JQ_CMD -R . | $JQ_CMD -s . > "$TARGET_DIR/files.json"

    echo "✅ $CURR_D 處理完成"
done

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

