#!/bin/bash

# 設定 report 目錄路徑
REPORT_BASE="report"

# 檢查 report 目錄是否存在
if [ ! -d "$REPORT_BASE" ]; then
    echo "錯誤: 找不到 $REPORT_BASE 目錄。"
    exit 1
fi

echo "開始掃描報表目錄..."

# 遍歷 report 底下的所有子目錄 (即日期資料夾)
for dir in "$REPORT_BASE"/*/; do
    # 去除路徑結尾的斜線，取得單純的目錄名稱
    dir_name=$(basename "$dir")
    
    # 檢查是否為目錄
    if [ -d "$dir" ]; then
        # 💡 新增判斷：如果 files.json 已經存在就跳過
#        if [ -f "$dir/files.json" ]; then
#            echo "⏭️  跳過目錄: $dir_name (files.json 已存在)"
#            continue
#        fi

        echo "處理目錄: $dir_name"
        
        # 1. 進入該目錄並列出所有 .html 檔案
        # 2. 將清單轉成標準的 JSON 陣列格式
        ls "$dir"*.html 2>/dev/null | xargs -n 1 basename | \
        python3 -c "import sys, json; print(json.dumps([line.strip() for line in sys.stdin if line.strip()]))" > "$dir/files.json"
        
        echo "  ✅ 已產生: $dir/files.json"
    fi
done

echo "---"
echo "全部處理完成！"
