#!/bin/bash
#

# --- 設定路徑 ---
# 來源目錄 (你的程式產出報表的地方)
SOURCE_BASE="../stock-Quantum/my-code/topology-4-20260209"
# 目標目錄 (GitHub Pages 的 report 資料夾)
TARGET_BASE="./report"

echo "🚀 開始同步報表資料..."

# 確保目標基礎目錄存在
mkdir -p "$TARGET_BASE"

# 尋找來源目錄下的所有日期資料夾 (格式假設為 8 位數字)
# 並遍歷這些資料夾
for dir_path in "$SOURCE_BASE"/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/; do
    
    # 檢查目錄是否存在（防止找不到目錄時報錯）
    [ -d "$dir_path" ] || continue
    
    # 取得資料夾名稱 (例如 20260407)
    dir_name=$(basename "$dir_path")
    
    echo "整理日期: $dir_name"
    
    # 建立目標日期資料夾
    mkdir -p "$TARGET_BASE/$dir_name"
    
    # 複製該日期資料夾下的所有 html 檔案
    cp "$dir_path"*.html "$TARGET_BASE/$dir_name/" 2>/dev/null
    
    echo "✅ 已更新 $TARGET_BASE/$dir_name/"
done

echo "---------------------------------------"
echo "準備上傳至 GitHub..."

# 執行 Git 指令
git add .
git commit -m "Auto-update reports: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo "✨ 全部完成！網頁將在 1 分鐘後自動更新。"

