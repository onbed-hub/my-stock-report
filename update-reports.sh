#!/bin/bash

# 取得日期參數，預設為當天 (例如 20260428)
DATE_DIR=${1:-"$(date +%Y%m%d)"}

# --- 1. 設定區 ---
# 💡 修正關鍵：來源路徑必須包含日期資料夾
SOURCE_BASE="../stock-Quantum/my-code/topology-4-20260209/report"
SOURCE_DIR="$SOURCE_BASE/$DATE_DIR"

# 目標目錄
TARGET_BASE="./report"
TARGET_PATH="$TARGET_BASE/$DATE_DIR"

# 建立目標基礎目錄
mkdir -p "$TARGET_PATH"

echo "🚀 開始執行深度分流同步 (日期: $DATE_DIR)..."
echo "📂 來源: $SOURCE_DIR"
echo "📂 目標: $TARGET_PATH"

# --- 2. 檢查來源目錄 ---
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ 錯誤: 找不到來源目錄 $SOURCE_DIR"
    exit 1
fi

# --- 3. 搬移 HTML 檔案 ---
echo "正在搬移 HTML 報表..."
# 這裡使用 cp -f 確保覆蓋最新版，! -name "[0-9]*" 排除純數字檔名
find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.html" \
    ! -name "[0-9]*" \
    -exec cp -f {} "$TARGET_PATH/" \;

# --- 4. 搬移 TXT 檔案並執行「末碼分流」 ---
echo "正在進行個股 TXT 分流..."
# 確保目錄存在
mkdir -p "$TARGET_PATH/live"

for txt_file in "$SOURCE_DIR"/*.txt; do
    [ -e "$txt_file" ] || continue
    filename=$(basename "$txt_file")

    # 擷取股票代號末碼 (例如 2330-live.txt -> 0)
    last_digit=$(echo "$filename" | cut -d'-' -f1 | sed 's/.*\(.\)$/\1/')

    # 防呆：非數字或特殊格式則放入 other
    if [[ ! "$last_digit" =~ [0-9] ]]; then
        last_digit="other"
    fi

    dest_dir="$TARGET_PATH/live/$last_digit"
    mkdir -p "$dest_dir"
    cp -f "$txt_file" "$dest_dir/"
done

# --- 5. 呼叫清單產生器 ---
if [ -f "./gen_file_list.sh" ]; then
    ./gen_file_list.sh "$TARGET_PATH"
fi

# --- 6. Git 推送 ---
echo "正在同步至 GitHub..."
git add .
git commit -m "Update: Structured reports for $DATE_DIR ($(date +%H:%M:%S))"
git push origin main

echo "✨ 全部處理完成！"

