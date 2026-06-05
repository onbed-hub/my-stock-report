#!/bin/bash

# 檢查參數數量是否正確
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "使用方法: $0 <搜尋字串> [搜尋目錄]"
    echo "範例: $0 \"error\" ./report"
    exit 1
fi

SEARCH_STR="$1"
# 如果沒有指定目錄，預設為當前目錄 (.)
SEARCH_DIR="${2:-.}"

# 檢查目錄是否存在
if [ ! -d "$SEARCH_DIR" ]; then
    echo "錯誤: 目錄 '$SEARCH_DIR' 不存在。"
    exit 1
fi

echo "正在 '$SEARCH_DIR' 中搜尋字串: \"$SEARCH_STR\"..."
echo "--------------------------------------------------"

# 執行搜尋
# -r: 遞迴搜尋子目錄
# -n: 顯示行號
# -w: 精準匹配整個單字 (若不需要可拿掉)
# --color=always: 讓關鍵字高亮顯示
# 舊的寫法
# grep -rnw "$SEARCH_DIR" -e "$SEARCH_STR" 2>/dev/null

# 新的寫法：限定只搜尋 .py 檔案
grep -rn --include="*.html" "$SEARCH_STR" "$SEARCH_DIR" 2>/dev/null

# 檢查 grep 的結束狀態碼
if [ $? -ne 0 ]; then
    echo "找不到任何包含 \"$SEARCH_STR\" 的檔案。"
fi


