<p align="center">
  <img src="assets/wechat-qr.jpg" width="200" alt="微信二维码"><br>
  <sub>扫码联系我，加入自媒体博主交流群，和众多博主一起交流运营心得</sub>
</p>

<div align="center">

# Betterdouyin · 抖音作品 AI 复盘助手

**让 AI 读懂抖音数据：账号诊断 + 任意主题爆款 Top 10 拆解**

![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows-blue)
![Browser](https://img.shields.io/badge/browser-Chrome-yellow)
![Agent](https://img.shields.io/badge/AI-Claude%20Code%20%7C%20Codex%20%7C%20Cursor%20%7C%20Gemini%20CLI-purple)

[1. 能做什么](#1-能做什么) · [2. 能帮你看清什么](#2-能帮你看清什么) · [5. 安装](#5-安装) · [6. 使用方法](#6-使用方法) · [配置指南](douyin-account-analysis/SETUP.md) · [8. 注意](#8-注意) · [9. 加入开发团队](#9-加入开发团队)

</div>

---

让 AI 助手在你自己电脑的 Chrome 里打开抖音。你可以直接给它一个主题，让它搜出点赞最多的 10 条作品，拆解别人做对了什么；也可以让它读你创作者中心里每条作品的数据，告诉你问题出在哪、下一条该怎么做。

## 1. 能做什么

- **账号诊断**：读取每条作品的播放、点赞、收藏、分享、吸粉、封面点击率、2 秒跳出率、图文平均浏览张数，以及流量来源、**平台扶持流量**、留存曲线（和同类作品对比）、观众性别年龄地域、搜索关键词；按固定方法找出漏斗卡在哪一步，给出下一条作品的具体建议。
- **主题搜索 Top 10**：**不用分析自己的账号**，直接告诉 AI 一个主题（例如「舞蹈」），它会搜出这个主题点赞最多的 10 条作品，拆解标题、封面、结构和评论区需求，给你几个可以直接拍的选题方案。
- **同题材 Top 10 对标**：用你作品的真实搜索词去抖音搜索，建候选池、过滤不相关的内容，取点赞最多的 10 条；补上作者粉丝数、评论区和图片内容，再按粉丝体量和发布时长做归一化，总结共性，和你自己的作品逐项对比。
- **指定作品分析**：不想看全部作品？可以只分析某一条或某几条，比如「最新那条」「10 月 16 号那条」「标题里有『舞蹈』的那条」，或者直接发作品链接。别人的作品发链接也能分析。
- **判断内容是否过气**：比如「某某大赏还能做吗」。按月份对比作品数量、点赞中位数、爆款比例，再拆分子形式，看哪种在降温、哪种在升温。
- **只读**：不会点赞、评论、关注、删除或修改任何东西。

## 2. 能帮你看清什么

做抖音最常见的困惑，AI 都会拿你账号的真实数据来回答：

| 你关心的问题 | AI 看哪些数据 | 你会得到什么 |
|---|---|---|
| 我的播放是真实水平，还是平台推起来的？ | 播放量、**平台扶持流量**、各作品播放中位数 | 扣掉扶持后的真实水平；哪条是靠平台流量撑起来的，别拿它当标准 |
| 观众在哪一步流失了？ | 封面点击率 → 2 秒跳出率、划走率 → 留存曲线 → 点赞、收藏、评论 → 涨粉 | 卡在哪一环，下一条该先改封面、开头还是结构 |
| 图文发几张合适？ | 平均浏览张数、逐张留存曲线（和同类作品对比） | 观众看到第几张就走了，下一条建议发几张、重点放前几张 |
| 观众怎么找到我的，还想看什么？ | 流量来源（推荐、主页、搜索、合集）、**搜索词**（搜什么词看到你，看完又搜了什么） | 哪些词该写进标题做搜索优化；观众看完还想看什么，可以直接当下一条的选题 |
| 谁在看我，和我的定位对得上吗？ | 性别、年龄、地域、兴趣、活跃度、涨粉和脱粉 | 账号定位有没有跑偏，内容该往哪类人调整 |
| 哪种内容能涨粉？ | 每千次播放带来的涨粉、主页访问、藏赞比 | 哪类内容能拉来新粉丝，哪类只被收藏、存完就走 |
| 为什么没人评论？ | 评论进入率和评论率的落差 | 观众点开评论区看到是空的就走了，可以先置顶一条评论把话题带起来 |
| 同题材的爆款做对了什么？ | 点赞最多的 10 条：赞、评、藏、转、作者粉丝、发布时间、标题、封面、结构、评论区 | 这 10 条的共同点、你和它们的差距，再加 2 到 3 个可以直接拍的方案 |
| 这个题材还能做吗？ | 按月统计的作品数、点赞中位数、爆款数量、各个子形式的冷热 | 判断是在上升、已经饱和还是在降温，以及该换什么角度 |

<details>
<summary><b>完整指标清单（点开查看）</b></summary>

**你自己的作品**（读的是抖音创作者中心后台，需要登录）

- **每条作品**：播放、点赞、评论、分享、收藏、下载、弹幕；涨粉、脱粉、主页访问、粉丝播放占比；封面展示次数、封面点击率；2 秒跳出率、5 秒完播率、完播率、平均播放时长；图文平均浏览张数、文案展开率、文案完读率；评论进入率、评论率、不感兴趣率；点赞率、收藏率、分享率、关注率；发布时间、体裁（图文几张、视频多长）、公开还是私密
- **单条作品详情**：流量来源占比和 7 日对比；平台扶持流量；搜索词（「通过这些词看到」「看完后常搜」）；留存曲线和同类作品对比；点赞分布（第几秒、第几张时点赞最多）；各项指标和以往作品的对比
- **观众画像**：性别、年龄、地域（到省）、兴趣分布、活跃程度、涨粉和脱粉趋势；粉丝满 1000 后有「受众关注热词」
- **账号整体**：粉丝、获赞、近 7 天播放、主页访问、净增粉；和同类作者的对比；粉丝画像（粉丝满 300 才有）

**别人的作品**（公开数据，登录普通抖音账号就行）

- 点赞、评论、收藏、转发；发布时间、时长或张数、标题、文案、话题
- 作者的粉丝数和获赞数；评论区内容；视频的「章节要点」（抖音自动生成的 AI 总结）；图文的图片
- 搜索结果的「相关搜索」词
- 拿不到的：别人作品的播放量、留存、流量来源、观众画像。这些只有作者本人能看到，AI 也不会编

**AI 计算出来的指标**

- **诊断账号**：自然播放（扣掉扶持后）、流量集中度、漏斗每一步的流失、藏赞比、评论进入率和评论率的落差、每千次播放涨粉、图文实际看了几张占总张数的比例、留存掉点、不同封面点击率对比、发布节奏
- **对标 Top 10**：点赞 ÷ 作者粉丝数（看小号能不能爆）、按距今天数修正、藏赞比、评赞比、转赞比
- **判断题材是否过气**：按月统计的作品数、点赞中位数、爆款数量，子形式冷热对比，标题模板重复率

</details>

## 3. 支持的环境

| | 调试模式（推荐） | 截图模式 |
|---|---|---|
| 支持的系统 | Mac、Windows | Mac、Windows |
| 原理 | 直接读网页里的数据（Mac 用 Apple 事件，Windows 用 Chrome 远程调试接口） | 截屏看页面，模拟鼠标键盘去点 |
| 运行时能不能用电脑 | 能。在一个单独的最小化窗口里跑，不会弹出来，也不会动你的标签页 | 不能，Chrome 要一直在最前面 |

**用户不需要输入任何命令**：配置只要点菜单、点「允许」或者双击文件，命令由 AI 自己执行。具体步骤见 [SETUP.md](douyin-account-analysis/SETUP.md)。

## 4. 适用的 AI 助手

任何能在你电脑上执行命令的 AI 助手都可以用，比如 Claude Code、Codex、Cursor、Gemini CLI。截图模式还要求它能看图片。

## 5. 安装

skill 本体是仓库里的 [`douyin-account-analysis/`](douyin-account-analysis) 文件夹，把它放进你的 AI 工具的 skills 目录就能用。

### 5.1 方式一：把链接发给 AI，让它自己下载和配置（最省事）

不用自己敲任何命令。复制下面这段话，发给你的 AI 助手（Claude Code、Codex、Cursor 等）：

```
帮我安装并配置这个抖音分析 skill：https://github.com/Allentide/Betterdouyin
```

AI 会按照 5.2「给 AI 的安装说明」完成这些事：
1. 下载项目，把 skill 装到它自己的 skills 目录；
2. 判断你的电脑是 Mac 还是 Windows，问你用调试模式还是截图模式；
3. 告诉你需要手动点哪几个菜单、开哪几个权限；
4. 运行自检，确认能用。

装好以后，怎么用见 [6. 使用方法](#6-使用方法)。

### 5.2 给 AI 的安装说明

> 如果你是 AI 助手，用户把本仓库链接发给你并要求安装，请按以下步骤执行：
> 1. 用 git 克隆本仓库，克隆不了就下载 zip：`https://github.com/Allentide/Betterdouyin/archive/refs/heads/main.zip`。
> 2. 把 `douyin-account-analysis/` 文件夹复制到你自己的 skills 目录。Claude Code 是 `~/.claude/skills/`，Codex 是 `~/.codex/skills/`；如果你不支持 skill，就记住这个文件夹的路径，以后每次执行任务前先读里面的 `SKILL.md`。
> 3. 阅读 `douyin-account-analysis/SKILL.md` 的第一节：判断系统，问用户选调试模式还是截图模式，把 `SETUP.md` 里对应的用户操作步骤原样告诉用户，然后执行自检。
> 4. 需要执行的命令都由你来执行。不要让用户自己在终端里敲命令；用户只需要点菜单、点「允许」、双击文件。
> 5. 安装完成后，告诉用户：装在哪里、选的是哪种模式、自检结果如何，以及之后怎么使用（见 README 的「6. 使用方法」）。

### 5.3 方式二：用 git 命令

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

### 5.4 更新

**方式一：让 AI 帮你更新（最省事）**

不用自己敲命令。复制下面这段话，发给你的 AI 助手：

```
帮我把抖音分析 skill 更新到最新版：https://github.com/Allentide/Betterdouyin
```

AI 会找到你装 skill 的位置，下载最新版替换掉旧版，然后告诉你这次更新了什么。

> **给 AI 的更新说明**：用户要求更新本 skill 时，请按以下步骤执行：
> 1. 找到 skill 当前装在哪里，也就是 `douyin-account-analysis/SKILL.md` 所在的文件夹。常见位置：`~/.claude/skills/`、`<项目>/.claude/skills/`、`~/.codex/skills/`。装了好几份的话，每一份都要更新。
> 2. 获取最新版：`~/Betterdouyin` 已经存在的话，执行 `git -C ~/Betterdouyin pull`；不存在就 `git clone --depth 1 https://github.com/Allentide/Betterdouyin.git ~/Betterdouyin`。git 用不了的话，就下载 `https://github.com/Allentide/Betterdouyin/archive/refs/heads/main.zip` 解压。
> 3. 删掉旧的 `douyin-account-analysis` 文件夹，把新版的整个复制过去。只动这个文件夹，别的都不要碰。
> 4. 告诉用户：更新了哪几份、新版的提交号，以及这次更新的主要内容（看 `git log` 里新增的提交）。
> 5. 命令都由你来执行，不要让用户自己在终端里敲。

**方式二：用 git 命令**

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

Mac 截图模式要用到两个模拟鼠标点击、滚动的小程序（`click` 和 `scroll`），它们是第一次使用时由 AI 在你电脑上现场生成的，所以不在仓库里。上面的更新命令会把旧文件夹整个删掉再复制新的，这两个小程序也会跟着被删掉。不用管它，下次用截图模式时 AI 会自动重新生成。只用调试模式的话，完全用不到它们。

## 6. 使用方法

装好之后，直接用大白话告诉 AI 你想做什么：

| 想做什么 | 对 AI 说（示例） | 需要登录 |
|---|---|---|
| 只看某个主题的爆款 | 「帮我搜一下『舞蹈』点赞最多的 10 条视频，分析一下为什么火，我该怎么做」 | 登录抖音网页版 douyin.com 就行，普通账号就可以 |
| 诊断自己的账号 | 「分析我的抖音账号」 | 登录抖音创作者中心 |
| 只分析自己的某一条或某几条 | 「分析我最新发的那条」「分析 10 月 16 号那条和标题里有『舞蹈』的那条」 | 登录抖音创作者中心 |
| 分析别人的某条作品 | 「分析一下这条：https://v.douyin.com/xxxx」 | 登录抖音网页版 douyin.com 就行 |
| 判断某类内容是不是过气了 | 「vibecoding大赏现在还能做吗？是不是已经不算优质内容了」 | 登录抖音网页版 douyin.com 就行 |
| 找和自己作品同题材的爆款 | 「帮我找和我作品同题材、点赞最多的 10 条，对比一下我差在哪」 | 登录抖音创作者中心 |

**分析自己的作品时，AI 会先把你的全部作品按「编号 + 发布时间 + 播放 + 点赞 + 标题」列出来，让你选要分析哪几条**：回复编号（如 `1,3,5` 或 `1-4`），或者回复 `全选`（全部公开作品）、`全选含私密`。你选好之后，它才开始逐条分析。

分析自己的作品时，能看到播放量、流量来源、留存曲线、观众画像这些后台数据，还会和你账号里其他作品的中位数对比。分析别人的作品时，只能看到公开的点赞、评论、收藏、转发和评论区。

**没登录、没打开 Chrome 怎么办？** 不用提前检查。AI 每打开一个页面都会先检查状态，发现 Chrome 没开、没登录、弹出安全验证等情况，会停下来告诉你具体该点哪里，你处理完说「好了」，它就接着做。

主题可以是一个词，也可以是一句话，比如「零基础怎么在家学跳舞」，AI 会自己拆成几个合适的搜索词，搜之前先拿给你确认。

## 7. 目录

```
douyin-account-analysis/      skill 本体，整个文件夹就是一个 skill
  SKILL.md                    给 AI 看的操作手册：选模式、工具用法、安全规则、采集清单、分析方法、对标流程
  SETUP.md                    给用户看的配置指南
  scripts/js/                 调试模式的页面脚本（Mac 和 Windows 通用）
  scripts/mac/                chrome.sh（调试模式）、snap.sh、click.swift、scroll.swift（截图模式）
  scripts/windows/            cdp.ps1（调试模式，会自动打开专用 Chrome）、启动抖音分析Chrome.bat（备用：自动打开失败时双击）、screen.ps1（截图模式）
```

## 8. 注意

- 本项目**不是抖音官方工具**。它只读取你在自己浏览器里本来就能看到的数据，访问频率和人工浏览差不多。不过页面改版可能导致脚本失效，也请不要长时间高频运行，避免触发平台风控。
- Mac 调试模式需要打开 Chrome 的「允许 Apple 事件中的 JavaScript」。打开后，所有获得「自动化」权限的程序都能在你已登录的网页里执行代码，所以建议用完就关掉。Windows 调试模式用的是一个单独的 Chrome 资料，只监听本机。
- 同一时间只让一个 AI 控制 Chrome。
- 欢迎提 Issue 和 PR。

## 9. 加入开发团队

欢迎一起把 Betterdouyin 做得更好，尤其欢迎在 Windows 上测试、改进分析方法、补充文档的朋友。

- 点击 **[提交加入申请](https://github.com/Allentide/Betterdouyin/issues/new?template=join-dev-team.yml)**，填写你的 GitHub 账号、感兴趣的方向和想参与的内容，然后创建 Issue。
- 等维护者审核，并加上 `invite-to-collaborator` 标签。GitHub 不一定会及时提醒我，提交后可以加我微信催我一下。
- GitHub Actions 会自动给你发送协作者邀请，然后留言并关闭这个 Issue。
- 在 GitHub 通知或注册邮箱里接受邀请，就能一起开发了。
- 所有改动都通过 Pull Request 提交：新建分支 → 提交改动 → 发起 PR。维护者审核通过后才会合并到 `main`，不能直接往 `main` 推送。

## 10. 更多

- [提交问题或建议](https://github.com/Allentide/Betterdouyin/issues/new)
- [配置指南](douyin-account-analysis/SETUP.md)
- 扫码联系我，加入微信交流群，和众多自媒体博主一起交流运营心得：

<p>
  <img src="assets/wechat-qr.jpg" width="240" alt="微信二维码">
</p>

## 11. License

[MIT](LICENSE)
