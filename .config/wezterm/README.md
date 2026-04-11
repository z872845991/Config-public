# WezTerm 配置说明

这是一套偏重 Linux/Wayland、SSH、工作区、多窗格和类 tmux 操作习惯的 WezTerm 配置。主入口只有 `wezterm.lua`，其余 Lua 文件都是被主配置加载的模块。

## 目录结构

| 文件 | 作用 |
| --- | --- |
| `wezterm.lua` | 主配置入口，定义字体、主题、渲染后端、窗口行为、超链接规则，并合并本地私有配置。 |
| `keybinds.lua` | 所有键盘和鼠标绑定，包括默认快捷键、tmux 风格快捷键、复制模式和搜索模式的键表。 |
| `on.lua` | 事件处理器，负责标签页标题、右侧状态栏、提示铃标记、切换 tmux 风格按键、把滚动回溯交给 Neovim 等行为。 |
| `utils.lua` | 若干工具函数，主要用于合并表、路径处理和 URL 拆分。 |
| `colors/nordfox.toml` | 自定义颜色方案，名字叫 `nordfox`。 |

## 加载关系

1. WezTerm 启动时读取 `wezterm.lua`。
2. `wezterm.lua` 会加载 `utils.lua`、`keybinds.lua`，并通过 `require("on")` 注册所有事件。
3. 主配置会尝试额外读取 `~/.local/share/wezterm/local.lua`，用于存放不想公开的私有配置。
4. 最终返回值会依次合并：
   - 主配置 `config`
   - 私有配置 `local_config`
   - 从 `~/.ssh/config` 自动推导出的 `ssh_domains`

## 外部依赖和隐含约定

- 字体依赖：当前默认字体是 `UDEV Gothic 35NFLG`。如果系统里没有这个字体，WezTerm 会退回其他可用字体。
- 配色依赖：`color_scheme = "nordfox"`，而 `colors/nordfox.toml` 通过 `color_scheme_dirs` 暴露给 WezTerm。
- 本地私有配置依赖：如果存在 `~/.local/share/wezterm/local.lua`，其中的内容会覆盖同名主配置项。
- SSH 依赖：`create_ssh_domain_from_ssh_config()` 会读取 `~/.ssh/config` 里的主机配置并自动生成 WezTerm 的 SSH 域，同时透传 `IdentityFile` 等认证选项给 WezTerm。
- 远程环境变量依赖：文件头注释提到远程 `/etc/ssh/sshd_config` 需要允许以下变量传递，否则某些集成功能可能失效：
  - `TERM_PROGRAM_VERSION`
  - `COLORTERM`
  - `TERM`
  - `TERM_PROGRAM`
  - `WEZTERM_REMOTE_PANE`
- 外部编辑器依赖：`trigger-nvim-with-scrollback` 事件会优先使用 `VISUAL`/`EDITOR`，否则回退到可用的 `nvim`/`vim` 打开回溯内容。
- Shell 集成依赖：`copy_last_command_output()` 依赖 shell integration 提供的 `Output` 语义区段，并通过 `WEZTERM_PROG` user var 缓存最近一次执行的命令；`user_vars.panetitle`、`user_vars.production`、`hacky-user-command` 也都依赖外部程序给 pane 注入用户变量。
- 临时提示实现：自定义提示不再使用系统桌面通知，而是用 WezTerm 左侧状态栏显示 2 秒后自动清除，避免桌面环境忽略通知超时。

---

## `wezterm.lua`

### 文件级变量和模块

- `local wezterm = require("wezterm")`
  - 导入 WezTerm API。
- `local utils = require("utils")`
  - 导入工具函数模块。
- `local keybinds = require("keybinds")`
  - 导入快捷键配置模块。
- `local scheme = wezterm.get_builtin_color_schemes()["nord"]`
  - 取内置 `nord` 配色，主要用于标签栏颜色计算；注意这和最终窗口主题 `nordfox` 不是同一个来源。
- `local gpus = wezterm.gui.enumerate_gpus()`
  - 枚举本机 GPU，用于后面指定首选 WebGPU 适配器。
- `require("on")`
  - 只为了执行副作用：注册所有 `wezterm.on(...)` 事件处理器。

### 辅助函数

- `enable_wayland()`
  - 读取 `XDG_SESSION_TYPE`。
  - 如果值是 `wayland`，返回 `true`；否则返回 `false`。
  - 当前实际没有使用这个函数，因为下面直接把 `enable_wayland = true` 写死了。

