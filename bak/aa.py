#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import os
import shutil
import re

def get_subfolder(stock_id):
    """與 analyzer34.py 相同的邏輯：根據股號最後一碼決定子目錄"""
    pure_id = stock_id.split('.')[0].split('-')[0] # 處理 8104.TW 或 8104-trend...
    if pure_id.isdigit():
        return pure_id[-1]
    return "other"

def migrate_to_new_structure(base_report_path="report"):
    if not os.path.exists(base_report_path):
        print(f"❌ 找不到目錄: {base_report_path}")
        return

    # 1. 遍歷所有日期資料夾 (例如 20260209)
    date_folders = [d for d in os.listdir(base_report_path) 
                    if os.path.isdir(os.path.join(base_report_path, d)) and d.isdigit()]

    for date_dir in date_folders:
        current_path = os.path.join(base_report_path, date_dir)
        print(f"📂 正在處理日期: {date_dir}...")

        # 2. 建立新的 data 目錄
        target_data_root = os.path.join(current_path, "data")
        
        # 3. 搜尋該目錄下所有的 .txt 報告檔
        # 比對模式：例如 8104-trend-backtest-report.txt
        for filename in os.listdir(current_path):
            if filename.endswith("-trend-backtest-report.txt"):
                # 提取股號 (純數字或 ^TWII)
                pure_id = filename.split('-')[0]
                sub_dir = get_subfolder(pure_id)

                # 準備目標路徑
                dest_dir = os.path.join(target_data_root, sub_dir)
                os.makedirs(dest_dir, exist_ok=True)

                src_file = os.path.join(current_path, filename)
                dest_file = os.path.join(dest_dir, filename)

                # 如果目標檔案已經存在，且跟來源是一模一樣的檔案，就跳過
                if os.path.exists(dest_file):
#                    print(f"  ⚠️ {filename} 已存在於目標路徑，跳過。")
                    continue

                # 執行搬移
                try:
                    shutil.move(src_file, dest_file)
                    # print(f"  OK: {filename} -> data/{sub_dir}/")
                except Exception as e:
                    print(f"  ERR: 搬移 {filename} 失敗: {e}")

        print(f"✅ {date_dir} 遷移完成。")

if __name__ == "__main__":
    # 執行前建議先備份 report 資料夾以防萬一
    migrate_to_new_structure()


