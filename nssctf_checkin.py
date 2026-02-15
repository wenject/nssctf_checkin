"""
NSSCTF 自动签到脚本
Author: wenject
GitHub: https://github.com/wenject

用法:
  python3 nssctf_checkin.py              # 交互式输入账号密码
  python3 nssctf_checkin.py -u 邮箱 -p 密码  # 命令行传入
"""

import requests
import json
import os
import sys
import argparse
from datetime import datetime


BASE = "https://www.nssctf.cn/api"


def log(msg):
    print(f"[{datetime.now():%Y-%m-%d %H:%M:%S}] {msg}")


def get_credentials():
    """按优先级获取账号密码: 命令行参数 > 环境变量 > 交互输入"""
    parser = argparse.ArgumentParser(description="NSSCTF 自动签到")
    parser.add_argument("-u", "--user", help="NSSCTF 账号(邮箱)")
    parser.add_argument("-p", "--password", help="NSSCTF 密码")
    args = parser.parse_args()

    user = args.user or os.environ.get("NSSCTF_USER", "")
    pwd = args.password or os.environ.get("NSSCTF_PASS", "")

    if not user:
        user = input("请输入 NSSCTF 账号(邮箱): ").strip()
    if not pwd:
        import getpass
        pwd = getpass.getpass("请输入 NSSCTF 密码: ").strip()

    if not user or not pwd:
        log("账号或密码为空，退出")
        sys.exit(1)

    return user, pwd


def login(session, user, pwd):
    """登录 NSSCTF"""
    session.headers.update({
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Referer": "https://www.nssctf.cn/user/login",
        "Origin": "https://www.nssctf.cn",
        "Content-Type": "application/json",
    })
    r = session.post(f"{BASE}/user/login/", data=json.dumps({
        "username": user,
        "password": pwd,
        "remember": "1"
    }), timeout=15)
    data = r.json()
    if data.get("code") != 200:
        return False, data
    return True, data["data"]


def clockin(session):
    """签到"""
    r = session.post(f"{BASE}/user/clockin/", data="{}", timeout=10)
    try:
        d = r.json()
        if d.get("code") == 200:
            return "success", d.get("data", "?")
        return "fail", d
    except Exception:
        if r.status_code == 404:
            return "already", None
        return "error", f"{r.status_code} {r.text[:100]}"


def main():
    log("===== NSSCTF 自动签到 =====")
    user, pwd = get_credentials()

    s = requests.Session()

    log(f"登录中...")
    ok, info = login(s, user, pwd)
    if not ok:
        log(f"❌ 登录失败: {info}")
        sys.exit(1)
    log(f"✅ 登录成功: {info.get('username', user)}")

    status, data = clockin(s)
    if status == "success":
        log(f"✅ 签到成功! 连续签到 {data} 天")
    elif status == "already":
        log("ℹ️  今日已签到，无需重复签到")
    else:
        log(f"❌ 签到异常: {data}")
        sys.exit(1)

    log("完成")


if __name__ == "__main__":
    main()