- `create_ssh_domain_from_ssh_config(ssh_domains)`
  - 作用：把 `wezterm.enumerate_ssh_hosts()` 返回的 SSH 主机定义转成 WezTerm 的 `ssh_domains` 数组。
  - 入参：
    - `ssh_domains`：已有的 SSH 域列表；如果为 `nil`，先初始化为空表。
  - 每个自动生成条目的字段：
    - `name = host`
      - 域名，直接使用 SSH Host 名。
    - `remote_address = config.hostname .. ":" .. config.port`
      - 远程地址，拼接成 `主机名:端口`。
    - `username = config.user`
      - 登录用户。
    - `multiplexing = "None"`
      - 禁用 WezTerm 自带的 SSH 复用。
    - `assume_shell = "Posix"`
      - 告诉 WezTerm 远程 shell 按 POSIX shell 处理。
    - `ssh_option = { ... }`
      - 如果 SSH 配置里定义了 `identityfile`、`identityagent`、`userknownhostsfile`、`identitiesonly`、`proxycommand`、`bindaddress`，也会一并带过去，避免命令行 `ssh` 能登录、WezTerm 内置 SSH 不能登录。
  - 返回值：
    - `{ ssh_domains = ssh_domains }`
      - 方便后面直接和其他配置表合并。

- `load_local_config(module)`
  - 作用：从 `~/.local/share/wezterm/` 动态加载一个 Lua 文件。
  - 实现细节：
    - 先把 `~/.local/share/wezterm/?.lua` 加到 `package.path` 前面。
    - `package.searchpath()` 找不到模块时返回空表 `{}`。
    - 找到后用 `dofile()` 直接执行并返回内容。

### 私有配置约定

- `local local_config = load_local_config("local")`
  - 会尝试读取 `~/.local/share/wezterm/local.lua`。
  - 这个文件不在当前目录里，但这个配置把它当成正式扩展点。
  - 注释里给了一个示例，说明你可以在里面写自己的 `ssh_domains` 或其他不想公开的设置。

### 主配置 `config`

下面按主题说明 `config` 中每个已启用选项。

#### 字体和文本渲染

- `font = wezterm.font("UDEV Gothic 35NFLG")`
  - 主字体。
- `font_size = 8.5`
  - 字号。
- `warn_about_missing_glyphs = false`
  - 缺字时不弹警告。
- ``selection_word_boundary = " \t\n{}[]()\"'`,;:│=&!%"``
  - 定义双击选词时的分隔符集合，遇到这些字符会切词。

#### 输入法和键盘输入

- `use_ime = true`
  - 启用输入法支持。
- `send_composed_key_when_left_alt_is_pressed = false`
  - 左 Alt 不发送组合后的字符。
- `send_composed_key_when_right_alt_is_pressed = false`
  - 右 Alt 不发送组合后的字符。
- `ime_preedit_rendering = "Builtin"`
  - 使用 WezTerm 内建方式显示输入法预编辑文本。
- `use_dead_keys = false`
  - 禁用 dead key 组合键机制，减少和终端快捷键冲突。
- `enable_csi_u_key_encoding = true`
  - 启用 CSI-u 键编码，让 `<Tab>` 和 `<Ctrl-i>` 这类按键能区分。
- `leader = { key = "Space", mods = "CTRL|SHIFT" }`
  - 定义 Leader 键为 `Ctrl+Shift+Space`。
  - 当前这个配置里没有继续使用 `LEADER` 绑定，所以它更像是预留项。

#### 更新、动画和光标

- `check_for_updates = false`
  - 不自动检查更新。
- `max_fps = 30`
  - 最大刷新率限制为 30 FPS。
- `animation_fps = 1`
  - 动画刷新率非常低，尽量减少动态效果。
- `cursor_blink_ease_in = "Constant"`
  - 光标闪烁进入动画使用常量速度。
- `cursor_blink_ease_out = "Constant"`
  - 光标闪烁退出动画使用常量速度。
- `cursor_blink_rate = 0`
  - 关闭光标闪烁。

#### 显示协议和图形后端

- `enable_wayland = true`
  - 强制启用 Wayland 支持。
  - 注释里提到过 WezTerm 的 Wayland 相关 issue，说明作者是带着兼容性背景保留了这个设置。
- `webgpu_preferred_adapter = gpus[1]`
  - 使用 GPU 列表中的第一个适配器作为 WebGPU 首选设备。
  - 注意：这依赖枚举顺序，跨机器不一定稳定。
- `prefer_egl = true`
  - 图形栈优先走 EGL。
- `front_end = "WebGpu"`
  - 使用 WebGPU 渲染前端。

#### 主题、标签页和窗口外观

- `color_scheme = "nordfox"`
  - 使用 `colors/nordfox.toml` 提供的主题。
