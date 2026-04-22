#!/bin/bash
#

# --- 1. 設定區 ---
DAYS_TO_KEEP=2  # 設定要同步最近幾天的資料

# 來源目錄
SOURCE_BASE="../stock-Quantum/my-code/topology-4-20260209/report"
# 目標目錄
TARGET_BASE="./report"

echo "🚀 開始同步最近 ${DAYS_TO_KEEP} 天的量化報表..."

# 取得比對基準日（DAYS_TO_KEEP 天前的日期，格式為 YYYYMMDD）
THRESHOLD_DATE=$(date -d "${DAYS_TO_KEEP} days ago" +%Y%m%d)

# 確保本地倉庫的 report 目錄存在
mkdir -p "$TARGET_BASE"

# --- 2. 遍歷來源目錄 ---
for dir_path in $(find "$SOURCE_BASE" -maxdepth 1 -type d -regextype sed -regex ".*/[0-9]\{8\}$" | sort); do

    # 取得日期資料夾名稱 (例如 20260421)
    dir_name=$(basename "$dir_path")

    # 💡 核心逻辑：只有當資料夾日期 >= 基準日，才執行同步
    if [ "$dir_name" -ge "$THRESHOLD_DATE" ]; then
        echo "📂 處理日期資料夾 (符合日期限制): $dir_name"

        # 建立目標對應的日期資料夾
        mkdir -p "$TARGET_BASE/$dir_name"

        # --- 3. 執行過濾與複製 (保持你原本的過濾邏輯) ---
        
        # 處理 HTML
        find "$dir_path" -maxdepth 1 -type f -name "*.html" \
            ! -name "*live-[0-9]*" \
            ! -name "*analysis-[0-9]*" \
            ! -name "[0-9]*" \
            -exec cp -u {} "$TARGET_BASE/$dir_name/" \; 2>/dev/null

        # 處理 TXT
        find "$dir_path" -maxdepth 1 -type f -name "*.txt" \
            ! -name "*live-[0-9]*" \
            ! -name "*analysis-[0-9]*" \
            -exec cp -u {} "$TARGET_BASE/$dir_name/" \; 2>/dev/null
    else
        # 這裡可以選擇不印出，或者用來除錯
        # echo "⏭️ 跳過舊資料夾: $dir_name"
        :
    fi
done

# --- 4. 後續自動化流程 ---
echo "產生 live-analysis.html 的即時分析 json 檔案"
./gen_file_list.sh

echo "======================================="
echo "☁️ 準備上傳至 GitHub..."

git pull
git add .
git commit -m "Auto-sync (Last $DAYS_TO_KEEP days): $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo "✨ 全部完成！"
echo "🌐 GitHub: https://github.com/onbed-hub/my-stock-report"
echo "🌐 網址: https://onbed-hub.github.io/my-stock-report/"

