.pragma library

// 这是给 matugen 用的模板文件。
// 目标输出文件：`modules/Theme/colors.js`
// 语法按当前系统里的 matugen 模板格式写，支持 `{{colors.*}}` 与 `hex_stripped`。
//
// 建议：
// 1. 把真正自动生成的目标锁定为 `modules/Theme/colors.js`
// 2. 只让 matugen 覆盖颜色；尺寸与圆角仍然保留在 `theme.js`
// 3. 这份模板默认按深色模式组织，如果你后面要 light，也可以再复制一份改映射

var palette = {
  // 主背景 / 表面层级。
  bg: "{{colors.background.default.hex}}",
  surface: "#d8{{colors.surface_container_low.default.hex_stripped}}",
  surfaceStrong: "#b5{{colors.surface_container.default.hex_stripped}}",
  surfaceRaised: "#d4{{colors.surface_container_high.default.hex_stripped}}",

  // 通用边框。
  border: "#00000000",
  borderSoft: "#35{{colors.outline_variant.default.hex_stripped}}",

  // 文本。
  textPrimary: "{{colors.on_surface.default.hex}}",
  textMuted: "{{colors.on_surface_variant.default.hex}}",

  // 强调 / 状态。
  accent: "{{colors.primary_container.default.hex}}",
  accentStrong: "{{colors.primary.default.hex}}",
  accentText: "{{colors.on_primary_container.default.hex}}",
  info: "{{colors.secondary.default.hex}}",
  danger: "{{colors.error.default.hex}}",

  // workspace / 选择态。
  workspaceOccupied: "#8a{{colors.secondary_container.default.hex_stripped}}",
  workspaceActive: "{{colors.primary_container.default.hex}}",
  workspaceEmpty: "#00000000",

  // 顶栏主体 / 背景叠层。
  barShellOverlay: "#04{{colors.on_surface.default.hex_stripped}}",

  // 顶栏：左侧头像 / 状态环。
  barAvatarShell: "#0a{{colors.on_surface.default.hex_stripped}}",
  barAvatarShellHover: "#12{{colors.on_surface.default.hex_stripped}}",
  barAvatarBorder: "#1f{{colors.on_surface.default.hex_stripped}}",
  barStatusCenterBg: "#0a{{colors.on_surface.default.hex_stripped}}",
  barStatusCenterActiveBg: "#14{{colors.on_surface.default.hex_stripped}}",
  barStatusRingTrack: "#1a{{colors.on_surface.default.hex_stripped}}",

  // 顶栏：workspace 条。
  barWorkspaceStripBg: "#0d{{colors.on_surface.default.hex_stripped}}",
  barWorkspaceStripBorder: "#14{{colors.on_surface.default.hex_stripped}}",
  barWorkspaceStripOverlay: "#05{{colors.on_surface.default.hex_stripped}}",
  barWorkspaceDotHover: "#61{{colors.on_surface.default.hex_stripped}}",
  barWorkspaceDotOccupied: "#3d{{colors.on_surface.default.hex_stripped}}",
  barWorkspaceDotEmpty: "#1f{{colors.on_surface.default.hex_stripped}}",

  // 顶栏：右侧控制区 / 小按钮 / 分隔线。
  barControlShellBorder: "#14{{colors.on_surface.default.hex_stripped}}",
  barControlShellOverlay: "#05{{colors.on_surface.default.hex_stripped}}",
  barControlButtonActiveBg: "#14{{colors.on_surface.default.hex_stripped}}",
  barControlButtonHoverBg: "#0a{{colors.on_surface.default.hex_stripped}}",
  barControlButtonBorder: "#14{{colors.on_surface.default.hex_stripped}}",
  barMediaIconBorder: "#47{{colors.on_surface.default.hex_stripped}}",
  barDivider: "#1a{{colors.on_surface.default.hex_stripped}}",
  barVolumePillBorder: "#1f{{colors.on_surface.default.hex_stripped}}",
  barTrayButtonHoverBg: "#0d{{colors.on_surface.default.hex_stripped}}",
  barTrayButtonBorder: "#1f{{colors.on_surface.default.hex_stripped}}",

  // 控制中心整体外壳 / 导航。
  controlHubInnerOverlay: "#04{{colors.on_surface.default.hex_stripped}}",
  controlHubNavBorder: "#0f{{colors.on_surface.default.hex_stripped}}",
  controlHubNavItemBorder: "#14{{colors.on_surface.default.hex_stripped}}",

  // 通知 toast。
  notificationToastBg: "#f5{{colors.surface_container.default.hex_stripped}}",
  notificationToastBorder: "#14{{colors.on_surface.default.hex_stripped}}",
  notificationToastInnerOverlay: "#05{{colors.on_surface.default.hex_stripped}}",
  notificationToastIconBg: "#09{{colors.on_surface.default.hex_stripped}}",
  notificationToastIconBorder: "#0f{{colors.on_surface.default.hex_stripped}}",

  // 头像弹出卡片：整体外壳。
  profileMenuBg: "#fb{{colors.surface_container.default.hex_stripped}}",
  profileMenuBorder: "#12{{colors.on_surface.default.hex_stripped}}",
  profileMenuInnerOverlay: "#04{{colors.on_surface.default.hex_stripped}}",

  // 头像弹出卡片：头部区域。
  profileHeaderAvatarShell: "#09{{colors.on_surface.default.hex_stripped}}",
  profileHeaderAvatarInner: "#08{{colors.on_surface.default.hex_stripped}}",
  profileClockBg: "#12{{colors.on_surface.default.hex_stripped}}",
  profileClockBorder: "#0d{{colors.on_surface.default.hex_stripped}}",
  profileActionBg: "#12{{colors.on_surface.default.hex_stripped}}",
  profileActionHoverBg: "#1c{{colors.on_surface.default.hex_stripped}}",
  profileActionBorder: "#0d{{colors.on_surface.default.hex_stripped}}",

  // 头像弹出卡片：快捷操作 / 分隔线 / 滑块底轨。
  profileTileBg: "#11{{colors.on_surface.default.hex_stripped}}",
  profileTileBorder: "#0d{{colors.on_surface.default.hex_stripped}}",
  profileTileAccentBorder: "#1f{{colors.primary_container.default.hex_stripped}}",
  profileTileBadgeBg: "#0d{{colors.on_surface.default.hex_stripped}}",
  profileTileAccentBadgeBg: "#24{{colors.primary_container.default.hex_stripped}}",
  profileDivider: "{{colors.on_surface.default.hex}}",
  profileSliderTrack: "#eb{{colors.secondary_container.default.hex_stripped}}",

  // 头像弹出卡片：问候卡。
  profileGreetingBg: "#0d{{colors.on_surface.default.hex_stripped}}",
  profileGreetingBorder: "#0f{{colors.on_surface.default.hex_stripped}}",
  profileGreetingInner: "#05{{colors.on_surface.default.hex_stripped}}",
  profileGreetingArtworkBg: "#0b{{colors.on_surface.default.hex_stripped}}",
  profileGreetingArtworkBorder: "#0d{{colors.on_surface.default.hex_stripped}}",

  // Wi‑Fi 菜单。
  wifiToggleBorder: "#14{{colors.on_surface.default.hex_stripped}}",
  wifiCardBg: "#0e{{colors.on_surface.default.hex_stripped}}",
  wifiCardBorder: "#0d{{colors.on_surface.default.hex_stripped}}",
  wifiSummaryIconActiveBg: "#24{{colors.secondary_container.default.hex_stripped}}",
  wifiSummaryIconInactiveBg: "#0d{{colors.on_surface.default.hex_stripped}}",
  wifiActionBg: "#0d{{colors.on_surface.default.hex_stripped}}",
  wifiActionBorder: "#0d{{colors.on_surface.default.hex_stripped}}",
  wifiStatusInfoBg: "#1f{{colors.secondary_container.default.hex_stripped}}",
  wifiStatusInfoBorder: "#2e{{colors.secondary.default.hex_stripped}}",
  wifiStatusErrorBg: "#1f{{colors.error_container.default.hex_stripped}}",
  wifiStatusErrorBorder: "#2e{{colors.error.default.hex_stripped}}",
  wifiConnectedCardBg: "#24{{colors.primary_container.default.hex_stripped}}",
  wifiConnectedCardBorder: "#2e{{colors.primary.default.hex_stripped}}",
  wifiConnectedIconBg: "#29{{colors.primary.default.hex_stripped}}",
  wifiListCardBg: "#0b{{colors.on_surface.default.hex_stripped}}",
  wifiListCardHoverBg: "#11{{colors.on_surface.default.hex_stripped}}",
  wifiListCardBorder: "#0d{{colors.on_surface.default.hex_stripped}}",
  wifiListIconBg: "#0d{{colors.on_surface.default.hex_stripped}}",
  wifiPasswordRevealBg: "#0d{{colors.on_surface.default.hex_stripped}}"
}