- `color_scheme_dirs = { os.getenv("HOME") .. "/.config/wezterm/colors/" }`
  - 指定自定义主题目录。
- `hide_tab_bar_if_only_one_tab = false`
  - 即使只有一个标签页，也显示标签栏。
- `use_fancy_tab_bar = false`
  - 使用简洁标签栏，而不是 WezTerm fancy tab bar。
- `tab_max_width = 32`
  - 单个标签最大宽度为 32 个单元。
- `tab_bar_at_bottom = false`
  - 标签栏放在顶部。
- `adjust_window_size_when_changing_font_size = false`
  - 调整字号时不改变窗口外框尺寸。
- `window_padding = { left = 0, right = 0, top = 0, bottom = 0 }`
  - 窗口四周不留内边距。
- `colors = { tab_bar = { ... } }`
  - 这里只覆盖标签栏的局部配色：
    - `tab_bar.background = scheme.background`
      - 标签栏底色取自内置 `nord` 的背景色。
    - `tab_bar.new_tab.bg_color = "#2e3440"`
      - “新建标签”按钮背景色。
    - `tab_bar.new_tab.fg_color = scheme.ansi[8]`
      - “新建标签”按钮前景色。
    - `tab_bar.new_tab.intensity = "Bold"`
      - “新建标签”按钮文字加粗。
    - `tab_bar.new_tab_hover.bg_color = scheme.ansi[1]`
      - 鼠标悬停时按钮背景色。
    - `tab_bar.new_tab_hover.fg_color = scheme.brights[8]`
      - 鼠标悬停时按钮前景色。
    - `tab_bar.new_tab_hover.intensity = "Bold"`
      - 鼠标悬停时文字加粗。
- `inactive_pane_hsb = { saturation = 0.7, brightness = 0.7 }`
  - 非活动 pane 降低饱和度和亮度，用来突出当前 pane。

#### 通知、退出和关闭行为

- `notification_handling = "SuppressFromFocusedTab"`
  - 来自当前焦点标签页的通知会被压制，不重复提醒。
- `exit_behavior = "CloseOnCleanExit"`
  - 进程正常退出时关闭对应 pane/标签。
- `window_close_confirmation = "AlwaysPrompt"`
  - 关闭窗口前总是确认。

#### 键盘和鼠标绑定入口

- `disable_default_key_bindings = true`
  - 完全关闭 WezTerm 默认快捷键，只保留当前配置里显式定义的绑定。
- `keys = keybinds.create_keybinds()`
  - 主快捷键集合，等于“默认快捷键 + tmux 风格快捷键”的合并结果。
- `key_tables = keybinds.key_tables`
  - 额外挂载 `resize_pane`、`copy_mode`、`search_mode` 三套键表。
- `mouse_bindings = keybinds.mouse_bindings`
  - 挂载自定义鼠标行为。

### 超链接规则 `hyperlink_rules`

- `\\((\\w+://\\S+)\\)` -> `$1`
  - 识别被圆括号包裹的 URL，如 `(https://example.com)`。
- `\\[(\\w+://\\S+)\\]` -> `$1`
  - 识别被中括号包裹的 URL。
- `\\{(\\w+://\\S+)\\}` -> `$1`
  - 识别被花括号包裹的 URL。
- `<(\\w+://\\S+)>` -> `$1`
  - 识别被尖括号包裹的 URL。
- `[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)` -> `$1`
  - 识别没有被括号包裹的普通 URL，并避免把开头的左括号一起匹配进去。
- `\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b` -> `mailto:$0`
  - 自动识别邮箱地址并转成 `mailto:` 链接。
- `["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?` -> `https://github.com/$1/$3`
  - 识别类似 `owner/repo` 的文本并链接到 GitHub 仓库首页。

### 最终返回逻辑

- `local merged_config = utils.merge_tables(config, local_config)`
  - 先把私有配置覆盖到主配置上。
- `return utils.merge_tables(merged_config, create_ssh_domain_from_ssh_config(merged_config.ssh_domains))`
  - 再把自动生成的 `ssh_domains` 合并进去。
  - 如果 `local.lua` 里已经定义了 `ssh_domains`，会和 `~/.ssh/config` 生成的结果合并。

### 当前被注释掉的备选项

这些内容当前不生效，但能说明作者当初考虑过什么：

- `font = wezterm.font("Cica")`
  - 旧的备选字体。
- `font_size = 10.0`
  - 旧字号。
- `cell_width = 1.1`
  - 字符单元宽度微调。
- `line_height = 1.1`
  - 行高微调。
- `font_rules = { ... }`
  - 针对 italic / bold italic 的单独字体规则。
