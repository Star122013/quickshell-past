.pragma library

// 颜色单独拆到这个文件里，方便后面接 matugen / pywal / 其它主题生成器。
// 建议后续自动生成时只覆盖这个文件里的值，尽量不要改 key 名。
// `theme.js` 里仍然通过 `Theme.colors.*` 对外暴露，现有组件不需要改调用方式。
//
// 推荐约定：
// 1. `bg/surface/text/accent` 这几组当作“主语义色”，最适合交给生成器覆盖。
// 2. 下面的 `bar* / profile* / wifi* / notification*` 更像是派生层级色；
//    如果后面想进一步自动化，也可以让生成器只改主语义色，再保留这些覆写做微调。

var palette = {
  // 主背景 / 表面层级。
  bg: "#1a1418",
  surface: "#d819151d",
  surfaceStrong: "#b5302a34",
  surfaceRaised: "#d4463d4a",

  // 通用边框。
  border: "#00000000",
  borderSoft: "#35f3dfd5",

  // 文本。
  textPrimary: "#f3e9e2",
  textMuted: "#cbb9b2",

  // 强调 / 状态。
  accent: "#ebb5a2",
  accentStrong: "#f3c8ba",
  accentText: "#261b19",
  info: "#9fb7d7",
  danger: "#f3a097",

  // workspace / 选择态。
  workspaceOccupied: "#8a685f6f",
  workspaceActive: "#ebb5a2",
  workspaceEmpty: "#00000000",

  // 顶栏主体 / 背景叠层。
  barShellOverlay: "#04ffffff",

  // 顶栏：左侧头像 / 状态环。
  barAvatarShell: "#0affffff",
  barAvatarShellHover: "#12ffffff",
  barAvatarBorder: "#1fffffff",
  barStatusCenterBg: "#0affffff",
  barStatusCenterActiveBg: "#14ffffff",
  barStatusRingTrack: "#1affffff",

  // 顶栏：workspace 条。
  barWorkspaceStripBg: "#0dffffff",
  barWorkspaceStripBorder: "#14ffffff",
  barWorkspaceStripOverlay: "#05ffffff",
  barWorkspaceDotHover: "#61ffffff",
  barWorkspaceDotOccupied: "#3dffffff",
  barWorkspaceDotEmpty: "#1fffffff",

  // 顶栏：右侧控制区 / 小按钮 / 分隔线。
  barControlShellBorder: "#14ffffff",
  barControlShellOverlay: "#05ffffff",
  barControlButtonActiveBg: "#14ffffff",
  barControlButtonHoverBg: "#0affffff",
  barControlButtonBorder: "#14ffffff",
  barMediaIconBorder: "#47ffffff",
  barDivider: "#1affffff",
  barVolumePillBorder: "#1fffffff",
  barTrayButtonHoverBg: "#0dffffff",
  barTrayButtonBorder: "#1fffffff",

  // 控制中心整体外壳 / 导航。
  controlHubInnerOverlay: "#04ffffff",
  controlHubNavBorder: "#0fffffff",
  controlHubNavItemBorder: "#14ffffff",

  // 通知 toast。
  notificationToastBg: "#f52b2630",
  notificationToastBorder: "#14ffffff",
  notificationToastInnerOverlay: "#05ffffff",
  notificationToastIconBg: "#09ffffff",
  notificationToastIconBorder: "#0fffffff",

  // 头像弹出卡片：整体外壳。
  profileMenuBg: "#fb211c26",
  profileMenuBorder: "#12ffffff",
  profileMenuInnerOverlay: "#04ffffff",

  // 头像弹出卡片：头部区域。
  profileHeaderAvatarShell: "#09ffffff",
  profileHeaderAvatarInner: "#08ffffff",
  profileClockBg: "#12ffffff",
  profileClockBorder: "#0dffffff",
  profileActionBg: "#12ffffff",
  profileActionHoverBg: "#1cffffff",
  profileActionBorder: "#0dffffff",

  // 头像弹出卡片：快捷操作 / 分隔线 / 滑块底轨。
  // `profileDivider` 这里只存“基色”，透明度仍由 style 文件控制，方便继续微调层级。
  profileTileBg: "#11ffffff",
  profileTileBorder: "#0dffffff",
  profileTileAccentBorder: "#1f261a1a",
  profileTileBadgeBg: "#0dffffff",
  profileTileAccentBadgeBg: "#24241a17",
  profileDivider: "#ffffff",
  profileSliderTrack: "#eb664d4d",

  // 头像弹出卡片：问候卡。
  profileGreetingBg: "#0dffffff",
  profileGreetingBorder: "#0fffffff",
  profileGreetingInner: "#05ffffff",
  profileGreetingArtworkBg: "#0bffffff",
  profileGreetingArtworkBorder: "#0dffffff",

  // Wi‑Fi 菜单。
  wifiToggleBorder: "#14ffffff",
  wifiCardBg: "#0effffff",
  wifiCardBorder: "#0dffffff",
  wifiSummaryIconActiveBg: "#249eb8d6",
  wifiSummaryIconInactiveBg: "#0dffffff",
  wifiActionBg: "#0dffffff",
  wifiActionBorder: "#0dffffff",
  wifiStatusInfoBg: "#1f9eb8d6",
  wifiStatusInfoBorder: "#2e9eb8d6",
  wifiStatusErrorBg: "#1fe07870",
  wifiStatusErrorBorder: "#2ef5a196",
  wifiConnectedCardBg: "#24d9b5a3",
  wifiConnectedCardBorder: "#2eebc5b8",
  wifiConnectedIconBg: "#29ebc5b8",
  wifiListCardBg: "#0bffffff",
  wifiListCardHoverBg: "#11ffffff",
  wifiListCardBorder: "#0dffffff",
  wifiListIconBg: "#0dffffff",
  wifiPasswordRevealBg: "#0dffffff"
}
