# 三宝订阅聚合系统

> 基于 Cloudflare Workers 的智能订阅聚合与节点管理系统，专为海外回国养号场景优化

## ✨ 核心特性

- 🔄 **智能聚合** - 多订阅源自动合并，支持 vless/vmess/trojan/ss 协议
- 🛡️ **稳定优先** - 600秒测速间隔，固定IP不频繁切换，避免风控
- 🚫 **自动断网** - 国内节点全挂自动 REJECT，防止海外IP触发风控
- 🏙️ **城市分组** - 北京/上海/广州/深圳/成都精细化分组
- 🔍 **健康检查** - 每3天自动检测，连续6天失败自动清理
- 📱 **TG通知** - 节点变化、健康报告实时推送
- 🎨 **Cyberpunk UI** - 赛博朋克风格管理界面，支持二维码
- 🔐 **防配置覆盖** - GitHub托管配置，不被机场订阅覆盖

## 🎯 使用场景

适用于海外账号回国维护，需要稳定国内IP避免频繁切换的场景

## 📦 部署状态

-
- **健康检查**: 每3天 08:00 (香港时间)

## 🏗️ 技术架构

- **运行环境**: Cloudflare Workers
- **存储**: KV Namespace (主节点 + 访客)
- **定时任务**: Cron Triggers (0 0 */3 * *)
- **配置管理**: GitHub托管 clash_config_optimized.ini
- **通知系统**: Telegram Bot API

## 📝 配置亮点

### Failover策略
```ini
🔄 回国专线 → 北京 → 上海 → 广州 → 深圳 → 成都 → REJECT
```
当所有国内节点失败时自动断网，避免切换到海外节点

### 节点清理规则
- ✅ 节点正常 → 保留
- ⚠️ 首次失败 → 标记待观察(保留)
- 🗑️ 自动删除

## 🚀 快速开始

1. 访问管理页面添加订阅链接
2. 将订阅地址导入 Clash/Surge 客户端
3. 选择 `🔄 策略组使用

## 📊 监控指标

系统每3天发送健康报告:
- ✅ 健康节点数量
- ⚠️ 待观察节点(首次失败)
- 🗑️ 已清理节点(连续失败)

## 🔧 维护

配置文件: `clash_config_optimized.ini` (85行纯净代码)
- 无注释干扰
- GitHub版本控制
- 防止订阅覆盖

---

---

README.md
v2
## Repository hygiene

为减小仓库体积并提高可维护性，本仓库已移除 tracked 的 node_modules 目录；依赖请用以下命令在本地安装：

```bash
npm install
```
—— 要删除的文件

workflow-run-19689324672.log （如果存在，请删除并提交）
—— 在本地执行的完整命令（推荐流程）

从 main 拉取并创建分支
```bash
git checkout main
git pull origin main
git checkout -b chore/cleanup-nodemodules-and-ci
```
停止跟踪 node_modules（如果已被跟踪）并删除意外日志文件
```bash
# 检查 node_modules 是否被跟踪
git ls-files node_modules | head -n 5

# 停止跟踪（如果存在）
git rm -r --cached node_modules || true

