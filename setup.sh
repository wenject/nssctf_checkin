#!/bin/bash
# NSSCTF 自动签到 一键部署脚本
# Author: wenject
# 用法: bash setup.sh

set -e

echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║   NSSCTF 自动签到 一键部署       ║"
echo "  ║   Author: wenject                ║"
echo "  ╚══════════════════════════════════╝"
echo ""

# 检查 Python3
if ! command -v python3 &> /dev/null; then
    echo "[*] 未检测到 python3，正在安装..."
    sudo apt update && sudo apt install -y python3 python3-pip
else
    echo "[✓] Python3 已安装"
fi

# 安装依赖
echo "[*] 安装 Python 依赖..."
pip3 install -r requirements.txt --break-system-packages 2>/dev/null || pip3 install -r requirements.txt
echo "[✓] 依赖安装完成"

# 获取账号密码
echo ""
echo "请输入你的 NSSCTF 账号信息（不会上传到任何地方，仅保存在本机定时任务中）"
echo ""
read -p "  NSSCTF 账号(邮箱): " NSSCTF_USER
read -s -p "  NSSCTF 密码: " NSSCTF_PASS
echo ""
echo ""

if [ -z "$NSSCTF_USER" ] || [ -z "$NSSCTF_PASS" ]; then
    echo "[✗] 账号或密码不能为空"
    exit 1
fi

# 测试签到
echo "[*] 测试签到..."
NSSCTF_USER="$NSSCTF_USER" NSSCTF_PASS="$NSSCTF_PASS" python3 nssctf_checkin.py

echo ""
read -p "签到测试通过了吗？设置每天自动签到？(y/n): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "已取消，你可以稍后重新运行 bash setup.sh"
    exit 0
fi

# 设置定时任务
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/nssctf_checkin.py"
PYTHON_PATH="$(which python3)"
LOG_PATH="$SCRIPT_DIR/nssctf.log"

CRON_LINE="0 8 * * * NSSCTF_USER=\"$NSSCTF_USER\" NSSCTF_PASS=\"$NSSCTF_PASS\" $PYTHON_PATH $SCRIPT_PATH >> $LOG_PATH 2>&1"

(crontab -l 2>/dev/null | grep -v "nssctf_checkin" ; echo "$CRON_LINE") | crontab -

echo ""
echo "  ╔══════════════════════════════════╗"
echo "  ║        ✅ 部署完成!              ║"
echo "  ╚══════════════════════════════════╝"
echo ""
echo "  ⏰ 每天早上 8:00 自动签到"
echo "  📄 日志文件: $LOG_PATH"
echo ""
echo "  常用命令:"
echo "    查看日志:   cat $LOG_PATH"
echo "    查看定时:   crontab -l"
echo "    手动签到:   python3 $SCRIPT_PATH"
echo "    重新部署:   bash setup.sh"
echo "    取消签到:   crontab -e  (删掉 nssctf 那行)"
echo ""
