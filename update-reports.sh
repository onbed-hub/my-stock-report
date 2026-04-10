#!/bin/bash
#

echo "☁️ 準備上傳至 GitHub..."

# 執行 Git 操作
git add .
git commit -m "Auto-sync reports: $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo "✨ 全部完成！"
echo "🌐 網址: https://onbed-hub.github.io/my-stock-report/"

