#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import os

# 🚀 請在這裡設定你要檢查的資料夾路徑 (例如今天 2026-07-04 的報表)
TARGET_DIR = "./report" 

def check_folder(path):
    if not os.path.exists(path):
        print(f"❌ 錯誤：找不到資料夾【{path}】！請確認路徑是否正確。")
        return

    print(f"🔍 開始檢查資料夾: {path}")
    print("-" * 50)
    
    file_count = 0
    symlink_count = 0
    empty_dirs = []

    for root, dirs, files in os.walk(path):
        # 檢查空資料夾
        if not dirs and not files:
            empty_dirs.append(root)
            
        for file in files:
            full_path = os.path.join(root, file)
            file_count += 1
            
            # 檢查是否為符號連結 (Symlink)
            if os.path.islink(full_path):
                print(f"⚠️  發現 Symlink (不支援): {full_path}")
                symlink_count += 1

    print("-" * 50)
    print(f"📊 檢查結果:")
    print(f"   - 總檔案數量: {file_count} 個")
    print(f"   - 符號連結數量: {symlink_count} 個")
    
    if empty_dirs:
        print(f"   - ⚠️  發現 {len(empty_dirs)} 個空資料夾 (可能導致 Pages 部署失敗):")
        for ed in empty_dirs:
            print(f"     -> {ed}")
            
    if file_count == 0:
        print("❌ 警告：這是一個空資料夾，GitHub Pages 無法部署空內容！")
    elif symlink_count == 0:
        print("✅ 結構檢查看起來正常，沒有發現異常的 Symlink。")

if __name__ == "__main__":
    check_folder(TARGET_DIR)

