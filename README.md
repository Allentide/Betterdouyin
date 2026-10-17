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

**用户不需要输入任何命令**：配置只要点菜单、点「允许」或者双击文件，命令由 AI 自己执行。具体步骤见 [SETUP.md](douyin-account-analysis/SETUP.md)。

## 适用的 AI 助手

任何能在你电脑上执行命令的 AI 助手都可以用，比如 Claude Code、Codex、Cursor、Gemini CLI。截图模式还要求它能看图片。

## 安装

skill 本体是仓库里的 [`douyin-account-analysis/`](douyin-account-analysis) 文件夹，把它放进你的 AI 工具的 skills 目录就能用。

### 方式一：把链接发给 AI，让它自己下载和配置（最省事）

不用自己敲任何命令。复制下面这段话，发给你的 AI 助手（Claude Code、Codex、Cursor 等）：

```
帮我安装并配置这个抖音分析 skill：https://github.com/Allentide/Betterdouyin
```

AI 会按照下面「给 AI 的安装说明」完成这些事：
1. 下载项目，把 skill 装到它自己的 skills 目录；
2. 判断你的电脑是 Mac 还是 Windows，问你用调试模式还是截图模式；
3. 告诉你需要手动点哪几个菜单、开哪几个权限；
4. 运行自检，确认能用。

装好以后，直接说「分析我的抖音账号」就能开始。

#### 给 AI 的安装说明

> 如果你是 AI 助手，用户把本仓库链接发给你并要求安装，请按以下步骤执行：
> 1. 用 git 克隆本仓库，克隆不了就下载 zip：`https://github.com/Allentide/Betterdouyin/archive/refs/heads/main.zip`。
> 2. 把 `douyin-account-analysis/` 文件夹复制到你自己的 skills 目录。Claude Code 是 `~/.claude/skills/`，Codex 是 `~/.codex/skills/`；如果你不支持 skill，就记住这个文件夹的路径，以后每次执行任务前先读里面的 `SKILL.md`。
> 3. 阅读 `douyin-account-analysis/SKILL.md` 的第一节：判断系统，问用户选调试模式还是截图模式，把 `SETUP.md` 里对应的用户操作步骤原样告诉用户，然后执行自检。
> 4. 需要执行的命令都由你来执行。不要让用户自己在终端里敲命令；用户只需要点菜单、点「允许」、双击文件。
> 5. 安装完成后，告诉用户：装在哪里、选的是哪种模式、自检结果如何，以及之后怎么使用（直接说「分析我的抖音账号」）。

### 方式二：用 git 命令

**Mac / Linux**（终端）：

```bash
git clone --depth 1 https://github.com/Allentide/Betterdouyin.git ~/Betterdouyin
mkdir -p ~/.claude/skills
cp -R ~/Betterdouyin/douyin-account-analysis ~/.claude/skills/
```

**Windows**（PowerShell）：

```powershell
git clone --depth 1 https://github.com/Allentide/Betterdouyin.git "$HOME\Betterdouyin"
New-Item -ItemType Directory -Force "$HOME\.claude\skills" | Out-Null
Copy-Item -Recurse "$HOME\Betterdouyin\douyin-account-analysis" "$HOME\.claude\skills\"
```

上面装的是 **Claude Code**，所有项目都能用。其他情况把目标目录换掉就行：

| 用在哪里 | 目标目录 |
|---|---|
| Claude Code（所有项目） | `~/.claude/skills/` |
| Claude Code（只在某个项目里用） | `<项目目录>/.claude/skills/` |
| Codex | `~/.codex/skills/` |
| 其他 AI 工具 | 任意位置都可以，然后对 AI 说「读一下 `<路径>/douyin-account-analysis/SKILL.md`，照着帮我分析抖音账号」 |

### 更新

**Mac / Linux**：

```bash
git -C ~/Betterdouyin pull
rm -rf ~/.claude/skills/douyin-account-analysis
cp -R ~/Betterdouyin/douyin-account-analysis ~/.claude/skills/
```

**Windows**（PowerShell）：

```powershell
git -C "$HOME\Betterdouyin" pull
Remove-Item -Recurse -Force "$HOME\.claude\skills\douyin-account-analysis"
Copy-Item -Recurse "$HOME\Betterdouyin\douyin-account-analysis" "$HOME\.claude\skills\"
```

更新会删掉 Mac 截图模式下编译好的两个小工具，下次使用时 AI 会自动重新编译。

装好之后，对 AI 说「分析我的抖音账号」或者「帮我找同题材点赞最多的作品」就行。

## 目录

```
douyin-account-analysis/      skill 本体，整个文件夹就是一个 skill
  SKILL.md                    给 AI 看的操作手册：选模式、工具用法、安全规则、采集清单、分析方法、对标流程
  SETUP.md                    给用户看的配置指南
  scripts/js/                 调试模式的页面脚本（Mac 和 Windows 通用）
  scripts/mac/                chrome.sh（调试模式）、snap.sh、click.swift、scroll.swift（截图模式）
  scripts/windows/            cdp.ps1（调试模式）、启动抖音分析Chrome.bat（双击启动专用 Chrome）、screen.ps1（截图模式）
```

## 注意

- 本项目**不是抖音官方工具**。它只读取你在自己浏览器里本来就能看到的数据，访问频率和人工浏览差不多。不过页面改版可能导致脚本失效，也请不要长时间高频运行，避免触发平台风控。
- Mac 调试模式需要打开 Chrome 的「允许 Apple 事件中的 JavaScript」。打开后，所有获得「自动化」权限的程序都能在你已登录的网页里执行代码，所以建议用完就关掉。Windows 调试模式用的是一个单独的 Chrome 资料，只监听本机。
- 同一时间只让一个 AI 控制 Chrome。
- 欢迎提 Issue 和 PR，特别是 Windows 上的实测反馈。

## License

[MIT](LICENSE)
