import Quickshell.Bluetooth
import Quickshell
import QtQuick

import "../../Theme/theme.js" as Theme
import "../widgets"

Row {
  id: root

  required property var notifications
  required property var audio
  required property var wifi
  required property var panelWindow
  required property bool notificationCenterOpen
  required property bool volumeMenuOpen
  required property bool wifiMenuOpen
  required property bool bluetoothMenuOpen
  required property bool powerMenuOpen

  signal toggleNotifications()
  signal clearNotifications()
  signal notificationMenuRequested(real x, real y)
  signal trayMenuRequested(var menu, real x, real y)
  signal volumeMenuRequested(real x, real y)
  signal volumeStep(int delta)
  signal toggleMute()
  signal wifiMenuRequested(real x, real y)
  signal bluetoothMenuRequested(real x, real y)
  signal powerMenuRequested(real x, real y)

  height: parent.height - 6
  spacing: 8

  TrayStrip {
    height: parent.height
    window: root.panelWindow
    onTrayMenuRequested: function(menu, x, y) { root.trayMenuRequested(menu, x, y) }
  }

  NotificationStrip {
    id: notificationButton
    height: parent.height
    notifications: root.notifications
    open: root.notificationCenterOpen
    onToggleRequested: {
      var p = notificationButton.mapToItem(null, notificationButton.width / 2, notificationButton.height)
      root.notificationMenuRequested(p.x, p.y)
    }
    onClearRequested: root.clearNotifications()
  }

  VolumeButton {
    id: volumeButton
    height: parent.height
    volumePercent: root.audio ? root.audio.volumePercent : 0
    muted: root.audio ? root.audio.muted : false
    open: root.volumeMenuOpen
    onToggleRequested: {
      var p = volumeButton.mapToItem(null, volumeButton.width / 2, volumeButton.height)
      root.volumeMenuRequested(p.x, p.y)
    }
    onWheelStep: function(delta) { root.volumeStep(delta) }
    onMuteToggleRequested: root.toggleMute()
  }

  WifiButton {
    id: wifiButton
    height: parent.height
    enabled: root.wifi ? root.wifi.enabled : false
    connectedSsid: root.wifi ? root.wifi.connectedSsid : ""
    open: root.wifiMenuOpen
    onToggleRequested: {
      var p = wifiButton.mapToItem(null, wifiButton.width / 2, wifiButton.height)
      root.wifiMenuRequested(p.x, p.y)
    }
  }

  BluetoothButton {
    id: bluetoothButton
    height: parent.height
    enabled: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
    connectedCount: {
      var devices = Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.devices && Bluetooth.defaultAdapter.devices.values ? Bluetooth.defaultAdapter.devices.values : []
      var count = 0
      var i
      for (i = 0; i < devices.length; i++) if (devices[i] && devices[i].connected) count++
      return count
    }
    open: root.bluetoothMenuOpen
    onToggleRequested: {
      var p = bluetoothButton.mapToItem(null, bluetoothButton.width / 2, bluetoothButton.height)
      root.bluetoothMenuRequested(p.x, p.y)
    }
  }

  PowerButton {
    id: powerButton
    height: parent.height
    open: root.powerMenuOpen
    onToggleRequested: {
      var p = powerButton.mapToItem(null, powerButton.width / 2, powerButton.height)
      root.powerMenuRequested(p.x, p.y)
    }
  }
}
