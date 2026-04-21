#!/bin/bash

# 設定 report 目錄路徑
REPORT_BASE="report"

if [ ! -d "$REPORT_BASE" ]; then
    echo "錯誤: 找不到 $REPORT_BASE 目錄。"
    exit 1
fi

echo "開始掃描報表目錄..."

# 使用 nullglob 防止資料夾為空時抓到原始字串 "*"
shopt -s nullglob

for dir in "$REPORT_BASE"/*/; do
    # 確保變數不為空且確實是目錄
    [ -d "$dir" ] || continue

    # 💡 使用 Bash 內建語法移除路徑與結尾斜線，代替 basename 指令
    # 這能防止 "missing operand" 錯誤
    temp_dir=${dir%/}
    dir_name=${temp_dir##*/}

    # ---------------------------------------------------------
    # 💡 補回判斷邏輯：如果 files.json 已經存在就跳過
#    if [ -f "$temp_dir/files.json" ]; then
#        echo "⏭️  跳過目錄: $dir_name (files.json 已存在)"
#        continue
#    fi
    # ---------------------------------------------------------

#    echo "處理目錄: $dir_name"

    # 1. 直接在 ls 階段處理，並加入檢查確保有 html 檔案
    # 2. 將清單轉成標準 JSON
    html_files=$(ls "$temp_dir"/*.html 2>/dev/null)
    
    if [ -z "$html_files" ]; then
        echo "  ⚠️  警告: $dir_name 內沒有 HTML 檔案，產生空陣列。"
        echo "[]" > "$temp_dir/files.json"
    else
        echo "$html_files" | xargs -n 1 basename | \
        python3 -c "import sys, json; print(json.dumps([line.strip() for line in sys.stdin if line.strip()]))" > "$temp_dir/files.json"
    fi

    echo "  ✅ 已產生: $temp_dir/files.json"
done

echo "---"
echo "全部處理完成！"

