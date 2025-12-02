# Neovim 个人配置

这是一个专注于 Rust, Go 和 Lua 开发的 Neovim 个人配置，并提供了丰富的美化 UI 以及 Markdown 图片渲染支持。

## 📋 前置要求

在使用此配置之前，请确保您的系统满足以下要求。建议使用包管理器一次性安装所有依赖。

### 💻 依赖安装指南 (以 Arch Linux 为例)

运行以下命令以安装所有核心组件、语言服务器 (Go, Rust, Lua)、搜索工具以及图片渲染所需的库：

```bash
# 1. 安装核心依赖、LSP 和图像处理库
sudo pacman -Sy git gcc go rustup lua-language-server fd ripgrep imagemagick luarocks

# 2. 安装 Lua 图片处理绑定 (用于 image.nvim)
# 注意: Neovim 使用 LuaJIT (兼容 Lua 5.1)，必须指定版本
sudo luarocks --lua-version=5.1 install magick
```

### 📦 依赖详情说明

*   **核心:** `neovim` (v0.12+), `git`, `gcc` (编译 Treesitter 需要)。
*   **LSP:** `rust-analyzer` (Rust), `gopls` (Go), `lua-language-server` (Lua)。
*   **搜索:** `ripgrep` (内容搜索), `fd` (文件查找)。
*   **图片:** `imagemagick` + `magick` (Lua rock) 用于在 Markdown 中渲染图片。

### ⚠️ 重要配置事项

**1. 字体:**
请安装并配置 **Nerd Font** (如 `ttf-jetbrains-mono-nerd`) 以正确显示图标。

**2. Tmux 用户:**
如果您在 Tmux 中运行 Neovim，**必须**在 `~/.tmux.conf` 中开启视觉内容直通，否则图片无法显示：
```tmux
set -g allow-passthrough on
```
*添加此行后，请运行 `tmux source ~/.tmux.conf` 并重启您的 Tmux 会话以使配置生效。*

**3. 终端模拟器:**
建议使用支持图形协议的现代终端 (如 **Kitty**, **WezTerm**, **Ghostty**, **Konsole**) 以获得最佳图片预览体验。

## 🛠️ 安装步骤

**1. 备份现有配置:**
```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

**2. 克隆仓库:**
```bash
git clone https://github.com/moexco/nvim ~/.config/nvim
```

**3. 启动 Neovim:**
```bash
nvim
```
*注意：首次启动时，插件管理器会自动下载所有插件。如果您看到 Markdown 渲染相关的报错，请尝试手动运行命令 `:TSInstall markdown markdown_inline`。*

## 🎭 多配置/独立实例 (可选)

您可以通过设置环境变量 `NVIM_APPNAME` 来创建独立的 Neovim 实例（例如 `moevim`），使其拥有完全独立的配置和插件目录，而不干扰默认的 `nvim` 配置。

**1. 创建别名:**
在您的 shell 配置文件（如 `.bashrc` 或 `.zshrc`）中添加：
```bash
alias moevim="NVIM_APPNAME=moevim nvim"
```

**2. 配置目录:**
该实例将读取 `~/.config/moevim` 下的配置，数据存储在 `~/.local/share/moevim`。
您可以将现有的 nvim 配置复制过去作为起点：
```bash
git clone https://github.com/moexco/nvim ~/.config/moevim
```

**注意:** 首次启动 `moevim` 时，它会像全新安装一样重新下载所有插件。如果遇到插件下载不完整导致报错（如 `module 'luasnip' not found`），可以使用内置的插件管理修复功能（快捷键 `<leader>p`）或手动清除 `~/.local/share/moevim` 目录。


## ⌨️ 常用快捷键概览
*   **Leader 键:** `<Space>` (空格键)
*   **LSP (语言服务):**
    *   `gd`: 跳转到定义 (Go to Definition)
    *   `gr`: 查找引用 (Find References)
    *   `<leader>lf`: 格式化代码
    *   `<leader>li`: 查看 LSP 客户端信息
*   **Telescope (模糊搜索):**
    *   `<leader>ff`: 查找文件
    *   `<leader>fw`: 全局搜索内容 (Live Grep)
*   **文件资源管理器:**
    *   `<leader>e`: 切换 NvimTree 显示/隐藏
