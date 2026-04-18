#!/bin/bash
#

# --- 設定路徑 (根據你的 ll 結果修正) ---
# 來源目錄：量化程式報表存放的總目錄
SOURCE_BASE="../stock-Quantum/my-code/topology-4-20260209/report"
# 目標目錄：GitHub 倉庫內的 report 資料夾
TARGET_BASE="./report"

#echo "🚀 開始同步量化報表..."

# 確保本地倉庫的 report 目錄存在
mkdir -p "$TARGET_BASE"

# 遍歷來源目錄下所有 8 位數字的日期資料夾
# 使用 find 確保只抓取目錄，避免路徑出錯
for dir_path in $(find "$SOURCE_BASE" -maxdepth 1 -type d -regextype sed -regex ".*/[0-9]\{8\}$"); do

    # 取得日期資料夾名稱 (例如 20260406)
    dir_name=$(basename "$dir_path")

#    echo "---------------------------------------"
#    echo "📂 處理日期: $dir_name"

    # 建立目標對應的日期資料夾
    mkdir -p "$TARGET_BASE/$dir_name"

    # 複製該日期資料夾下的所有 html 檔案到目標
    # 使用 -u 參數：僅在來源檔案較新或目標不存在時才複製
    cp -u "$dir_path"/*.html "$TARGET_BASE/$dir_name/" 2>/dev/null
    cp -u "$dir_path"/*.txt "$TARGET_BASE/$dir_name/" 2>/dev/null

#    if [ $? -eq 0 ]; then
#        echo "✅ 已更新: $TARGET_BASE/$dir_name/"
#    else
#        echo "⚠️  $dir_name 資料夾內無 HTML 檔案，跳過。"
#    fi
done

echo "產生 live-analysis.html 的即時分析 json 檔案"
./gen_file_list.sh

echo "======================================="
echo "☁️ 準備上傳至 GitHub..."

# 執行 Git 操作
git pull
git add .
git commit -m "Auto-sync reports: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo "✨ 全部完成！"
echo "🌐 GitHub: https://github.com/onbed-hub/my-stock-report"
echo "🌐 網址: https://onbed-hub.github.io/my-stock-report/"

