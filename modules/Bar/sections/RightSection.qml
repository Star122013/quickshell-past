import Quickshell.Bluetooth
import Quickshell.Services.Mpris
import Quickshell
import QtQuick

import "../../Theme/theme.js" as Theme
import "../widgets/buttons"
import "../widgets/strips"

Row {
  id: root

  required property var notifications
  required property var audio
  required property var wifi
  required property var panelWindow
  required property bool mediaMenuOpen
  required property bool notificationCenterOpen
  required property bool volumeMenuOpen
  required property bool wifiMenuOpen
  required property bool bluetoothMenuOpen
  required property bool powerMenuOpen

  signal toggleNotifications()
  signal clearNotifications()
  signal mediaMenuRequested(real x, real y)
  signal notificationMenuRequested(real x, real y)
  signal trayMenuRequested(var menu, real x, real y)
  signal volumeMenuRequested(real x, real y)
  signal volumeStep(int delta)
  signal toggleMute()
  signal wifiMenuRequested(real x, real y)
  signal bluetoothMenuRequested(real x, real y)
  signal powerMenuRequested(real x, real y)

  property var activePlayer: {
    var values = Mpris.players && Mpris.players.values ? Mpris.players.values : []
    var first = null
    var index
    for (index = 0; index < values.length; index++) {
      if (!values[index]) continue
      if (!first) first = values[index]
      if (values[index].isPlaying) return values[index]
    }
    return first
  }

  function mediaTitle() {
    if (!root.activePlayer) return "No media"
    if (root.activePlayer.trackTitle && root.activePlayer.trackTitle.length > 0) return root.activePlayer.trackTitle
    if (root.activePlayer.identity && root.activePlayer.identity.length > 0) return root.activePlayer.identity
    return "Unknown track"
  }

  height: parent.height - 4
  spacing: 6

  Item {
    width: trayStrip.implicitWidth
    height: parent.height
    visible: trayStrip.implicitWidth > 0

    TrayStrip {
      id: trayStrip
      anchors.verticalCenter: parent.verticalCenter
      height: Theme.barCompactButtonSize()
      window: root.panelWindow
      onTrayMenuRequested: function(menu, x, y) { root.trayMenuRequested(menu, x, y) }
    }
  }

  Rectangle {
    id: controlsShell
    width: controlsRow.implicitWidth + Theme.innerGap * 2 - 2
    height: parent.height
    radius: height / 2
    color: Theme.colors.surfaceStrong
    border.width: 1
    border.color: Theme.colors.barControlShellBorder

    Rectangle {
      anchors.fill: parent
      anchors.margins: 1
      radius: parent.radius - 1
      color: Theme.colors.barControlShellOverlay
      border.width: 0
    }

    Row {
      id: controlsRow
      anchors.left: parent.left
      anchors.leftMargin: Theme.barControlsInset()
      anchors.right: parent.right
      anchors.rightMargin: Theme.barControlsInset()
      anchors.verticalCenter: parent.verticalCenter
      height: parent.height - Theme.barControlsHeightOffset()
      spacing: Theme.barControlsSpacing()

      Rectangle {
        id: mediaChip
        property bool hovered: mediaMouse.containsMouse

        width: Math.max(Theme.barMediaChipMinWidth(), Math.min(Theme.barMediaChipMaxWidth(), mediaLabel.implicitWidth + Theme.barCompactButtonSize() * 2))
        height: parent.height
        radius: height / 2
        color: root.mediaMenuOpen ? Theme.colors.barControlButtonActiveBg : (hovered ? Theme.colors.barControlButtonHoverBg : "transparent")
        border.width: root.mediaMenuOpen || hovered ? 1 : 0
        border.color: root.mediaMenuOpen ? Theme.colors.workspaceActive : Theme.colors.barControlButtonBorder

        Behavior on color { ColorAnimation { duration: 140 } }
        Behavior on border.color { ColorAnimation { duration: 140 } }
        Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        Row {
          anchors.fill: parent
          anchors.leftMargin: Math.max(6, Theme.innerGap - 2)
          anchors.rightMargin: Theme.innerGap
          spacing: Math.max(6, Math.round(Theme.innerGap * 0.8))

          Rectangle {
            width: Theme.barMediaChipIconSize()
            height: Theme.barMediaChipIconSize()
            radius: Theme.halfRadius(Theme.barMediaChipIconSize())
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"
            border.width: 1
            border.color: root.mediaMenuOpen ? Theme.colors.workspaceActive : Theme.colors.barMediaIconBorder

            Text {
              anchors.centerIn: parent
              text: root.activePlayer && root.activePlayer.isPlaying ? "󰏤" : "󰐊"
              color: root.mediaMenuOpen ? Theme.colors.workspaceActive : Theme.colors.textPrimary
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 6
              font.bold: true
            }
          }

          Text {
            id: mediaLabel
            anchors.verticalCenter: parent.verticalCenter
            width: mediaChip.width - Theme.barCompactButtonSize() * 2
            text: root.mediaTitle()
            color: Theme.colors.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 5
            font.bold: true
            elide: Text.ElideRight
          }
        }

        MouseArea {
          id: mediaMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            var p = mediaChip.mapToItem(null, mediaChip.width / 2, mediaChip.height)
            root.mediaMenuRequested(p.x, p.y)
          }
        }
      }

      Rectangle {
        width: 1
        height: Theme.barDividerHeight()
        radius: 0.5
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.colors.barDivider
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
          for (i = 0; i < devices.length; i++) {
            if (devices[i] && devices[i].connected)
              count++
          }
          return count
        }
        open: root.bluetoothMenuOpen
        onToggleRequested: {
          var p = bluetoothButton.mapToItem(null, bluetoothButton.width / 2, bluetoothButton.height)
          root.bluetoothMenuRequested(p.x, p.y)
        }
      }

      Rectangle {
        width: 1
        height: Theme.barDividerHeight()
        radius: 0.5
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.colors.barDivider
      }

      Rectangle {
        id: volumePill
        property bool hovered: volumeMouse.containsMouse

        width: Theme.barVolumePillWidth()
        height: parent.height
        radius: height / 2
        color: root.volumeMenuOpen ? Theme.colors.workspaceActive : Theme.colors.accentStrong
        border.width: hovered && !root.volumeMenuOpen ? 1 : 0
        border.color: Theme.colors.barVolumePillBorder

        Behavior on color { ColorAnimation { duration: 140 } }

        Text {
          anchors.centerIn: parent
          text: (root.audio ? root.audio.volumePercent : 0) + "%"
          color: Theme.colors.accentText
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 5
          font.bold: true
        }

        MouseArea {
          id: volumeMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            var p = volumePill.mapToItem(null, volumePill.width / 2, volumePill.height)
            root.volumeMenuRequested(p.x, p.y)
          }
        }
      }
    }
  }
}
