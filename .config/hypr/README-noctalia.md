# Hyprland + Noctalia 迁移说明

这套配置面向 **Hyprland 0.55+（Lua 配置）** 与 **Noctalia v5**。Hyprland
使用本目录下的 `hyprland.lua`；旧的 Waybar、Wofi、Mako、Hyprlock 与
`hyprland.conf` 配置已经清理。

## 文件

- `~/.config/hypr/hyprland.lua`：显示器、窗口规则、自启动和快捷键。
- `~/.config/noctalia/config.toml`：栏、主题、壁纸、通知、锁屏、截图和 OSD。

## 安装前检查

生成配置时，本机尚未安装 Hyprland、Noctalia 与
`xdg-desktop-portal-hyprland`。Arch Linux 上可以按需安装：

```sh
sudo pacman -S hyprland xdg-desktop-portal-hyprland
paru -S noctalia-git
```

你已有 PipeWire、WirePlumber、Fcitx5、CopyQ、brightnessctl、playerctl、
WezTerm、Alacritty、Dolphin 和 grim。Noctalia v5 自己提供截图、通知、锁屏、
壁纸、剪贴板与 polkit agent，因此不需要同时启动 Polybar、Picom、Variety、
XFCE notifyd、Hyprlock 或独立的通知守护进程。

## 首次启动

1. 从登录管理器选择 Hyprland 会话。
2. 进入桌面后执行 `hyprctl monitors`。
3. 当前配置根据正在使用的 i3/Polybar 脚本采用 `DP-1 + DP-2`：DP-1 为
   2560×1440，DP-2 在右侧。如果实际第二输出仍叫 `HDMI-1`，将
   `hyprland.lua` 中全部 `DP-2` 改为 `HDMI-1`，并同步修改
   `config.toml` 的 `[bar.main.monitor.secondary] match`。
4. 检查错误：`hyprctl configerrors`。
5. 检查 Noctalia：`noctalia status` 与 `noctalia config validate`。

配置支持热重载：`Super+Shift+C` 重载 Hyprland，`Super+Shift+R` 同时重载
Hyprland 和 Noctalia。

## 与 i3 对应的主要快捷键

| 快捷键 | 功能 |
| --- | --- |
| `Super+Return` / `Super+Shift+Return` | WezTerm / Alacritty |
| `Super+D` | Noctalia 启动器 |
| `Alt+Tab` | Noctalia 窗口切换器 |
| `Super+H/J/K/L` | Vim 风格切换焦点 |
| `Super+Shift+H/J/K/L` | 移动窗口 |
| `Super+1…0` | 工作区 1…10 |
| `Super+Shift+1…0` | 移动窗口并跟随到工作区 |
| `Super+R` | resize 模式；用 H/J/K/L 调整，Esc 退出 |
| `Super+Shift+G` | gaps 模式；I/O 增大，Shift+I/O 减小，0 清零，R 重置 |
| `Super+W` / `Super+S` | 建立/解除标签组；切到组内下一窗口 |
| `Super+Z` / `Super+Shift+Z` | 显示 scratchpad / 移入 scratchpad |
| `Alt+Ctrl+A` / `Print` | 区域截图 / 选择显示器截图 |
| `Super+X` | 会话菜单 |
| `Super+Ctrl+L` | 锁屏 |

注意：Hyprland 的 group 是 i3 tabbed 容器最接近的对应物；dwindle 没有完全
等价的 stacking 容器。`Super+;` 和 `Super+V` 分别预选下一个窗口的水平、
垂直分割方向。

## 可选调整

- 当前网络速率沿用 Polybar 的有线接口 `enp2s0`。若接口名变化，执行
  `ip link`，修改 Noctalia 中 `net-down` 和 `net-up` 的 `interface`；也可留空
  以统计所有非 loopback 接口。
- 外接显示器亮度通常需要 `ddcutil`。确认 `ddcutil detect` 正常后，把
  `[brightness] enable_ddcutil` 改为 `true`。
- Noctalia 图形设置产生的覆盖项位于
  `~/.local/state/noctalia/settings.toml`，其优先级高于当前 `config.toml`。
