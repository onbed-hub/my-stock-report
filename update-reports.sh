#!/bin/bash

#!/bin/bash

# 設定要更新的天數，預設為 1 (只更新今天)
# 你可以在執行時輸入參數，例如: ./update-reports.sh 2
DAYS_TO_UPDATE=${1:-1}

echo "📅 準備更新過去 $DAYS_TO_UPDATE 天的報告..."

# 迴圈處理日期
for (( i=0; i<$DAYS_TO_UPDATE; i++ ))
do
    # 計算日期 (例如 0 代表今天, 1 代表昨天)
    CURR_D=$(date -d "$i days ago" +%Y%m%d)
    
    SOURCE_DIR="../stock-Quantum/my-code/topology-4-20260209/report/$CURR_D"
    TARGET_DIR="./report/$CURR_D"

    echo "------------------------------------------"
    echo "🚀 處理日期: $CURR_D ($((i+1))/$DAYS_TO_UPDATE)"

    # 檢查來源是否存在
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "⚠️  跳過：找不到來源目錄 $SOURCE_DIR"
        continue
    fi

    # 建立目標目錄
    mkdir -p "$TARGET_DIR"

    # 同步目錄結構 (包含 data 子目錄)
    echo "📂 正在同步目錄結構..."
    cp -a "$SOURCE_DIR/." "$TARGET_DIR/"

    # 重新產生 files.json
    echo "🔍 更新檔案清單 (掃描深度 4)..."
    find "$TARGET_DIR" -maxdepth 4 -type f \( -name "*.html" -o -name "*.txt" \) \
        ! -name "files.json" -printf "%P\n" | \
        jq -R . | jq -s . > "$TARGET_DIR/files.json"
    
    echo "✅ $CURR_D 處理完成"
done

# --- Git 同步 (全部日期處理完後再一次 Push) ---
echo "------------------------------------------"
echo "🔄 正在上傳至 GitHub..."
git add .
COMMIT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
git commit -m "Update: Recursive reports for last $DAYS_TO_UPDATE days ($COMMIT_TIME)"
git push origin main

echo "✨ 全部完成！"
echo "🌐 GitHub: https://github.com/onbed-hub/my-stock-report"
echo "🌐 網址: https://onbed-hub.github.io/my-stock-report/"