# 删除工作流日志（如果存在）
git rm workflow-run-19689324672.log || true
```
在仓库根目录创建/更新文件（将上面提供的文件内容保存到对应路径）

新建 .gitignore
新建 .github/workflows/basic-checks.yml
新建 README.dirs.md
在 README.md 末尾追加上面的 Repository hygiene 段落
在 public/, src/, telegram-bot/, tests/, workspace/, .github/ 下分别添加空的 .gitkeep 文件
添加并提交更改（建议一次性提交）
```bash
git add .gitignore .github/workflows/basic-checks.yml README.dirs.md public/.gitkeep src/.gitkeep telegram-bot/.gitkeep tests/.gitkeep workspace/.gitkeep .github/.gitkeep README.md
git commit -m "chore: remove node_modules and add .gitignore, placeholders and basic CI"
```
推送分支并创建 PR（两种方式：gh CLI 或 GitHub 网页）
使用 gh CLI（若已安装）
```bash
git push origin chore/cleanup-nodemodules-and-ci
gh pr create --title "chore: remove node_modules, add .gitignore, placeholders, and basic CI" --body "背景：清理 node_modules 跟踪、删除意外日志、添加 .gitignore、占位文件和基础 CI。此 PR 不重写历史，仅停止跟踪 node_modules 并添加忽略规则。" --base main
```
使用 GitHub 网站：推送后在仓库页面创建 PR，分支选择 chore/cleanup-nodemodules-and-ci，填写同样的标题与描述。
—— 如果你希望我代为执行并打开 PR

我需要你在 GitHub 页面上通过弹窗/授权允许写入权限（在你点击确认授权后我会继续并立即推送与打开 PR）。目前我在本对话中还无法直接写入仓库，所以请完成授权，然后回复“我已授权，请创建 PR”，我就会开始代为推送并回报 PR URL 与进度。（若你已在之前的界面授权，请也回复确认，我会继续。）
—— 冲突与失败处理

如果在创建分支或合并时出现冲突：我建议先手动 rebase/merge 并解决冲突，流程如下：
```bash
git fetch origin
git rebase origin/main
# 解决冲突后
git add <冲突已解决的文件>
git rebase --continue
git push origin chore/cleanup-nodemodules-and-ci --force-with-lease
```
我在代为创建 PR 时，如果遇到自动合并冲突或无法推送，我会中止操作并把冲突文件清单和错误信息原文返回给你以便手动处理。
—— 额外建议（可选）

若仓库历史中大量提交已包含 node_modules 且你希望彻底从历史删除，请在确认后再使用 BFG 或 git filter-repo（这会重写历史，所有协作者需重新克隆）。
运行 gitleaks/trufflehog 等工具扫描敏感信息（如果担心秘钥泄漏）。
需要我现在代为创建 PR 吗？

如果“是”，请先在 GitHub UI 授权写入权限，然后回复“我已授权，请创建 PR”。
如果你更愿意自己执行，请按照上面命令操作；过程中遇到任何问题贴错误输出给我，我会继续协助解决。

---

README.md
v2
## Repository hygiene

为减小仓库体积并提高可维护性，本仓库已移除 tracked 的 node_modules 目录；依赖请用以下命令在本地安装：

```bash
npm install
```
—— 要删除的文件

workflow-run-19689324672.log （如果存在，请删除并提交）
—— 在本地执行的完整命令（推荐流程）

从 main 拉取并创建分支
```bash
git checkout main
git pull origin main
git checkout -b chore/cleanup-nodemodules-and-ci
```
停止跟踪 node_modules（如果已被跟踪）并删除意外日志文件
```bash
# 检查 node_modules 是否被跟踪
git ls-files node_modules | head -n 5

# 停止跟踪（如果存在）
git rm -r --cached node_modules || true

# 删除工作流日志（如果存在）
git rm workflow-run-19689324672.log || true
```
在仓库根目录创建/更新文件（将上面提供的文件内容保存到对应路径）

新建 .gitignore
新建 .github/workflows/basic-checks.yml
新建 README.dirs.md
在 README.md 末尾追加上面的 Repository hygiene 段落
在 public/, src/, telegram-bot/, tests/, workspace/, .github/ 下分别添加空的 .gitkeep 文件
添加并提交更改（建议一次性提交）
```bash
git add .gitignore .github/workflows/basic-checks.yml README.dirs.md public/.gitkeep src/.gitkeep telegram-bot/.gitkeep tests/.gitkeep workspace/.gitkeep .github/.gitkeep README.md
git commit -m "chore: remove node_modules and add .gitignore, placeholders and basic CI"
```
推送分支并创建 PR（两种方式：gh CLI 或 GitHub 网页）
使用 gh CLI（若已安装）
```bash
git push origin chore/cleanup-nodemodules-and-ci
gh pr create --title "chore: remove node_modules, add .gitignore, placeholders, and basic CI" --body "背景：清理 node_modules 跟踪、删除意外日志、添加 .gitignore、占位文件和基础 CI。此 PR 不重写历史，仅停止跟踪 node_modules 并添加忽略规则。" --base main
```
使用 GitHub 网站：推送后在仓库页面创建 PR，分支选择 chore/cleanup-nodemodules-and-ci，填写同样的标题与描述。
—— 如果你希望我代为执行并打开 PR

我需要你在 GitHub 页面上通过弹窗/授权允许写入权限（在你点击确认授权后我会继续并立即推送与打开 PR）。目前我在本对话中还无法直接写入仓库，所以请完成授权，然后回复“我已授权，请创建 PR”，我就会开始代为推送并回报 PR URL 与进度。（若你已在之前的界面授权，请也回复确认，我会继续。）
—— 冲突与失败处理

如果在创建分支或合并时出现冲突：我建议先手动 rebase/merge 并解决冲突，流程如下：
```bash
git fetch origin
git rebase origin/main
# 解决冲突后
git add <冲突已解决的文件>
git rebase --continue
git push origin chore/cleanup-nodemodules-and-ci --force-with-lease
```
我在代为创建 PR 时，如果遇到自动合并冲突或无法推送，我会中止操作并把冲突文件清单和错误信息原文返回给你以便手动处理。
—— 额外建议（可选）

若仓库历史中大量提交已包含 node_modules 且你希望彻底从历史删除，请在确认后再使用 BFG 或 git filter-repo（这会重写历史，所有协作者需重新克隆）。
运行 gitleaks/trufflehog 等工具扫描敏感信息（如果担心秘钥泄漏）。
需要我现在代为创建 PR 吗？

如果“是”，请先在 GitHub UI 授权写入权限，然后回复“我已授权，请创建 PR”。
如果你更愿意自己执行，请按照上面命令操作；过程中遇到任何问题贴错误输出给我，我会继续协助解决。
