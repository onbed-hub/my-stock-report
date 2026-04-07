#!/bin/bash
#
# 2020/10/25, borchen
#
# ./upload.sh
#
# git branch --all
#
# git push origin abc	# add new branch abc to github
#

# 確保已經初始化 Git LFS（這一步可以省略，除非第一次使用）
#git lfs install

# 追蹤需要 Git LFS 管理的檔案（可選，已經在 .gitattributes 中設定）
#git lfs track "*.csv"
#git lfs track "*.json"
#git lfs track "*.gz"

git pull

git add -A
git commit -m "$(date +%Y%m%d)"
git push origin main
#git push --force origin main

