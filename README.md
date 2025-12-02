# Neovim 个人配置

这是一个专注于 Rust, Go 和 Lua 开发的 Neovim 个人配置，并提供了丰富的美化 UI 以及 Markdown 图片渲染支持。

## 📋 前置要求

在使用此配置之前，请确保您的系统满足以下要求：

### 核心组件
*   **Neovim:** 需要版本 **0.12.0+** 。
*   **Nerd Font:** 需要安装并配置 Nerd Font (如 JetBrainsMono Nerd Font, Hack Nerd Font) 以正确显示图标。
*   **C 编译器:** `gcc` 或 `clang` (编译 Treesitter 解析器时必须)。

### 工具与依赖
*   **Ripgrep (`rg`):** Telescope 的 `live_grep` (实时搜索) 功能需要此工具。
*   **fd:** (可选但强烈推荐) 用于 Telescope 加速文件查找并更好处理 `.gitignore`。
    *   **Arch Linux:** `sudo pacman -S fd`
    *   **Ubuntu/Debian:** `sudo apt install fd-find` (注意: 可能需要建个软链接 `ln -s $(which fdfind) ~/.local/bin/fd`)
    *   **MacOS:** `brew install fd`
*   **剪贴板工具:** Linux 下需要 `xclip` 或 `wl-copy`，macOS 自带 `pbcopy` (配置已启用 `unnamedplus` 以支持系统剪贴板)。

### LSP 语言服务器
如果您的 PATH 环境变量中包含以下服务器，此配置会自动启动它们：
*   **Rust:** `rust-analyzer`
*   **Go:** `gopls`
*   **Lua:** `lua-language-server`

### 🖼️ 图片支持 (重要事项)
本配置使用 [image.nvim](https://github.com/3rd/image.nvim) 在 Markdown 中直接渲染图片。

**1. 系统依赖库:**
您需要安装 ImageMagick 7.x (推荐) 或 6.x。
*   **Ubuntu/Debian:** `sudo apt install imagemagick libmagickwand-dev`
*   **MacOS:** `brew install imagemagick`
*   **Arch:** `sudo pacman -S imagemagick`

**2. Tmux 配置 (关键):**
如果您在 Tmux 中运行 Neovim，**必须**在您的 `~/.tmux.conf` 中开启视觉内容直通，否则会报错：
```tmux
set -g allow-passthrough on
```
*添加此行后，请运行 `tmux source ~/.tmux.conf` 并重启您的 Tmux 会话以使配置生效。*

**3. 终端支持:**
请使用支持图形协议的现代终端模拟器 (例如: **Kitty**, **WezTerm**, **Ghostty**, **iTerm2**, 或 **Konsole**)。

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
cp -r ~/.config/nvim ~/.config/moevim
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