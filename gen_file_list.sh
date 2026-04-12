#!/bin/bash

# 設定 report 目錄路徑
REPORT_BASE="report"

if [ ! -d "$REPORT_BASE" ]; then
    echo "錯誤: 找不到 $REPORT_BASE 目錄。"
    exit 1
fi

echo "開始掃描報表目錄..."

for dir in "$REPORT_BASE"/*/; do
    # 💡 移除 dir 結尾的斜線，避免產生 //
    dir=${dir%/} 
    dir_name=$(basename "$dir")

    if [ -d "$dir" ]; then
        # 如果你想恢復「存在就跳過」的功能，請取消下面註解
        # if [ -f "$dir/files.json" ]; then
        #     echo "⏭️  跳過目錄: $dir_name (files.json 已存在)"
        #     continue
        # fi

        echo "處理目錄: $dir_name"

        # 產生 JSON
        ls "$dir"/*.html 2>/dev/null | xargs -n 1 basename | \
        python3 -c "import sys, json; print(json.dumps([line.strip() for line in sys.stdin if line.strip()]))" > "$dir/files.json"

        # 💡 強制讓 Git 追蹤這個 JSON (防止被 ignore 掉)
        git add -f "$dir/files.json"

        echo "  ✅ 已產生並追蹤: $dir/files.json"
    fi
done

echo "---"
echo "全部處理完成！現在你可以執行 git commit 並 push 了。"
