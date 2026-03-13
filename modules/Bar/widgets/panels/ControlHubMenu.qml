import Quickshell.Bluetooth
import QtQuick

import "../../../Theme/theme.js" as Theme
import "../../../Theme/barPopupStyle.js" as PopupStyle

Rectangle {
  id: root

  required property bool open
  required property string activeSection
  required property var notifications
  required property var audio
  required property var wifi

  signal sectionRequested(string section)
  signal closeRequested()

  property real popupScale: root.open ? 1 : 0.96
  property var adapter: Bluetooth.defaultAdapter
  property var navItems: [
    { key: "power", icon: "⏻" },
    { key: "notifications", icon: "" },
    { key: "sound", icon: "󰕾" },
    { key: "wifi", icon: "󰤨" },
    { key: "bluetooth", icon: "󰂯" }
  ]

  radius: Theme.radiusMd
  color: Theme.colors.surface
  border.width: 1
  border.color: Theme.colors.surfaceRaised
  opacity: root.open ? 1 : 0
  clip: true

  transform: Scale {
    origin.x: root.width
    origin.y: 0
    xScale: root.popupScale
    yScale: root.popupScale
  }

  Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
  Behavior on popupScale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

  function syncBluetoothDiscovery() {
    if (!root.adapter)
      return
    root.adapter.discovering = root.open && root.activeSection === "bluetooth" && root.adapter.enabled
  }

  onOpenChanged: root.syncBluetoothDiscovery()
  onActiveSectionChanged: root.syncBluetoothDiscovery()
  Component.onDestruction: {
    if (root.adapter)
      root.adapter.discovering = false
  }

  Rectangle {
    anchors.fill: parent
    anchors.margins: 1
    radius: parent.radius - 1
    color: Theme.colors.controlHubInnerOverlay
    border.width: 0
  }

  Column {
    anchors.fill: parent
    anchors.margins: PopupStyle.panel.controlHub.padding
    spacing: PopupStyle.panel.controlHub.spacing

    Rectangle {
      id: navShell
      width: parent.width
      height: PopupStyle.panel.controlHub.navHeight
      radius: height / 2
      color: Theme.colors.surfaceStrong
      border.width: 1
      border.color: Theme.colors.controlHubNavBorder

      Row {
        anchors.left: parent.left
        anchors.leftMargin: PopupStyle.panel.controlHub.navInset
        anchors.right: parent.right
        anchors.rightMargin: PopupStyle.panel.controlHub.navInset
        anchors.verticalCenter: parent.verticalCenter
        spacing: PopupStyle.panel.controlHub.navSpacing

        Repeater {
          model: root.navItems

          Rectangle {
            required property var modelData

            width: PopupStyle.panel.controlHub.navButtonSize
            height: PopupStyle.panel.controlHub.navButtonSize
            radius: PopupStyle.panel.controlHub.navButtonSize / 2
            anchors.verticalCenter: parent.verticalCenter
            color: root.activeSection === modelData.key ? Theme.colors.workspaceActive : "transparent"
            border.width: root.activeSection === modelData.key ? 0 : (buttonMouse.containsMouse ? 1 : 0)
            border.color: Theme.colors.controlHubNavItemBorder

            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
              anchors.centerIn: parent
              text: modelData.icon
              color: root.activeSection === modelData.key ? Theme.colors.accentText : Theme.colors.textPrimary
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
              font.bold: root.activeSection === modelData.key
            }

            MouseArea {
              id: buttonMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.sectionRequested(modelData.key)
            }
          }
        }
      }
    }

    Item {
      width: parent.width
      height: parent.height - navShell.height - parent.spacing

      Loader {
        id: pageLoader
        anchors.fill: parent
        sourceComponent: {
          if (root.activeSection === "notifications") return notificationsPage
          if (root.activeSection === "sound") return soundPage
          if (root.activeSection === "wifi") return wifiPage
          if (root.activeSection === "bluetooth") return bluetoothPage
          return powerPage
        }
      }
    }
  }

  Component {
    id: notificationsPage

    NotificationCenter {
      anchors.fill: parent
      notifications: root.notifications
      open: true
      popupScale: 1
      radius: 0
      color: "transparent"
      border.width: 0
    }
  }

  Component {
    id: soundPage

    VolumeMenu {
      anchors.fill: parent
      open: true
      compactMode: true
      popupScale: 1
      radius: 0
      color: "transparent"
      border.width: 0
      audio: root.audio
    }
  }

  Component {
    id: wifiPage

    WifiMenu {
      anchors.fill: parent
      open: true
      compactMode: true
      popupScale: 1
      radius: 0
      color: "transparent"
      border.width: 0
      wifi: root.wifi
    }
  }

  Component {
    id: bluetoothPage

    BluetoothMenu {
      anchors.fill: parent
      open: true
      compactMode: true
      popupScale: 1
      radius: 0
      color: "transparent"
      border.width: 0
    }
  }

  Component {
    id: powerPage

    PowerMenu {
      anchors.fill: parent
      open: true
      compactMode: true
      popupScale: 1
      radius: 0
      color: "transparent"
      border.width: 0
      onActionTriggered: root.closeRequested()
    }
  }
}
