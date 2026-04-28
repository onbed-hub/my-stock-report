#!/bin/bash

# 取得日期參數，預設為當天
DATE_DIR=${1:-"$(date +%Y%m%d)"}

# --- 1. 設定區 ---
# 來源目錄 (請確保路徑正確)
SOURCE_DIR="../stock-Quantum/my-code/topology-4-20260209/report"
# 目標目錄
TARGET_BASE="./report"
TARGET_PATH="$TARGET_BASE/$DATE_DIR"

# 建立基礎目錄
mkdir -p "$TARGET_PATH"

echo "🚀 開始執行深度分流同步 (日期: $DATE_DIR)..."

# --- 2. 搬移 HTML 檔案 ---
# 修正重點：確保變數正確，且註解不干擾指令換行
if [ -d "$SOURCE_DIR" ]; then
    find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.html" \
        ! -name "[0-9]*" \
        -exec cp -f {} "$TARGET_PATH/" \;
else
    echo "❌ 錯誤: 找不到來源目錄 $SOURCE_DIR"
    exit 1
fi

# --- 3. 搬移 TXT 檔案並執行「末碼分流」 ---
echo "分流搬移個股 TXT 資料中..."
for txt_file in "$SOURCE_DIR"/*.txt; do
    [ -e "$txt_file" ] || continue
    filename=$(basename "$txt_file")

    # 擷取股票代號末碼 (例如 2330-live.txt -> 0)
    last_digit=$(echo "$filename" | cut -d'-' -f1 | sed 's/.*\(.\)$/\1/')

    # 防呆：非數字則放入 other
    if [[ ! "$last_digit" =~ [0-9] ]]; then
        last_digit="other"
    fi

    dest_dir="$TARGET_PATH/live/$last_digit"
    mkdir -p "$dest_dir"
    cp -f "$txt_file" "$dest_dir/"
done

# --- 4. 呼叫清單產生器 ---
if [ -f "./gen_file_list.sh" ]; then
    chmod +x ./gen_file_list.sh
    ./gen_file_list.sh "$TARGET_PATH"
else
    echo "⚠️ 警告: 找不到 ./gen_file_list.sh"
fi

# --- 5. Git 推送 ---
echo "正在推送至 GitHub..."
git add .
# 使用當前時間戳記避免 nothing to commit
git commit -m "Update reports and restructure: $DATE_DIR ($(date +%H:%M:%S))"
git push origin main

echo "✨ 全部處理完成！"
echo "🌐 預覽網址: https://onbed-hub.github.io/my-stock-report/live-analysis.html?date=$DATE_DIR"