- `enable_kitty_graphics = false`
  - 是否关闭 kitty graphics 协议。
- `enable_wayland = enable_wayland()`
  - 原本想按环境变量自动判断是否启用 Wayland。
- `enable_wayland = false`
  - 另一套保守的兼容性备选。
- `colors.tab_bar.active_tab / inactive_tab / inactive_tab_hover`
  - 预留过手工定义标签状态色，但现在改成在 `on.lua` 里动态格式化。
- `visual_bell = { ... }`
  - 视觉铃效果配置。
- `window_background_opacity = 0.8`
  - 全局窗口透明度示例。
- 下方 Vulkan 适配器检测循环
  - 原本打算优先选集成显卡 Vulkan/WebGPU 设备，目前整段关闭。

---

## `keybinds.lua`

这个文件导出 5 个对外成员：

- `tmux_keybinds`
  - 一组类 tmux 操作习惯的快捷键。
- `default_keybinds`
  - 基础快捷键。
- `create_keybinds()`
  - 把上面两组按顺序拼接后返回。
- `key_tables`
  - 模式化键表，包括 `resize_pane`、`copy_mode`、`search_mode`。
- `mouse_bindings`
  - 鼠标行为。

### 辅助函数 `copy_last_command_output(window, pane)`

作用：复制“上一条命令及其输出”到系统剪贴板和 Primary Selection。

执行步骤：

1. 如果当前 pane 处于 alternate screen，则直接提示不可用并返回。
2. 读取 pane 里的全部语义区段，倒序查找最后一个 `Output` 区段。
3. 提取最后一个 `Output` 区段的文本；如果没有找到，或者文本为空，则提示并返回。
4. 从这个 `Output` 区段向前回溯，查找紧邻的非空 `Input` 区段；如果在遇到更早的 `Prompt`/`Output` 前没有找到，就认为当前语义区段缺失了输入部分。
5. 如果 `Input` 区段缺失，则优先回退到当前 `WEZTERM_PROG` user var，再回退到 `user-var-changed` 事件缓存的最近一次非空命令。
6. 如果拿到了命令文本，则按“`=` 分隔线 + 命令 + `=` 分隔线 + 输出”拼接后复制。
7. 调用 `window:copy_to_clipboard(..., "ClipboardAndPrimarySelection")`。
8. 在左侧状态栏显示 `Copied!`，2 秒后自动消失。

这依赖 shell integration 至少能正确标记 `Output` zone；如果 `Input` zone 丢失，但 `WEZTERM_PROG` 可用，仍然可以复制“命令 + 输出”。

### `tmux_keybinds`

- `Alt+t`
  - `SpawnTab = "CurrentPaneDomain"`，在当前 pane 所在域新建标签页。
- `Alt+w`
  - 关闭当前标签页，带确认。
- `Alt+H`
  - 切到左边标签页。
- `Alt+L`
  - 切到右边标签页。
- `Ctrl+Alt+H`
  - 当前标签左移一位。
- `Ctrl+Alt+L`
  - 当前标签右移一位。
- `Ctrl+Alt+K`
  - 清空选区并进入复制模式。
- `Ctrl+Alt+J`
  - 从 Primary Selection 粘贴。
- `Alt+1` 到 `Alt+9`
  - 跳转到第 1 到第 9 个标签页。
- `Alt+-`
  - `SplitVertical`，把当前 pane 左右分栏。
