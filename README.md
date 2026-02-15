# NSSCTF 自动签到

> Author: **wenject**

每天自动签到 [NSSCTF](https://www.nssctf.cn)，部署一次，永久自动。

## 功能

- 自动登录 NSSCTF 并完成每日签到
- 支持 Ubuntu / Debian 服务器部署
- 一键部署脚本，无需编程基础
- 支持 cron 定时任务，每天自动执行

## 快速开始（3 步完成）

### 1. 在服务器上下载代码

SSH 登录你的 Ubuntu 服务器，执行：

```bash
git clone https://github.com/wenject/nssctf-checkin.git
cd nssctf-checkin
```

### 2. 运行一键部署

```bash
bash setup.sh
```

脚本会引导你：

1. 自动安装 Python 和依赖
2. 输入你的 NSSCTF 账号和密码
3. 测试一次签到
4. 设置每天早上 8:00 自动签到

### 3. 完成

部署完成后不用再管了，每天会自动签到。

## 其他用法

### 手动签到

```bash
# 交互式（会提示输入账号密码）
python3 nssctf_checkin.py

# 命令行传参
python3 nssctf_checkin.py -u 你的邮箱 -p 你的密码

# 环境变量
export NSSCTF_USER="你的邮箱"
export NSSCTF_PASS="你的密码"
python3 nssctf_checkin.py
```

## 常用命令

| 操作         | 命令                                  |
| ------------ | ------------------------------------- |
| 查看签到日志 | `cat nssctf.log`                      |
| 查看定时任务 | `crontab -l`                          |
| 手动签到     | `python3 nssctf_checkin.py`           |
| 重新部署     | `bash setup.sh`                       |
| 取消自动签到 | `crontab -e`，删掉含 nssctf 的那行    |
| 修改签到时间 | `crontab -e`，改 `0 8` 为你想要的时间 |

> 时间格式：`分 时`，24 小时制。例如 `30 7` = 每天 7:30，`0 12` = 每天中午 12:00

## 常见问题

**Q: 怎么知道签到成功了？**

查看日志 `cat nssctf.log`，会看到：

```
[2026-02-16 08:00:01] ✅ 登录成功: 你的用户名
[2026-02-16 08:00:01] ✅ 签到成功! 连续签到 5 天
```

**Q: 显示"今日已签到"？**

正常现象，说明今天已经签过了。

**Q: 登录失败？**

检查账号密码是否正确。如果改了密码，重新运行 `bash setup.sh` 即可。

**Q: 想换个签到时间？**

`crontab -e`，把 `0 8` 改成你想要的时间，保存退出。

**Q: 我的密码安全吗？**

密码只保存在你服务器的 cron 定时任务中，不会上传到任何地方。

## 文件说明

```
nssctf_checkin.py   # 签到脚本
setup.sh            # 一键部署脚本
requirements.txt    # Python 依赖
README.md           # 本文档
```

## License

MIT
