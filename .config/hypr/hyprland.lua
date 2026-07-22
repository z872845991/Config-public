-- Hyprland 0.55+ configuration, migrated from ~/.config/i3/config.
-- Noctalia v5 owns the bar, launcher, wallpaper, notifications, OSD and lock screen.

local mainMod = "SUPER"
local terminal = "wezterm"
local opaqueTerminal = "alacritty"
local browser = "env LANGUAGE=zh_CN google-chrome-stable"
local fileManager = "dolphin"
local noctalia = "noctalia msg "

-- ---------------------------------------------------------------------------
-- Outputs
-- ---------------------------------------------------------------------------
-- The i3 monitor script and Polybar launcher use DP-1 + DP-2. DP-1 is the
-- 2560x1440 primary display and DP-2 is placed to its right. If `hyprctl
-- monitors` reports a different second connector, change DP-2 here and in the
-- workspace rules below. The final catch-all keeps an unexpected output usable.
hl.monitor({ output = "DP-1", mode = "2560x1440", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "preferred", position = "2560x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Keep the same 1-5 / 6-10 monitor split as i3 and keep empty workspaces
-- visible in Noctalia.
for workspace = 1, 10 do
  hl.workspace_rule({
    workspace = tostring(workspace),
    monitor = workspace <= 5 and "DP-1" or "DP-2",
    persistent = true,
  })
end

-- ---------------------------------------------------------------------------
-- Environment
-- ---------------------------------------------------------------------------
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Preserve the existing Fcitx5 environment for native Wayland and XWayland
-- applications.
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "fcitx")

-- ---------------------------------------------------------------------------
-- Session startup
-- ---------------------------------------------------------------------------
hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")
  hl.exec_cmd("noctalia")
  hl.exec_cmd("fcitx5 -d")
  hl.exec_cmd("copyq")
end)

-- ---------------------------------------------------------------------------
-- Input and behavior
-- ---------------------------------------------------------------------------
hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "",
    kb_rules = "",
    follow_mouse = 1,
    numlock_by_default = true,
    sensitivity = 0,
    touchpad = {
      natural_scroll = true,
      tap_to_click = true,
      drag_lock = 1,
      disable_while_typing = true,
    },
  },
  cursor = {
    inactive_timeout = 3,
  },
  binds = {
    workspace_back_and_forth = true,
    allow_workspace_cycles = true,
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
  },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- ---------------------------------------------------------------------------
-- Appearance: i3's compact gaps/borders with the existing Hyprland effects
-- ---------------------------------------------------------------------------
hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 3,
    border_size = 3,
    col = {
      active_border = "rgb(FF5577)",
      inactive_border = "rgba(44475AAA)",
    },
    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
  },
  decoration = {
    rounding = 8,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 0.95,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = 0xee1a1a1a,
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 2,
      vibrancy = 0.1696,
    },
  },
  animations = {
    enabled = true,
  },
  dwindle = {
    preserve_split = true,
    use_active_for_splits = true,
  },
})

hl.curve("snappy", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
hl.animation({ leaf = "global", enabled = true, speed = 6, bezier = "snappy" })
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "snappy", style = "popin 90%" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "snappy" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "snappy", style = "slide" })

-- Noctalia already animates its own surfaces; Hyprland only supplies blur.
hl.layer_rule({
  name = "noctalia",
  match = {
    namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
  },
  no_anim = true,
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true,
})

-- ---------------------------------------------------------------------------
-- Window rules migrated from i3
-- ---------------------------------------------------------------------------
hl.window_rule({
  name = "copyq",
  match = { class = "^(copyq|com.github.hluk.copyq)$" },
  float = true,
  size = { 700, 450 },
  center = true,
})

hl.window_rule({
  name = "noctalia-settings",
  match = { class = "^dev.noctalia.Noctalia$" },
  float = true,
  size = { 1080, 920 },
  center = true,
})

hl.window_rule({
  name = "modal-dialogs",
  match = { modal = true },
  float = true,
  center = true,
})

hl.window_rule({
  name = "small-utilities",
  match = { class = "^(org.pulseaudio.pavucontrol|nm-connection-editor|galculator|org.gnome.FontViewer|Gpick)$" },
  float = true,
  center = true,
})

hl.window_rule({
  name = "file-operation-dialogs",
  match = { title = "^(Copying|Deleting|Moving).*$" },
  float = true,
  center = true,
})

-- Chromium and some XWayland applications request maximize on startup; keep
-- tiling behavior consistent with i3.
hl.window_rule({
  name = "suppress-maximize",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- ---------------------------------------------------------------------------
-- Application and shell keybindings
-- ---------------------------------------------------------------------------
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal), { description = "Open WezTerm" })
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(opaqueTerminal), { description = "Open Alacritty" })
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(browser), { description = "Open Chrome" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(fileManager), { description = "Open Dolphin" })

hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(noctalia .. "panel-toggle launcher"), { description = "Application launcher" })
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(noctalia .. "panel-toggle launcher /win"), { description = "Window search" })
hl.bind("ALT + SHIFT + D", hl.dsp.exec_cmd(noctalia .. "panel-toggle launcher"), { description = "Application launcher" })
hl.bind("ALT + Tab", hl.dsp.exec_cmd(noctalia .. "window-switcher"), { description = "Window switcher" })
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(noctalia .. "settings-toggle"), { description = "Noctalia settings" })
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(noctalia .. "panel-toggle session"), { description = "Session menu" })
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(noctalia .. "panel-toggle session"), { description = "Session menu" })
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("xfce4-settings-manager"), { description = "XFCE settings" })
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd(noctalia .. "session lock"), { description = "Lock session" })

-- Keep the i3 screenshot chord, but use Noctalia's native Wayland capture.
hl.bind("ALT + CTRL + A", hl.dsp.exec_cmd(noctalia .. "screenshot-region"), { description = "Region screenshot" })
hl.bind("Print", hl.dsp.exec_cmd(noctalia .. "screenshot-fullscreen pick"), { description = "Screenshot a display" })

-- ---------------------------------------------------------------------------
-- Window management
-- ---------------------------------------------------------------------------
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close(), { description = "Close window" })
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

-- i3 split h/v becomes a one-shot direction for the next opened window.
hl.bind(mainMod .. " + semicolon", hl.dsp.layout("preselect r"), { description = "Next window splits horizontally" })
hl.bind(mainMod .. " + V", hl.dsp.layout("preselect d"), { description = "Next window splits vertically" })
hl.bind(mainMod .. " + E", hl.dsp.layout("togglesplit"), { description = "Toggle current split" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))

-- Hyprland groups are the closest equivalent to i3's tabbed container.
hl.bind(mainMod .. " + W", hl.dsp.group.toggle(), { description = "Toggle tabbed group" })
hl.bind(mainMod .. " + S", hl.dsp.group.next(), { description = "Next tab in group" })
hl.bind(mainMod .. " + A", hl.dsp.layout("movetoroot active"), { description = "Promote window in layout tree" })

-- Scratchpad / special workspace.
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind(mainMod .. " + Z", hl.dsp.workspace.toggle_special("scratchpad"))

-- Mouse move/resize and workspace scrolling.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- ---------------------------------------------------------------------------
-- Workspaces
-- ---------------------------------------------------------------------------
for workspace = 1, 10 do
  local key = workspace % 10
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace, follow = true }))
end

hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))

-- ---------------------------------------------------------------------------
-- Resize and gap modes
-- ---------------------------------------------------------------------------
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"), { description = "Resize mode" })
hl.define_submap("resize", function()
  hl.bind("H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
  hl.bind("J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
  hl.bind("K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
  hl.bind("L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
  hl.bind("Return", hl.dsp.submap("reset"))
  hl.bind("Escape", hl.dsp.submap("reset"))
  hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
end)

local gapsIn = 3
local gapsOut = 3
local function applyGaps()
  hl.config({ general = { gaps_in = gapsIn, gaps_out = gapsOut } })
end

hl.bind(mainMod .. " + SHIFT + G", hl.dsp.submap("gaps"), { description = "Gap mode" })
hl.define_submap("gaps", function()
  hl.bind("I", function() gapsIn = gapsIn + 2; applyGaps() end, { repeating = true })
  hl.bind("SHIFT + I", function() gapsIn = math.max(0, gapsIn - 2); applyGaps() end, { repeating = true })
  hl.bind("O", function() gapsOut = gapsOut + 2; applyGaps() end, { repeating = true })
  hl.bind("SHIFT + O", function() gapsOut = math.max(0, gapsOut - 2); applyGaps() end, { repeating = true })
  hl.bind("0", function() gapsIn = 0; gapsOut = 0; applyGaps() end)
  hl.bind("R", function() gapsIn = 3; gapsOut = 3; applyGaps() end)
  hl.bind("Return", hl.dsp.submap("reset"))
  hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- ---------------------------------------------------------------------------
-- Media and hardware keys (Noctalia also shows the matching OSD)
-- ---------------------------------------------------------------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctalia .. "volume-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctalia .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(noctalia .. "volume-mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(noctalia .. "mic-mute"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(noctalia .. "brightness-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctalia .. "brightness-down"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })

-- Reload both sides without restarting the session.
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland" })
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload; noctalia msg config-reload"), { description = "Reload desktop config" })