- `Alt+\`
  - `SplitHorizontal`，把当前 pane 上下分栏。
- `Shift+Alt+H`
  - 焦点移到左侧 pane。
- `Shift+Alt+L`
  - 焦点移到右侧 pane。
- `Shift+Alt+K`
  - 焦点移到上方 pane。
- `Shift+Alt+J`
  - 焦点移到下方 pane。
- `Ctrl+Shift+Alt+H`
  - pane 向左缩放 1 个单元。
- `Ctrl+Shift+Alt+L`
  - pane 向右缩放 1 个单元。
- `Ctrl+Shift+Alt+K`
  - pane 向上缩放 1 个单元。
- `Ctrl+Shift+Alt+J`
  - pane 向下缩放 1 个单元。
- `Alt+Enter`
  - 打开 `QuickSelect`。
- `Shift+Enter`
  - 发送原始换行字符 `\n`。
- `Alt+/`
  - 以“当前选中文本，否则空字符串”为初始关键字启动搜索。

### `default_keybinds`

- `Ctrl+Shift+C`
  - 复制到系统剪贴板。
- `Ctrl+Shift+V`
  - 从系统剪贴板粘贴。
- `Shift+Insert`
  - 从 Primary Selection 粘贴。
- `Ctrl+=`
  - 重置字号。
- `Ctrl+Shift++`
  - 放大字号。
- `Ctrl+-`
  - 缩小字号。
- `Shift+Up`
  - 跳到上一个 prompt。
- `Shift+Down`
  - 跳到下一个 prompt。
- `Alt+PageUp`
  - 向上翻一页。
- `Alt+PageDown`
  - 向下翻一页。
- `Alt+B`
  - 向上翻一页，`PageUp` 的字母别名。
- `Alt+F`
  - 向下翻一页，`PageDown` 的字母别名。
- `Alt+Z`
  - 重新加载 WezTerm 配置。
- `Shift+Alt+T`
  - 触发 `toggle-tmux-keybinds` 事件，切换 tmux 风格按键是否启用。
- `Alt+E`
  - 触发 `trigger-nvim-with-scrollback`，把滚动回溯送到新标签页里的 Neovim。
- `Alt+Q`
  - 关闭当前 pane，带确认。
- `Alt+X`
  - 与 `Alt+Q` 相同，也是关闭 pane。
- `Alt+A`
  - 打开 WezTerm Launcher。
- `Alt+Space`
  - 打开标签导航器。
- `Shift+Alt+D`
  - 打开调试面板。
- `Alt+.`
  - 先上滚 1 行，再进入复制模式，并清掉当前选区；相当于一个“暂停浏览”入口。
- `Alt+R`
  - 进入 `resize_pane` 键表。
  - 该键表：
    - `one_shot = false`：不会执行一次就自动退出。
    - `timeout_milliseconds = 3000`：3 秒无输入后退出。
    - `replace_current = false`：不替换已有键表堆栈。
- `Alt+S`
  - 进入 pane 选择模式，提示字符集为 `1234567890`。
- Alt+反引号键
  - pane 逆时针轮换。
- Shift+Alt+反引号键
  - pane 顺时针轮换。
- `Alt+'`
  - `PaneSelect(mode = "SwapWithActiveKeepFocus")`
  - 选择一个 pane 与当前 pane 交换位置，但保持当前焦点。
- `Shift+Alt+E`
  - 弹出输入框重命名当前标签页。
  - `description = "Enter new name for tab"` 是提示文本。
  - `action_callback` 会在用户输入非 `nil` 时调用 `set_title(line)`。
- `Shift+Alt+Z`
  - 如果当前标签页里有多个 pane，就切换 zoom 状态；单 pane 时不做事。
- `Alt+0`
  - 打开 Workspace Launcher，并启用 `FUZZY|WORKSPACES` 标志。
- `Alt+N`
  - 切到下一个工作区。
- `Alt+P`
  - 切到上一个工作区。
- `Ctrl+Shift+Alt+C`
  - 调用 `copy_last_command_output()`，复制上一条命令及其输出。

### `create_keybinds()`

- `return utils.merge_lists(M.default_keybinds, M.tmux_keybinds)`
  - 只是简单拼接，不做去重。
  - 所以前后顺序就是默认绑定在前，tmux 风格绑定在后。

### `key_tables.resize_pane`

- `LeftArrow` / `H`
  - 当前 pane 向左调整大小 1 格。
- `RightArrow` / `L`
  - 当前 pane 向右调整大小 1 格。
- `UpArrow` / `K`
  - 当前 pane 向上调整大小 1 格。
- `DownArrow` / `J`
  - 当前 pane 向下调整大小 1 格。
- `Escape`
  - 退出该键表。

### `key_tables.copy_mode`

#### 退出和清理

- `Escape`
  - 清空选区、清空搜索模式残留的 pattern，并退出复制模式。
- `Q`
  - 直接关闭复制模式。
- `Enter`
  - 清掉当前选择模式，但不退出复制模式。

#### 光标移动

- `H` / `LeftArrow`
  - 左移一个字符。
- `J` / `DownArrow`
  - 下移一行。
- `K` / `UpArrow`
  - 上移一行。
- `L` / `RightArrow`
  - 右移一个字符。

#### 单词级移动

- `Alt+RightArrow` / `Alt+F` / `Tab` / `W`
  - 向前移动一个单词。
- `Alt+LeftArrow` / `Alt+B` / `Shift+Tab` / `B`
  - 向后移动一个单词。
- `E`
  - 先右移一格，再前进到下一个单词，再回退一格。
  - 这个组合动作的效果接近 Vim 里的“到单词结尾”。

#### 行首行尾移动

- `0`
  - 移到行首。
- `Ctrl+A`
  - 移到当前行的实际内容起点。
