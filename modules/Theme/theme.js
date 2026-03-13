.pragma library
.import "./colors.js" as Palette
.import "./userTheme.js" as User

// 这个文件现在尽量不放“你手动常改的值”。
// 真正常调的东西都在 `userTheme.js`；这里主要负责把它们整理成组件更好用的派生值。

// 对外保留旧接口，避免 QML 组件大面积重写。
var fontFamily = User.typography.family
var fontSize = User.typography.size

var outerGap = User.layout.outerGap
var innerGap = User.layout.innerGap
var barHeight = User.layout.barHeight
var barTopMargin = User.layout.barTopMargin
var uiRadius = User.layout.uiRadius

var barOuterCornerControlFactor = User.bar.outerCornerControlFactor
var avatarImagePath = User.profile.avatarImagePath

var profileMenuWidth = User.profile.menu.width
var profileMenuHeight = User.profile.menu.height
var profileMenuMarginLeft = User.profile.menu.marginLeft

var barBottomSpacing = outerGap * 2
var radiusSm = Math.max(0, uiRadius - 5)
var radiusMd = uiRadius
var radiusLg = uiRadius + 4
var barOuterCornerWidth = radiusLg + 4
var barOuterCornerHeight = radiusMd + 2
var popupGap = 0
var popupSideGap = 10
var popupTopMargin = barTopMargin + outerGap + barOuterCornerHeight + popupGap
var profileMenuTopMargin = popupTopMargin

// 常用派生函数。
// 这些函数的目的就是继续减少可配置项数量，让组件尽量“自动跟着主参数走”。
function halfRadius(size) {
    return Math.min(uiRadius, size / 2);
}

function barCompactButtonSize() {
    return Math.max(22, Math.round(barHeight * 0.44));
}

function barControlsInset() {
    return Math.max(4, innerGap - 3);
}

function barControlsHeightOffset() {
    return Math.max(6, Math.round(barHeight * 0.16));
}

function barControlsSpacing() {
    return Math.max(4, Math.round(innerGap / 2));
}

function barMediaChipMinWidth() {
    return Math.max(120, fontSize * 6);
}

function barMediaChipMaxWidth() {
    return barMediaChipMinWidth() + 36;
}

function barMediaChipIconSize() {
    return Math.max(18, barCompactButtonSize() - 4);
}

function barVolumePillWidth() {
    return Math.max(40, barCompactButtonSize() + 18);
}

function barDividerHeight() {
    return Math.max(14, barCompactButtonSize() - 6);
}

function workspaceStripSpacing() {
    return Math.max(6, Math.round(innerGap * 0.7));
}

function workspaceDotActiveWidth() {
    return Math.max(24, uiRadius + 10);
}

function workspaceDotActiveHeight() {
    return Math.max(12, uiRadius - 6);
}

function workspaceDotOccupiedSize() {
    return Math.max(10, Math.round(uiRadius * 0.56));
}

function workspaceDotEmptySize() {
    return Math.max(8, Math.round(uiRadius * 0.44));
}

// 颜色继续沿用 `Theme.colors.*`。
var colors = Palette.palette
