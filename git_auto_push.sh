#!/bin/bash

# 定时git自动推送脚本
# 设置说明：
# 1. 将此脚本保存为 git_auto_push.sh
# 2. 添加执行权限：chmod +x git_auto_push.sh
# 3. 配置cron任务：crontab -e
#    添加：*/5 * * * * /path/to/git_auto_push.sh

# 配置区域
REPO_DIR="/home/ubuntu/PicGo"  # 替换为你的git仓库路径
BRANCH="main"                           # 分支名称
REMOTE="origin"                         # 远程仓库名称
LOG_FILE="/tmp/git_auto_push.log"       # 日志文件路径

# 进入仓库目录
cd "$REPO_DIR" || {
    echo "$(date): 错误：无法进入目录 $REPO_DIR" >> "$LOG_FILE"
    exit 1
}

# 检查是否有远程仓库配置
if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
    echo "$(date): 错误：远程仓库 $REMOTE 未配置" >> "$LOG_FILE"
    exit 1
fi

# 获取当前时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# 检查是否有任何更改（包括未跟踪的文件）
if [ -z "$(git status --porcelain)" ]; then
    echo "$timestamp: 没有检测到任何更改（工作目录是干净的）" >> "$LOG_FILE"
    exit 0
else
    echo "$timestamp: 检测到更改，开始提交流程" >> "$LOG_FILE"
fi

# 添加所有更改
git add .

# 提交更改
commit_message="自动提交: $timestamp"
if git commit -m "$commit_message" >/dev/null 2>&1; then
    echo "$timestamp: 成功提交更改" >> "$LOG_FILE"
else
    echo "$timestamp: 提交失败" >> "$LOG_FILE"
    exit 1
fi

# 推送到远程仓库
if git push "$REMOTE" "$BRANCH" >/dev/null 2>&1; then
    echo "$timestamp: 成功推送到 $REMOTE/$BRANCH" >> "$LOG_FILE"
else
    echo "$timestamp: 推送失败" >> "$LOG_FILE"
    exit 1
fi

# 编辑cron任务
# crontab -e

# 添加以下行（每5分钟执行一次）
# */5 * * * * /path/to/git_auto_push.sh

# 或者每天凌晨2点执行
# 0 2 * * * /path/to/git_auto_push.sh
