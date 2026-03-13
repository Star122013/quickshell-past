.pragma library
.import "./theme.js" as Theme
.import "./userTheme.js" as User

// 头像主菜单内部样式。
// 如果只是想改主菜单的“整体感觉”，优先改 `userTheme.js` 里的 `profileMenu`。
// 这里主要负责把那些主尺寸派生成更细的局部尺寸。

var layout = {
  padding: User.profileMenu.layout.padding,
  spacing: User.profileMenu.layout.spacing,
  dividerOpacity: User.profileMenu.layout.dividerOpacity
}

var header = {
  avatarSize: User.profileMenu.header.avatarSize,
  avatarInset: User.profileMenu.header.avatarInset,
  titleSize: User.profileMenu.header.titleSize,
  statusIconSize: Theme.fontSize + 1,
  statusTextSize: Theme.fontSize - 3,
  clockWidth: User.profileMenu.header.clockWidth,
  clockHeight: User.profileMenu.header.clockHeight,
  clockTimeSize: Theme.fontSize - 3,
  clockDateSize: Theme.fontSize - 7,
  actionSize: User.profileMenu.header.actionSize,
  actionIconSize: Theme.fontSize - 1,

  avatarRadius: function() {
    return Theme.halfRadius(this.avatarSize);
  },

  avatarImageRadius: function() {
    return Math.max(0, this.avatarRadius() - this.avatarInset);
  },

  clockRadius: function() {
    return Theme.halfRadius(this.clockHeight);
  },

  actionRadius: function() {
    return Theme.halfRadius(this.actionSize);
  }
}

var tile = {
  height: User.profileMenu.tile.height,
  padding: User.profileMenu.tile.padding,
  gap: User.profileMenu.tile.gap,
  iconBadgeSize: Theme.fontSize + 8,
  iconSize: Theme.fontSize - 3,
  titleSize: Theme.fontSize - 1,
  titleBottomMargin: 12,

  radius: function() {
    return Theme.halfRadius(this.height);
  },

  iconBadgeRadius: function() {
    return Theme.halfRadius(this.iconBadgeSize);
  }
}

var slider = {
  trackHeight: User.profileMenu.slider.trackHeight,
  handleWidth: User.profileMenu.slider.handleWidth,
  handleHeight: User.profileMenu.slider.handleHeight,
  animationDuration: User.profileMenu.slider.animationDuration,

  trackRadius: function() {
    return Theme.halfRadius(this.trackHeight);
  },

  handleRadius: function() {
    return Theme.halfRadius(this.handleWidth);
  }
}

var greeting = {
  cardHeight: User.profileMenu.greeting.cardHeight,
  cardPadding: User.profileMenu.greeting.cardPadding,
  titleSize: Theme.fontSize + 1,
  messageSize: Theme.fontSize - 5,
  artworkWidth: User.profileMenu.greeting.artworkWidth,
  artworkHeight: User.profileMenu.greeting.artworkHeight,
  artworkInset: 2,
  patternSize: Theme.fontSize + 16,

  cardRadius: function() {
    return Math.min(Theme.uiRadius, 28);
  },

  artworkRadius: function() {
    return Math.min(Theme.uiRadius, 24);
  }
}
