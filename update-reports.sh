#!/bin/bash
#

DATE_DIR=${1:-"$(date +%Y%m%d)"}

# --- 1. 設定區 ---
DAYS_TO_KEEP=2  # 設定要同步最近幾天的資料

# 來源目錄
SOURCE_BASE="../stock-Quantum/my-code/topology-4-20260209/report"
# 目標目錄
TARGET_BASE="./report"

#DATE_DIR=$(date +%Y%m%d)
TARGET_PATH="$TARGET_BASE/$DATE_DIR"

# 1. 建立基礎目錄
mkdir -p "$TARGET_PATH"

echo "🚀 開始執行深度分流同步..."

# 2. 搬移 HTML 檔案 (保持在根目錄，檔案數通常不多)
find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.html" \
#    ! -name "all-*" \
    ! -name "[0-9]*" \
    -exec cp -f {} "$TARGET_PATH/" \;

# 3. 搬移 TXT 檔案並執行「末碼分流」
# 假設檔名格式如 2330-live.txt 或 6152-live.txt
for txt_file in "$SOURCE_DIR"/*.txt; do
    [ -e "$txt_file" ] || continue
    filename=$(basename "$txt_file")
    
    # 擷取檔名中「第一個連字號前」的最後一個字元 (通常是股票代號末碼)
    # 例如 2330-live.txt -> 抓 0
    last_digit=$(echo "$filename" | cut -d'-' -f1 | sed 's/.*\(.\)$/\1/')
    
    # 如果不是數字（防呆），就放進 'other' 目錄
    if [[ ! "$last_digit" =~ [0-9] ]]; then
        last_digit="other"
    fi

    dest_dir="$TARGET_PATH/live/$last_digit"
    mkdir -p "$dest_dir"
    cp -f "$txt_file" "$dest_dir/"
done

# 4. 呼叫清單產生器
./gen_file_list.sh "$TARGET_PATH"

# 5. Git 推送
git add .
git commit -m "Cleanup and Restructure: Multi-directory distribution for $DATE_DIR"
git push origin main

echo "✨ 全部完成！"
echo "🌐 GitHub: https://github.com/onbed-hub/my-stock-report"
echo "🌐 網址: https://onbed-hub.github.io/my-stock-report/"

