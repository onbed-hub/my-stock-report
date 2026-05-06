#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import os
import json
import re
import argparse
from datetime import datetime

def update_specific_report(target_date):
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

    # 2. 指定檔案路徑
    # 根據你的格式，路徑為 report/YYYYMMDD/all-trend-backtest-report.html
    target_path = f"report/{target_date}/all-trend-backtest-report.html"
    
    if not os.path.exists(target_path):
        print(f"❌ 錯誤：找不到檔案 {target_path}")
        return

    # 3. 讀取並執行安全檢查
    try:
        with open(target_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # 核心安全檢查：若沒發現標籤則立即離開
        if 'const markLists =' not in content:
            print(f"🛑 安全警告：在 {target_path} 中找不到 'const markLists'。")
            print("程式已停止修改，請確認該 HTML 是否已加入自定義清單功能。")
            return

        # 4. 執行替換
        pattern = r'const markLists = \{.*?\};'
        replacement = f'const markLists = {new_json};'
        new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

        # 5. 寫入檔案
        with open(target_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"✨ 成功更新 {target_date} 的自定義清單！")
        print(f"📊 已同步清單：{', '.join(mark_lists.keys())}")

    except Exception as e:
        print(f"❌ 發生非預期錯誤: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="針對特定日期的 all-trend-backtest-report.html 更新清單")
    parser.add_argument("-d", "--date", type=str, help="日期格式 YYYYMMDD", required=True)
    
    args = parser.parse_args()
    update_specific_report(args.date)