- `Alt+M`
  - 移到当前行的实际内容起点。
- `^`
  - 移到当前行的实际内容起点。
- `Enter`
  - 移到下一行行首。
- `$`
  - 移到当前行内容末尾。
- `Ctrl+E`
  - 移到当前行内容末尾。

#### 选择

- `Space`
  - 把当前位置附近的单词选中并立即复制。
  - 内部做法是：前进一个词、回退到词首、进入选择、移到词尾，再延时 50ms 后复制并关闭复制模式。
- `V`
  - 进入单元格级选择模式。
- `Shift+V`
  - 选中整行内容。

#### 复制

- `Y`
  - 复制当前选区到系统剪贴板和 Primary Selection，然后退出复制模式。
- `Shift+Y`
  - 从当前位置开始选到行尾，复制到系统剪贴板和 Primary Selection，然后退出复制模式。

#### 滚动和视口跳转

- `G`
  - 跳到滚动回溯底部。
- `g`
  - 跳到滚动回溯顶部。
- `H`
  - 跳到当前视口顶部。
- `M`
  - 跳到当前视口中间。
- `L`
  - 跳到当前视口底部。
- `O`
  - 跳到选区另一端。
- `Shift+O`
  - 水平方向跳到选区另一端。
- `PageUp`
  - 上翻一页。
- `PageDown`
  - 下翻一页。
- `Ctrl+B`
  - 上翻一页。
- `Ctrl+F`
  - 下翻一页。

#### 搜索

- `/`
  - 用当前选区或空串启动搜索。
- `N`
  - 跳到下一个匹配项，并清理当前选择模式。
- `Shift+N`
  - 跳到上一个匹配项，并清理当前选择模式。

### `key_tables.search_mode`

- `Escape`
  - 关闭搜索/复制模式。
- `Enter`
  - 清掉当前选择模式并重新进入复制模式。
- `Ctrl+P`
  - 跳到上一个匹配。
- `Ctrl+N`
  - 跳到下一个匹配。
- `Ctrl+R`
  - 在不同匹配类型之间切换。
- `/`
  - 清空当前搜索 pattern。
- `Ctrl+U`
  - 清空当前搜索 pattern。

### `mouse_bindings`

- `左键抬起`
  - 完成选择，并把内容写入 Primary Selection。
- `右键抬起`
  - 完成选择，并把内容写入系统剪贴板。
- `Ctrl+左键抬起`
  - 打开鼠标下方的链接。

文件里还保留了两段被注释掉的中键行为：

- 中键抬起时从 Primary Selection 粘贴。
- 中键按下时禁用默认行为。

---

## `on.lua`

这个文件不返回模块，而是通过 `wezterm.on(...)` 直接注册事件。

### 文件级状态和导入

- `local scheme = wezterm.get_builtin_color_schemes()["nord"]`
  - 和 `wezterm.lua` 一样，这里使用内置 `nord` 的配色来绘制标签栏部件。
- `local act = wezterm.action`
  - 方便后续简写动作。
- `local bell_tabs = {}`
  - 记录哪些标签页触发过 bell，但还没被用户切回去查看。

### 辅助函数

- `find_mux_tab(tab_id)`
  - 在所有 GUI 窗口和所有 mux tab 中查找指定 `tab_id` 对应的对象。
  - 主要用于在格式化标签标题时拿到“其他 pane 的标题”。

- `create_tab_title(tab, tabs, panes, config, hover, max_width)`
  - 负责生成标签标题的文本片段数组。
  - 具体规则：
    - 如果 `tab.active_pane.user_vars.panetitle` 存在且非空，优先显示 `序号:panetitle`。
    - 否则从 `active_pane.title` 提取标题。
    - 如果标题长得像 `Copy mode: ...`，会把模式前缀提炼出来放到前面。
    - 如果 pane 标题格式是 `app:content`，则 `app:` 部分会加粗。
    - 如果当前 tab 有多个 pane，会额外把另一个 pane 的标题以斜体、半亮度形式拼到右边，中间用 `|` 分隔。

- `update_window_background(window, pane)`
  - 读取当前窗口的 config override。
  - 如果 override 里没有 `color_scheme`，就直接返回。
  - 如果当前 pane 的 `user_vars.production == "1"`，把 override 主题改成 `OneHalfDark`。
  - 最终调用 `window:set_config_overrides(overrides)` 应用覆盖。
  - 这意味着“生产环境 pane”会被换成不同主题，用视觉方式提醒。

- `update_tmux_style_tab(window, pane)`
  - 当前没有被实际调用。
  - 作用原本是从工作目录 URL 里拆出主机名，并以下划线和斜体格式显示。

