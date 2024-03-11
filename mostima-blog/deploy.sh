#!/bin/bash

# 保存当前目录
CURRENT_DIR=$(pwd)

# 定义博客目录路径常量
BLOG_DIR="/Users/sylvestershi/blog/mostima/mostima-blog"

# 检查是否存在博客目录
if [ ! -d "$BLOG_DIR" ]; then
    echo "错误：找不到博客目录 '$BLOG_DIR'"
    exit 1
fi

# 1. 切换到博客目录
cd "$BLOG_DIR" || exit 1

# 检查是否存在 public 目录
if [ ! -d "public" ]; then
    echo "错误：找不到 public 目录"
    exit 1
fi

# 2. 执行 Hugo 命令
hugo

# 3. 切换到 public 目录
cd public || exit 1

# 4. 提示输入 commit
read -p "请输入 commit: " commit

# 5. 提示是否确认执行
read -p "是否确定执行？(Y/N): " confirmation

# 判断用户输入
if [[ $confirmation =~ ^[Yy]$ ]]; then
    # 6. 执行 git 操作
    git add .
    git commit -m "$commit"
    git push origin main
    echo "部署完成！"
else
    echo "部署已终止。"
fi

# 返回到保存的目录
cd "$CURRENT_DIR" || exit 1

