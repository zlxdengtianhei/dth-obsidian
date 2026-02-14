# Obsidian 同步方案：Git + iCloud 混合模式

## 🎯 目标

实现：
- ✅ iCloud 自动同步到手机
- ✅ Git 版本控制
- ✅ 文件保存在 iCloud 目录（方便手机同步）
- ✅ 优雅的版本控制体验

## 📁 目录结构

```
iCloud Obsidian/
├── .git/                    # Git 仓库
├── .gitignore              # Git 忽略规则
├── agents/                 # Agent 相关研究
│   └── openclaw/
│       └── OpenClaw记忆系统与memsearch.md
├── 其他笔记...
└── OBSIDIAN_SYNC_GUIDE.md  # 本文档
```

## 🔄 工作流程

### 日常使用（手机 + 电脑）

1. **手机端**：
   - 直接在 Obsidian App 中编辑
   - iCloud 自动同步

2. **电脑端（Obsidian）**：
   - 直接在 Obsidian 中编辑
   - iCloud 自动同步变更

3. **版本控制（电脑端 Terminal）**：
   ```bash
   cd "/Users/lexuanzhang/Library/Mobile Documents/iCloud~md~obsidian/Documents"
   
   # 查看变更
   git status
   
   # 添加变更
   git add .
   
   # 提交（添加有意义的提交信息）
   git commit -m "feat: 添加 OpenClaw 记忆系统笔记"
   
   # 查看历史
   git log --oneline -10
   ```

### 团队协作（PR 评审）

```bash
# 创建分支
git checkout -b feature/new-agent-notes

# 提交变更
git add .
git commit -m "feat: 添加新的 Agent 文档"

# 推送到远程（如果配置了私有 Git）
git push origin feature/new-agent-agent-notes

# 创建 Pull Request
```

## 🛠️ 配置步骤

### 步骤 1：初始化 Git（已完成）

```bash
cd "/Users/lexuanzhang/Library/Mobile Documents/iCloud~md~obsidian/Documents"
git init
git add .
git commit -m "Initial commit"
```

### 步骤 2：配置远程仓库（可选）

如果需要私有 Git 仓库：

```bash
# 创建私有 GitHub/GitLab 仓库
# https://github.com/new（选择 Private）

# 添加远程仓库
git remote add origin https://github.com/你的用户名/obsidian-notes.git

# 推送
git push -u origin main
```

### 步骤 3：设置快捷命令

在你的 `~/.zshrc` 中添加：

```bash
# Obsidian 笔记快捷命令
alias obsidian-cd='cd "/Users/lexuanzhang/Library/Mobile Documents/iCloud~md~obsidian/Documents"'
alias obsidian-status='cd "/Users/lexuanzhang/Library/Mobile Documents/iCloud~md~obsidian/Documents" && git status'
alias obsidian-commit='cd "/Users/lexuanzhang/Library/Mobile Documents/iCloud~md~obsidian/Documents" && git add . && git commit'
alias obsidian-push='cd "/Users/lexuanzhang/Library/Mobile Documents/iCloud~md~obsidian/Documents" && git push'

# 使用
# obsidian-cd              # 进入目录
# obsidian-status          # 查看状态
# obsidian-commit "message" # 提交
# obsidian-push           # 推送到远程
```

### 步骤 4：配置 Git（推荐）

```bash
# 设置用户信息
git config user.name "你的名字"
git config user.email "你的邮箱"

# 设置默认分支名为 main
git config init.defaultBranch main

# 启用彩色输出
git config --global color.ui auto
```

## 📝 .gitignore 规则

已配置忽略：

```gitignore
# 图片和附件（iCloud 已同步）
*.png
*.jpg
*.jpeg
*.gif
*.mp3
*.mp4
*.pdf

# Obsidian 配置（个性化）
.obsidian/workspace.json
.obsidian/graph.json
.obsidian/cache/

# 系统文件
.DS_Store
Thumbs.db

# 保留 Markdown
!*.md
!agents/
```

## 💡 最佳实践

### 1. 提交时机

- **每日提交**：每天结束时提交当日笔记
- **功能提交**：添加新笔记后提交
- **批量提交**：避免频繁的小提交

### 2. 提交信息规范

```bash
# 好的提交信息
git commit -m "feat: 添加 OpenClaw 记忆系统研究笔记"
git commit -m "fix: 修正 Agent 分类错误"
git commit -m "docs: 更新同步方案文档"
git commit -m "chore: 更新 .gitignore 规则"
```

### 3. 分支策略

- `main`：稳定版本
- `feature/*`：新功能/新笔记
- `bugfix/*`：修复错误

### 4. 手机端使用

手机端无需配置 Git，直接使用 Obsidian 即可：
- ✅ iCloud 自动同步
- ✅ 无需 Git 操作
- ✅ 享受版本控制的好处（在电脑端）

## 🔒 安全考虑

### 敏感信息

如果笔记中包含敏感信息：
1. 使用 Obsidian 的密码保护功能
2. 或在 `.gitignore` 中忽略特定文件
3. 使用私有 Git 仓库

### 备份建议

```bash
# 定期推送远程仓库
git push origin main

# 或创建本地备份
git bundle create obsidian-backup.bundle --all
```

## 🎉 优点

| 特性 | iCloud | Git |
|------|---------|-----|
| 手机同步 | ✅ 自动 | ❌ 需手动 |
| 版本控制 | ❌ | ✅ 完整 |
| 协作 | ❌ | ✅ PR 评审 |
| 变更追溯 | ❌ | ✅ 完整历史 |
| 跨设备 | ✅ | 需推送 |

## 🚀 进阶使用

### 使用 GitHub Desktop

1. 下载 GitHub Desktop
2. 打开仓库：`/Users/lexuanzhang/Library/Mobile Documents/iCloud~md~obsidian/Documents`
3. 可视化提交和推送

### 使用 Obsidian Git 插件

1. 在 Obsidian 中安装 "Obsidian Git" 插件
2. 配置仓库路径
3. 自动提交和推送

## 📚 相关资源

- [Git 官方文档](https://git-scm.com/doc)
- [Obsidian 官方](https://obsidian.md)
- [GitHub Desktop](https://desktop.github.com)

## ✅ 总结

这套方案结合了：
- **iCloud** 的便捷同步（手机+电脑）
- **Git** 的版本控制（历史追溯+协作）
- **Markdown** 的跨平台兼容性

完美满足你的需求！🎯