- `update_ssh_status(window, pane)`
  - 取 `pane:get_domain_name()`。
  - 如果域名是 `local`，就不显示。
  - 否则在右侧状态栏显示 `域名 `。

- `display_ime_on_right_status(window, pane)`
  - 当前没有被实际调用。
  - 如果窗口处于输入法组合态，就在右侧状态栏显示 `COMPOSING: ...`。

- `display_copy_mode(window, pane)`
  - 如果当前有活动键表，就显示 `Mode: 键表名`。
  - 否则显示空串。

- `display_tmux_mode(window)`
  - 通过检查 `window_background_opacity` 是否存在，推断 tmux 风格按键当前是否关闭。
  - 当 opacity 被设置时，返回 ` tmux-keybind:OFF `；否则不显示任何提示。

- `display_zoom_mode(window, pane)`
  - 如果当前 pane 正处于 zoom 状态，就显示 `Mode: Zoom`。

### 事件：`format-tab-title`

作用：自定义标签页标题外观。

执行逻辑：

1. 如果当前 tab 正处于活动状态，就清掉它在 `bell_tabs` 里的提醒标记。
2. 如果这个 tab 曾触发 bell，则在标题前加 `● `。
3. 调用 `create_tab_title(...)` 生成主体文字。
4. 用左右两个半块字符：
   - `solid_left_arrow = utf8.char(0x2590)`
   - `solid_right_arrow = utf8.char(0x258c)`
   拼出类似“箭头标签”的边缘效果。
5. 颜色规则：
   - 默认背景 `scheme.ansi[1]`，前景 `scheme.ansi[5]`
   - 活动 tab：背景 `scheme.brights[1]`，前景 `scheme.brights[8]`
   - hover tab：背景 `scheme.cursor_bg`，前景 `scheme.cursor_fg`
   - 边缘底色固定为 `#2e3440`
6. 返回格式化片段数组给 WezTerm。

### 事件：`update-right-status`

作用：实时刷新右侧状态栏。

拼接顺序：

1. SSH 域名状态。
2. 当前键表模式，比如 `Mode: copy_mode`。
3. tmux 风格按键是否关闭。
4. 当前 pane 是否 zoom。
5. 当前 workspace 名字；如果工作区不是 `default`，就显示 ` workspace_name `。

同时还会调用 `update_window_background(window, pane)`，根据 `production` 用户变量决定是否切换主题。

### 事件：`toggle-tmux-keybinds`

作用：在“完整快捷键”和“只保留 default_keybinds”之间切换。

切换规则：

- 如果当前没有 `window_background_opacity` override：
  - 设置 `window_background_opacity = 0.85`
  - 设置 `overrides.keys = keybinds.default_keybinds`
  - 结果：tmux 风格快捷键被关闭，同时窗口微透明，作为视觉提示。
- 否则：
  - 把 `window_background_opacity` 清空
  - 把 `overrides.keys` 恢复为 `default_keybinds + tmux_keybinds`
  - 结果：tmux 风格快捷键重新启用。

### 事件：`trigger-nvim-with-scrollback`

作用：把当前 pane 的滚动回溯内容送进一个新的 Neovim 标签页里。

步骤：

1. `pane:get_lines_as_text()` 取回溯文本。
2. `os.tmpname()` 生成临时文件名。
3. 写入临时文件。
4. 在新标签页执行：
   - 优先 `VISUAL` / `EDITOR`
   - 否则尝试 `~/.local/share/zsh/zinit/polaris/bin/nvim`
   - 再回退到 `nvim` / `vim`
5. 等待 1 秒。
6. 删除临时文件。

注意：

- 如果 `VISUAL` / `EDITOR` 和 `nvim` / `vim` 都不可用，会弹出提示而不是直接 `ENOENT`。
- 删除临时文件依赖 Neovim 已经及时打开文件。

### `hacky_user_commands` 和 `user-var-changed`

`hacky_user_commands` 里定义了两个“通过用户变量远程控制 WezTerm”的动作：

- `scroll-up`
  - 向上翻一页。
- `scroll-down`
  - 向下翻一页。

`wezterm.on("user-var-changed", ...)` 的规则：

- 只关心变量名 `hacky-user-command`。
- 变量值会被当成 JSON 解析。
- 再根据 `cmd_context.cmd` 去调用 `hacky_user_commands[...]` 对应函数。

这通常用于 shell、编辑器或远程程序主动控制终端界面。

### 事件：`bell`

作用：当某个 pane 触发终端铃声时，给它所在的 tab 打标记。

流程：

