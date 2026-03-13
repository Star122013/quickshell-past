.pragma library

// 这个文件是“用户自定义入口”。
// 以后你想改主题，优先只改这里；其它 `theme.js / profileMenuStyle.js / barPopupStyle.js`
// 基本都只负责“派生”这些值，尽量不要再去那些文件里到处翻。
//
// 建议顺序：
// 1. 想整体更圆 / 更方：改 `layout.uiRadius`
// 2. 想改 bar 高度 / 间距：改 `layout`
// 3. 想改头像主菜单大小：改 `profile.menu`
// 4. 想改各种弹出层大小：改 `popup`
// 5. 想改颜色：去改 `colors.js`，或者直接让 matugen 覆盖它

// 字体。
var typography = {
  family: "Maple Mono NF CN",
  size: 18
}

// 整体布局。
var layout = {
  // 顶部 bar 离屏幕边的距离；通常你现在是贴边，所以保持 0。
  outerGap: 0,

  // bar 内部左右留白，以及很多小组件间距的基础值。
  innerGap: 10,

  // 顶部 bar 高度。
  barHeight: 50,

  // bar 顶部外边距；需要贴屏幕边时保持 0。
  barTopMargin: 0,

  // 全局圆角基准。
  // 大多数卡片 / 按钮 / 菜单圆角都从它派生。
  uiRadius: 18
}

// bar 外角。
var bar = {
  // 值越大，外角越饱满圆润；值越小，外角越收、更硬。
  outerCornerControlFactor: 0.48
}

// 头像与主菜单。
var profile = {
  // 左上角小头像路径。
  // 支持绝对路径；相对路径会按引用它的组件解析。
  avatarImagePath: "",

  menu: {
    width: 436,
    height: 624,

    // 主菜单相对点击点的横向补偿，避免太贴边。
    marginLeft: 12
  }
}

// 头像主菜单内部排版。
// 这里只放“主尺寸”，更细的圆角/字号会在 `profileMenuStyle.js` 里自动派生。
var profileMenu = {
  layout: {
    padding: 16,
    spacing: 14,
    dividerOpacity: 0.07
  },

  header: {
    avatarSize: 78,
    avatarInset: 2,
    titleSize: 28,
    clockWidth: 64,
    clockHeight: 42,
    actionSize: 42
  },

  tile: {
    height: 72,
    padding: 14,
    gap: 12
  },

  slider: {
    trackHeight: 12,
    handleWidth: 8,
    handleHeight: 30,
    animationDuration: 360
  },

  greeting: {
    cardHeight: 190,
    cardPadding: 16,
    artworkWidth: 172,
    artworkHeight: 92
  }
}

// 各弹出层尺寸。
// 大多数时候你只需要改宽高；padding/spacing 这些可以后面再细调。
var popup = {
  systemStatus: {
    width: 220,
    height: 120
  },

  media: {
    width: 420,
    height: 170
  },

  leftSubmenu: {
    volume: { width: 320, height: 304 },
    wifi: { width: 400, height: 472 },
    bluetooth: { width: 340, height: 340 },
    power: { width: 300, height: 312 },
    notifications: { width: 360, height: 280 }
  },

  controlHub: {
    width: 412,
    height: 472,
    padding: 10,
    spacing: 10,
    navHeight: 38,
    navInset: 4,
    navSpacing: 4,
    navButtonSize: 30
  },

  tray: {
    width: 230,
    expandedWidth: 446,
    paneMaxHeight: 320,
    contentPadding: 8,
    itemHeight: 34,
    separatorHeight: 8,
    hitWidth: 460,
    hitHeight: 440
  },

  toast: {
    width: 392,
    height: 88,
    padding: 12,
    spacing: 12,
    iconSize: 60,
    iconGlyphSize: 36,
    closeButtonSize: 18,
    textSpacing: 6,
    marginRight: 14,
    timeout: 4600,
    minimumTimeout: 600
  },

  avatar: {
    anchorOffset: 18
  }
}
