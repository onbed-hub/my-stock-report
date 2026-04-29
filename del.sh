#!/bin/bash

# 設定報告根目錄
BASE_DIR="report"

echo "🚀 正在清理各日期目錄下的股號 .txt 檔案..."

# 使用迴圈遍歷每個日期資料夾
for date_dir in $BASE_DIR/*/; do
    # 檢查是否為目錄
    if [ -d "$date_dir" ]; then
        echo "檢查目錄: $date_dir"
        
        # 刪除該目錄下「數字開頭」且為「.txt」的檔案
        # 這裡的 [0-9]*.txt 隻會匹配當前目錄，不會進入子目錄
        rm -f ${date_dir}[0-9]*.txt 2>/dev/null
        
        # 也可以加上 -v 讓你知道刪了哪些 (可選)
        # rm -fv ${date_dir}[0-9]*.txt 2>/dev/null
    fi
done

echo "✅ 清理完畢！只有日期目錄下的股號 txt 被刪除，data/ 內安然無恙。"
