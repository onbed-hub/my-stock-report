#!/bin/bash

# 設定要更新的天數，預設為 1
DAYS_TO_UPDATE=${1:-1}

# 1. ✨ 定義多個來源目錄 (在這裡新增你的路徑)
SOURCES=(
    "../stock-Quantum/my-code/topology-4-20260209/report"
    "../stock-Quantum/my-code/vietnam/report"
)

echo "📅 準備更新過去 $DAYS_TO_UPDATE 天的報告..."

for (( i=0; i<$DAYS_TO_UPDATE; i++ ))
do
    CURR_D=$(date -d "$i days ago" +%Y%m%d)
    TARGET_DIR="./report/$CURR_D"

    echo "------------------------------------------"
    echo "🚀 處理日期: $CURR_D ($((i+1))/$DAYS_TO_UPDATE)"

    # 建立目標目錄
    mkdir -p "$TARGET_DIR"

    # 2. ✨ 內層迴圈：處理每一個來源
    for src_base in "${SOURCES[@]}"
    do
        SOURCE_PATH="$src_base/$CURR_D"

        if [ -d "$SOURCE_PATH" ]; then
            echo "📂 正在從 $SOURCE_PATH 同步..."
            # 使用 cp -a 覆蓋同步，同名的檔案會以最後一個來源為準
            cp -a "$SOURCE_PATH/." "$TARGET_DIR/"
        else
            echo "⚠️  跳過來源：找不到 $SOURCE_PATH"
        fi
    done

    # 3. ✨ 清理邏輯：刪除根目錄下數字開頭的 .txt (保留 data/ 目錄)
    # 這是你剛才要求的：只刪除 report/日期/ 底下的股號 txt
    echo "🧹 清理根目錄下冗餘的股號 TXT..."
    find "$TARGET_DIR" -maxdepth 1 -type f -name "[0-9]*.txt" -delete

    # 4. 重新產生 files.json
    echo "🔍 更新檔案清單 (掃描深度 4)..."
    find "$TARGET_DIR" -maxdepth 4 -type f \( -name "*.html" -o -name "*.txt" \) \
        ! -name "files.json" -printf "%P\n" | \
        jq -R . | jq -s . > "$TARGET_DIR/files.json"

    echo "✅ $CURR_D 處理完成"
done

./gen_file_list.sh

# --- Git 同步 ---
echo "------------------------------------------"
echo "🔄 正在上傳至 GitHub..."
git add .
COMMIT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
git commit -m "Update: Combined reports from multiple sources ($COMMIT_TIME)"
git push origin main

echo "✨ 全部完成！"

