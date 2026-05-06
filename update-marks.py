#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import os
import json
import re
import argparse
from datetime import datetime, timedelta

def get_date_list(start_date_str, end_date_str=None):
    """產生日期字串列表"""
    start_date = datetime.strptime(start_date_str, "%Y%m%d")
    
    # 如果沒給結束日期，就只回傳起始日
    if not end_date_str:
        return [start_date_str]
    
    # 如果結束日期是 "today"，則設為今天
    if end_date_str.lower() == "today":
        end_date = datetime.now()
    else:
        end_date = datetime.strptime(end_date_str, "%Y%m%d")
        
    date_list = []
    current_date = start_date
    while current_date <= end_date:
        date_list.append(current_date.strftime("%Y%m%d"))
        current_date += timedelta(days=1)
    return date_list

def update_specific_report(target_dates):
    # 1. 讀取最新標記清單
    mark_lists = {}
    data_path = "data"
    if os.path.exists(data_path):
        for filename in os.listdir(data_path):
            if filename.endswith("-mark.txt"):
                list_name = filename.replace("-mark.txt", "")
                with open(os.path.join(data_path, filename), "r", encoding="utf-8") as f:
                    stocks = [line.strip() for line in f if line.strip()]
                    mark_lists[list_name] = stocks
    
    new_json = json.dumps(mark_lists, ensure_ascii=False)
    print(f"✅ 載入標記清單: {', '.join(mark_lists.keys())}")

    # 2. 遍歷所有指定的日期
    for date_str in target_dates:
        target_path = f"report/{date_str}/all-trend-backtest-report.html"
        
        if not os.path.exists(target_path):
            print(f"🟡 跳過：找不到 {target_path}")
            continue

        try:
            with open(target_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # 安全檢查
            if 'const markLists =' not in content:
                print(f"🛑 警告：{target_path} 找不到 'const markLists' 標籤，不予修改。")
                continue

            # 執行替換
            pattern = r'const markLists = \{.*?\};'
            replacement = f'const markLists = {new_json};'
            new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

            with open(target_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            print(f"✨ 成功更新: {date_str} 的總表")

        except Exception as e:
            print(f"❌ 更新 {date_str} 時發生錯誤: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="更新特定範圍或單一日期報表的自定義清單")
    parser.add_argument("-d", "--date", type=str, help="單一日期 (YYYYMMDD) 或起始日期", required=True)
    parser.add_argument("-e", "--end", type=str, help="結束日期 (YYYYMMDD) 或輸入 'today'")
    
    args = parser.parse_args()
    
    # 產生日期清單
    target_dates = get_date_list(args.date, args.end)
    update_specific_report(target_dates)


