#!/bin/bash

# 檢查 report 目錄是否存在
if [ ! -d "report" ]; then
    echo "錯誤：找不到 report 目錄！"
    exit 1
fi

# 判斷使用者是否有帶入日期參數
if [ -n "$1" ]; then
    target_date="$1"
    target_dir="report/${target_date}"
    
    # 檢查指定的日期資料夾是否存在
    if [ -d "$target_dir" ]; then
        tar_file="my-stock-report-${target_date}.tar.gz"
        echo "正在壓縮指定日期：${target_dir} -> ${tar_file}"
        tar czvf "$tar_file" "$target_dir"
        echo "壓縮完成！"
    else
        echo "錯誤：找不到指定的日期資料夾：${target_dir}"
        exit 1
    fi
else
    # 沒有帶參數時，自動走訪 report 底下的所有資料夾
    found=0
    for dir in report/*/; do
        if [ -d "$dir" ]; then
            found=1
            date_str=$(basename "$dir")
            tar_file="my-stock-report-${date_str}.tar.gz"
            echo "正在壓縮：report/${date_str} -> ${tar_file}"
            tar czvf "$tar_file" "report/${date_str}"
        fi
    done
    
    if [ "$found" -eq 0 ]; then
        echo "report 底下沒有找到任何資料夾。"
    else
        echo "所有報表壓縮完成！"
    fi
fi

