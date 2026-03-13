.pragma library

// 这个文件偏“内容配置”：文字、图片、快捷卡片、问候语都放这里。
// 适合你后面自己改；一般不建议自动主题生成器去动这个文件。

// 头像图片路径。留空会显示默认占位图。
// 支持绝对路径，也支持相对路径；相对路径会按 `modules/Theme/profileMenuConfig.js` 的位置解析。
var profileImagePath = "../../assets/1.webp"

// 头像菜单顶部的大标题。
var displayName = "cyrene"

// 标题下方的小状态行。
// `statusIcon` 适合放一个简短图标，`statusText` 放一句状态 / uptime / 心情都行。
var statusIcon = "󰍹 "
var statusText = "Hello, World!"

// 头部右上角动作按钮。
// 支持两种方式：
// 1. `section`: 打开内置子菜单（wifi / sound / bluetooth / notifications / power）
// 2. `command`: 直接执行 shell 命令
var headerActions = [
  { key: "power", icon: "⏻", section: "power" }
]

// 主快捷卡片。
// 当前界面主要渲染 `icon` 和 `title`；`subtitle` 先保留给以后扩展。
var quickTiles = [
  { key: "wifi", icon: "󰖩", title: "Wi-Fi", subtitle: "Open networks", section: "wifi" },
  { key: "audio", icon: "󰂯", title: "Audio", subtitle: "Open device page", section: "bluetooth" },
  { key: "record", icon: "󰻃", title: "Screen record", subtitle: "Launch recorder", command: "command -v wf-recorder >/dev/null 2>&1 && (mkdir -p \"$HOME/Videos/Recordings\"; wf-recorder -f \"$HOME/Videos/Recordings/record-$(date +%F-%H%M%S).mp4\" >/dev/null 2>&1 &) || true" },
  { key: "dnd", icon: "󰂛", title: "Do not disturb", subtitle: "Silence popups", command: "" }
]

// 底部亮度默认值。
// 只有在真实亮度服务暂时拿不到数据时，才会退回显示这里的值。
var brightnessPercent = 32

// 底部问候卡文案。
// `greetingTitle` 留空时，会按当前时间自动显示 morning / afternoon / evening。
var greetingTitle = ""
var greetingMessage = "Take a breath, tune your setup, and enjoy the rest of the day."

// 问候卡中央图片路径。留空时会显示一个简单的占位图案。
// 同样支持相对路径，会按当前这个配置文件所在目录解析。
var greetingImagePath = "../../assets/banner.png"
var greetingPatternText = "✦"
