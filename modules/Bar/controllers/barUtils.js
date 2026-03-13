.pragma library

function popupPanel(popupStyle) {
  if (popupStyle && popupStyle.panel)
    return popupStyle.panel;
  return popupStyle || {};
}

function submenuConfig(panel, section) {
  var key = section;

  if (key === "sound")
    key = "volume";

  if (!panel || !panel.leftSubmenu)
    return null;

  if (panel.leftSubmenu[key])
    return panel.leftSubmenu[key];

  return panel.leftSubmenu.volume || null;
}

function controlHubWidthFor(section, popupStyle) {
  var panel = popupPanel(popupStyle);

  if (panel.controlHub && panel.controlHub.width !== undefined)
    return panel.controlHub.width;

  return 0;
}

function controlHubHeightFor(section, popupStyle) {
  var panel = popupPanel(popupStyle);

  if (panel.controlHub && panel.controlHub.height !== undefined)
    return panel.controlHub.height;

  return 0;
}

function avatarSubmenuWidthFor(section, popupStyle) {
  var panel = popupPanel(popupStyle);
  var submenu = submenuConfig(panel, section);

  if (submenu && submenu.width !== undefined)
    return submenu.width;

  return 0;
}

function avatarSubmenuHeightFor(section, popupStyle) {
  var panel = popupPanel(popupStyle);
  var submenu = submenuConfig(panel, section);

  if (submenu && submenu.height !== undefined)
    return submenu.height;

  return 0;
}

function popupLeft(anchorX, popupWidth, screenWidth, outerGap) {
  var minX = outerGap;
  var maxX = Math.max(minX, screenWidth - outerGap - popupWidth);
  var centeredX = outerGap + anchorX - popupWidth / 2;
  return Math.max(minX, Math.min(maxX, centeredX));
}

function popupTop(popupTopMargin) {
  return popupTopMargin;
}

function controlHubLeft(screenWidth, popupWidth, outerGap) {
  return Math.max(outerGap, screenWidth - outerGap - popupWidth);
}

function avatarMenuLeft(anchorX, menuWidth, screenWidth, outerGap, marginLeft, anchorOffset) {
  return Math.max(marginLeft, Math.min(screenWidth - outerGap - menuWidth, anchorX - anchorOffset));
}

function avatarSubmenuLeft(avatarMenuX, avatarMenuWidth, popupSideGap, screenWidth, popupWidth, outerGap) {
  var preferredX = avatarMenuX + avatarMenuWidth + popupSideGap;
  var maxX = Math.max(outerGap, screenWidth - outerGap - popupWidth);
  if (preferredX <= maxX)
    return preferredX;
  return Math.max(outerGap, avatarMenuX + avatarMenuWidth - popupWidth);
}

function findItemByKey(list, key) {
  var i;
  if (!list)
    return null;
  for (i = 0; i < list.length; i++) {
    if (list[i] && list[i].key === key)
      return list[i];
  }
  return null;
}

function dismissTrackedNotifications(notifications) {
  if (!notifications || !notifications.trackedNotifications)
    return;
  var values = notifications.trackedNotifications.values;
  var i;
  if (!values)
    return;
  for (i = values.length - 1; i >= 0; i--) {
    if (values[i] && values[i].dismiss)
      values[i].dismiss();
  }
}

function notificationToastTimeout(notification, fallbackTimeout, minimumTimeout) {
  var timeout = notification && notification.expireTimeout !== undefined ? parseInt(notification.expireTimeout, 10) : 0;
  if (!isNaN(timeout) && timeout > minimumTimeout)
    return timeout;
  return fallbackTimeout;
}
