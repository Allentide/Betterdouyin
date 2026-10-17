# Betterdouyin

让 AI 助手在你自己电脑的 Chrome 里打开抖音创作者中心，读取你每条作品的数据，告诉你问题出在哪、下一条该怎么做；再去搜同题材点赞最多的 10 条作品，拆解别人做对了什么。

An AI-agent skill that reads your own Douyin creator-center analytics in your local Chrome, diagnoses each post, and benchmarks you against the top-10 most-liked posts on the same topic.

## 能做什么

- **账号诊断**：读取每条作品的播放、点赞、收藏、分享、吸粉、封面点击率、2 秒跳出率、图文平均浏览张数，以及流量来源、**平台扶持流量**、留存曲线（和同类作品对比）、观众性别年龄地域、搜索关键词；按固定方法找出漏斗卡在哪一步，给出下一条作品的具体建议。
- **同题材 Top 10 对标**：用你作品的真实搜索词去抖音搜索，建候选池、过滤不相关的内容，取点赞最多的 10 条；补上作者粉丝数、评论区和图片内容，再按粉丝体量和发布时长做归一化，总结共性，和你自己的作品逐项对比。
- **只读**：不会点赞、评论、关注、删除或修改任何东西。

## 支持的环境

| | 调试模式（推荐） | 截图模式 |
|---|---|---|
| **Mac** | ✅ 已实测 | ✅ 已实测 |
| **Windows** | ⚠️ 脚本已写好，还没在真机上验证 | ⚠️ 脚本已写好，还没在真机上验证 |
| 原理 | 直接读网页里的数据（Mac 用 Apple 事件，Windows 用 Chrome 远程调试接口） | 截屏看页面，模拟鼠标键盘去点 |
| 运行时能不能用电脑 | 能，在后台标签页里跑 | 不能 |

**用户不需要输入任何命令**：配置只要点菜单、点「允许」或者双击文件，命令由 AI 自己执行。具体步骤见 [SETUP.md](SETUP.md)。

## 适用的 AI 助手

任何能在你电脑上执行命令的 AI 助手都可以用，比如 Claude Code、Codex、Cursor、Gemini CLI。截图模式还要求它能看图片。

**安装**（下面的命令可以直接交给你的 AI 助手去执行）：

- **Claude Code**：把本仓库克隆到 `~/.claude/skills/douyin-account-analysis`（如果只想在某个项目里用，就放到那个项目的 `.claude/skills/` 下）。
- **Codex**：克隆到 `~/.codex/skills/douyin-account-analysis`。
- **其他工具**：克隆到任意位置，然后对 AI 说「读一下 `<路径>/SKILL.md`，照着帮我分析抖音账号」。

装好之后，对 AI 说「分析我的抖音账号」或者「帮我找同题材点赞最多的作品」就行。

## 目录

```
SKILL.md          给 AI 看的操作手册：选模式、工具用法、安全规则、采集清单、分析方法、对标流程
SETUP.md          给用户看的配置指南
scripts/js/       调试模式的页面脚本（Mac 和 Windows 通用）
scripts/mac/      chrome.sh（调试模式）、snap.sh、click.swift、scroll.swift（截图模式）
scripts/windows/  cdp.ps1（调试模式）、启动抖音分析Chrome.bat（双击启动专用 Chrome）、screen.ps1（截图模式）
```

## 注意

- 本项目**不是抖音官方工具**。它只读取你在自己浏览器里本来就能看到的数据，访问频率和人工浏览差不多。不过页面改版可能导致脚本失效，也请不要长时间高频运行，避免触发平台风控。
- Mac 调试模式需要打开 Chrome 的「允许 Apple 事件中的 JavaScript」。打开后，所有获得「自动化」权限的程序都能在你已登录的网页里执行代码，所以建议用完就关掉。Windows 调试模式用的是一个单独的 Chrome 资料，只监听本机。
- 同一时间只让一个 AI 控制 Chrome。
- 欢迎提 Issue 和 PR，特别是 Windows 上的实测反馈。

## License

[MIT](LICENSE)
