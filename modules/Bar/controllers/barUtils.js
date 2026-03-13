.pragma library

function controlHubWidthFor(section, popupStyle) {
  if (section === "wifi")
    return popupStyle.controlHubWifiWidth;
  if (section === "bluetooth")
    return popupStyle.controlHubBluetoothWidth;
  if (section === "notifications")
    return popupStyle.controlHubNotificationsWidth;
  if (section === "power")
    return popupStyle.controlHubPowerWidth;
  return popupStyle.controlHubDefaultWidth;
}

function controlHubHeightFor(section, popupStyle) {
  if (section === "wifi")
    return popupStyle.controlHubWifiHeight;
  if (section === "bluetooth")
    return popupStyle.controlHubBluetoothHeight;
  if (section === "notifications")
    return popupStyle.controlHubNotificationsHeight;
  if (section === "power")
    return popupStyle.controlHubPowerHeight;
  return popupStyle.controlHubDefaultHeight;
}

function avatarSubmenuWidthFor(section, popupStyle) {
  if (section === "wifi")
    return popupStyle.wifiMenuWidth;
  if (section === "sound")
    return popupStyle.volumeMenuWidth;
  if (section === "bluetooth")
    return popupStyle.bluetoothMenuWidth;
  if (section === "notifications")
    return popupStyle.notificationMenuWidth;
  if (section === "power")
    return popupStyle.powerMenuWidth;
  return popupStyle.volumeMenuWidth;
}

function avatarSubmenuHeightFor(section, popupStyle) {
  if (section === "wifi")
    return popupStyle.wifiMenuHeight;
  if (section === "sound")
    return popupStyle.volumeMenuHeight;
  if (section === "bluetooth")
    return popupStyle.bluetoothMenuHeight;
  if (section === "notifications")
    return popupStyle.notificationMenuHeight;
  if (section === "power")
    return popupStyle.powerMenuHeight;
  return popupStyle.volumeMenuHeight;
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