1. 取触发铃声的 `pane_id`。
2. 遍历当前窗口里所有 tab 和 pane。
3. 找到对应 pane 后，把 `bell_tabs[mux_tab:tab_id()] = true`。
4. 之后 `format-tab-title` 会在对应标签页前显示 `● `。
5. 用户切回该标签页时，标记会被清掉。

### 本文件涉及的用户变量

- `panetitle`
  - 自定义标签名，优先级高于 pane 自带标题。
- `production`
  - 值为 `"1"` 时，把当前窗口 override 的主题切换到 `OneHalfDark`。
- `hacky-user-command`
  - JSON 格式命令入口，当前支持 `scroll-up` 和 `scroll-down`。

---

## `utils.lua`

这是一个纯工具模块，返回表 `M`。

- `basename(s)`
  - 从路径中取最后一级文件名或目录名。
  - 兼容 `/` 和 `\` 两种分隔符。

- `merge_tables(t1, t2)`
  - 递归合并两个表。
  - 如果 `t1[k]` 和 `t2[k]` 都是表，就继续递归。
  - 否则直接让 `t2[k]` 覆盖 `t1[k]`。
  - 注意：这个函数会原地修改 `t1`。

- `merge_lists(t1, t2)`
  - 把两个数组按顺序拼接到一个新表里并返回。
  - 不做去重。

- `exists(tab, element)`
  - 递归检查一个值是否存在于表中。
  - 当前这套配置里没有实际用到，但保留在工具库里。

- `convert_home_dir(path)`
  - 把路径前缀里的 `$HOME/` 替换成 `~/`。
  - 如果替换后结果为空串，就返回原路径。

- `convert_useful_path(dir)`
  - 先执行 `convert_home_dir()`，再取 basename。
  - 也就是把长路径压缩成更短、更适合显示的名字。

- `split_from_url(dir)`
  - 把类似 `file://hostname/path` 的 URI 拆成：
    - `hostname`
    - `cwd`
  - 处理细节：
    - 先去掉前缀 `file://`
    - 取第一个 `/` 之前的部分作为主机名
    - 如果主机名包含域名后缀，只保留第一个点前面的主机短名
    - 余下路径取 basename 作为目录名
  - 返回值：`hostname, cwd`

---

## `colors/nordfox.toml`

这个文件定义了名为 `nordfox` 的主题。

### 顶部注释

- `# Nightfox Wezterm Colors`
  - 说明这是 Nightfox 项目的 WezTerm 颜色文件。
- `# Style: nordfox`
  - 说明具体变体是 `nordfox`。
- `# Upstream: ...`
  - 标注了上游来源 URL。

### `[colors]`

- `foreground = "#b9bfca"`
  - 默认前景色。
- `background = "#2e3440"`
  - 默认背景色。
- `cursor_bg = "#b9bfca"`
  - 光标背景色。
- `cursor_border = "#b9bfca"`
  - 光标边框色。
- `cursor_fg = "#2e3440"`
  - 光标内部文字颜色。
- `selection_bg = "#3e4655"`
  - 选区背景色。
- `selection_fg = "#b9bfca"`
  - 选区前景色。
- `ansi = [...]`
  - 标准 8 色调色板，依次对应终端基础色位。
- `brights = [...]`
  - 高亮版 8 色调色板。
- `compose_cursor = "#f0d399"`
  - 输入法组合态光标颜色。

### `[metadata]`

- `name = 'nordfox'`
  - 主题名称，必须和 `color_scheme = "nordfox"` 对应。
- `origin_url = 'https://github.com/edeneast/nightfox.nvim/raw/main/extra/nordfox/nightfox_wezterm.toml'`
  - 记录主题来源。

---

## 建议补一个本地私有文件：`~/.local/share/wezterm/local.lua`

这个目录没有带上私有配置，但从主配置逻辑看，作者预期你自己维护一个本地文件。最小示例：

```lua
return {
  default_prog = { "/usr/bin/zsh", "-l" },
  ssh_domains = {
    {
      name = "my.server",
      remote_address = "192.168.8.31:22",
      username = "your-user",
    },
  },
}
```

这个文件里的字段会覆盖主配置同名项；如果你自己还写了 `ssh_domains`，最终会和 `~/.ssh/config` 自动生成的列表合并。

## 一句话总结

这套配置的核心思路是：

- 用 `wezterm.lua` 管全局外观和运行时选项；
- 用 `keybinds.lua` 接管全部键鼠行为；
- 用 `on.lua` 把标签页、状态栏、bell、scrollback、工作区和“生产环境提醒”做成事件驱动；
- 用 `local.lua` 和 `~/.ssh/config` 承担本地机器差异。
