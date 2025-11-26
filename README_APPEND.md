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
