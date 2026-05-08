#!/bin/bash

# 設定要更新的天數，預設為 1
DAYS_TO_UPDATE=${1:-1}

# 1. ✨ 定義多個來源目錄 (包含你產出 HTML 的路徑)
SOURCES=(
    "../stock-Quantum/my-code/topology-4-20260209/report"
    "../stock-Quantum/my-code/vietnam/report"
)

echo "📅 準備同步過去 $DAYS_TO_UPDATE 天的報告..."

# 1. 確保 Cron 能找到指令
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
JQ_CMD="/usr/local/bin/jq"

for (( i=0; i<$DAYS_TO_UPDATE; i++ ))
do
    CURR_D=$(date -d "$i days ago" +%Y%m%d)
    TARGET_DIR="./report/$CURR_D"

    echo "------------------------------------------"
    echo "🚀 處理日期: $CURR_D ($((i+1))/$DAYS_TO_UPDATE)"

    # 建立目標目錄
    mkdir -p "$TARGET_DIR"

    # 2. ✨ 同步來源：處理每一個來源路徑
    for src_base in "${SOURCES[@]}"
    do
        SOURCE_PATH="$src_base/$CURR_D"

        if [ -d "$SOURCE_PATH" ]; then
            echo "📂 正在從 $SOURCE_PATH 同步 (包含分流目錄)..."
            # 使用 cp -a 保持目錄結構與屬性
            # 這會把原始路徑下的 stock-analysis/0/ 等子目錄完整複製過來
            cp -a "$SOURCE_PATH/." "$TARGET_DIR/"
        else
            echo "⚠️  跳過來源：找不到 $SOURCE_PATH"
        fi
    done

    # 3. ✨ 清理邏輯：刪除根目錄下數字開頭的 .txt (保留資料夾內的檔案)
    echo "🧹 清理根目錄下冗餘的股號 TXT..."
    find "$TARGET_DIR" -maxdepth 1 -type f -name "[0-9]*.txt" -delete

    # 4. 重新產生 files.json (掃描深度 4 以支援分流目錄)
    echo "🔍 更新檔案清單 (深度 4)..."

    # 這裡會抓到：
    # - report/日期/stock-analysis/0/2330.TW-stock-analysis.html
    # - 以及其他你在來源路徑產出的檔案
    FILE_DATA=$(find "$TARGET_DIR" -maxdepth 4 -type f \( -name "*.html" -o -name "*.txt" \) ! -name "files.json" -printf "%P\n")

    if [ -z "$FILE_DATA" ]; then
        echo "[]" > "$TARGET_DIR/files.json"
    else
        # 轉成 JSON 陣列存檔
        echo "$FILE_DATA" | $JQ_CMD -R . | $JQ_CMD -s . > "$TARGET_DIR/files.json"
    fi

    echo "✅ $CURR_D 處理完成"

done

# --- Git 同步 ---
echo "------------------------------------------"
echo "🔄 正在上傳至 GitHub..."
git add -A
COMMIT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
git commit -m "Update: Combined reports and sub-dir sync ($COMMIT_TIME)"
git push origin main

echo "✨ 全部完成！"
echo "🌐 GitHub: https://github.com/onbed-hub/my-stock-report"
echo "🌐 網址: https://onbed-hub.github.io/my-stock-report/"

