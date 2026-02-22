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
  signal trayMenuRequested(var menu, real x, real y)
  signal toggleVolumeMenu()
  signal volumeStep(int delta)
  signal toggleMute()
  signal toggleWifiMenu()
  signal toggleBluetoothMenu()
  signal togglePowerMenu()

  height: parent.height - 6
  spacing: 8

  TrayStrip {
    height: parent.height
    window: root.panelWindow
    onTrayMenuRequested: function(menu, x, y) { root.trayMenuRequested(menu, x, y) }
  }

  NotificationStrip {
    height: parent.height
    notifications: root.notifications
    open: root.notificationCenterOpen
    onToggleRequested: root.toggleNotifications()
    onClearRequested: root.clearNotifications()
  }

  VolumeButton {
    height: parent.height
    volumePercent: root.audio ? root.audio.volumePercent : 0
    muted: root.audio ? root.audio.muted : false
    open: root.volumeMenuOpen
    onToggleRequested: root.toggleVolumeMenu()
    onWheelStep: function(delta) { root.volumeStep(delta) }
    onMuteToggleRequested: root.toggleMute()
  }

  WifiButton {
    height: parent.height
    enabled: root.wifi ? root.wifi.enabled : false
    connectedSsid: root.wifi ? root.wifi.connectedSsid : ""
    open: root.wifiMenuOpen
    onToggleRequested: root.toggleWifiMenu()
  }

  BluetoothButton {
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
    onToggleRequested: root.toggleBluetoothMenu()
  }

  PowerButton {
    height: parent.height
    open: root.powerMenuOpen
    onToggleRequested: root.togglePowerMenu()
  }
}
