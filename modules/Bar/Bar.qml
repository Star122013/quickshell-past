pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import "../Theme/theme.js" as Theme
import "sections"
import "widgets"

Scope {
  id: root

  required property var niri
  required property var notifications
  required property var stats
  required property var audio
  required property var wifi

  property bool notificationCenterOpen: false
  property bool mediaMenuOpen: false
  property bool powerMenuOpen: false
  property bool volumeMenuOpen: false
  property bool wifiMenuOpen: false
  property bool bluetoothMenuOpen: false
  property bool trayMenuOpen: false
  property bool systemStatusMenuOpen: false
  property var trayMenuHandle: null
  property real trayMenuX: 0
  property var trayMenuScreen: null
  property int notificationCenterVerticalOffset: -40
  property bool anyPopupOpen: root.notificationCenterOpen || root.mediaMenuOpen || root.powerMenuOpen || root.volumeMenuOpen || root.wifiMenuOpen || root.bluetoothMenuOpen || root.systemStatusMenuOpen

  function closeAllPopups() {
    root.notificationCenterOpen = false
    root.mediaMenuOpen = false
    root.powerMenuOpen = false
    root.volumeMenuOpen = false
    root.wifiMenuOpen = false
    root.bluetoothMenuOpen = false
    root.trayMenuOpen = false
    root.systemStatusMenuOpen = false
  }

  function clearNotifications() {
    if (!root.notifications || !root.notifications.trackedNotifications) return
    var values = root.notifications.trackedNotifications.values
    if (!values) return

    var i
    for (i = values.length - 1; i >= 0; i--) {
      if (values[i] && values[i].dismiss) values[i].dismiss()
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel

      required property var modelData
      screen: modelData

      color: "transparent"
      implicitHeight: Theme.barHeight + Theme.outerGap * 2

      anchors {
        top: true
        left: true
        right: true
      }

      margins {
        top: Theme.outerGap
        left: Theme.outerGap
        right: Theme.outerGap
      }

      exclusiveZone: implicitHeight

      Item {
        id: frame
        width: panel.width - (Theme.outerGap * 4) + 10
        height: Theme.barHeight
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
          anchors.fill: parent
          radius: Theme.radiusLg
          color: Theme.colors.surface
          border.width: 0
        }

        LeftSection {
          id: left
          anchors.left: parent.left
          anchors.leftMargin: Theme.innerGap
          anchors.verticalCenter: parent.verticalCenter
          niri: root.niri
        }

        RightSection {
          id: right
          anchors.right: parent.right
          anchors.rightMargin: Theme.innerGap
          anchors.verticalCenter: parent.verticalCenter
          notifications: root.notifications
          audio: root.audio
          wifi: root.wifi
          notificationCenterOpen: root.notificationCenterOpen
          volumeMenuOpen: root.volumeMenuOpen
          wifiMenuOpen: root.wifiMenuOpen
          bluetoothMenuOpen: root.bluetoothMenuOpen
          powerMenuOpen: root.powerMenuOpen
          panelWindow: panel
          onToggleNotifications: {
            root.notificationCenterOpen = !root.notificationCenterOpen
            root.volumeMenuOpen = false
            root.wifiMenuOpen = false
            root.bluetoothMenuOpen = false
            root.powerMenuOpen = false
            root.systemStatusMenuOpen = false
          }
          onClearNotifications: root.clearNotifications()
          onToggleVolumeMenu: {
            root.volumeMenuOpen = !root.volumeMenuOpen
            root.notificationCenterOpen = false
            root.wifiMenuOpen = false
            root.bluetoothMenuOpen = false
            root.powerMenuOpen = false
            root.systemStatusMenuOpen = false
          }
          onVolumeStep: function(delta) { root.audio.stepVolume(delta) }
          onToggleMute: root.audio.toggleMute()
          onToggleWifiMenu: {
            root.wifiMenuOpen = !root.wifiMenuOpen
            root.notificationCenterOpen = false
            root.volumeMenuOpen = false
            root.bluetoothMenuOpen = false
            root.powerMenuOpen = false
            root.systemStatusMenuOpen = false
          }
          onToggleBluetoothMenu: {
            root.bluetoothMenuOpen = !root.bluetoothMenuOpen
            root.notificationCenterOpen = false
            root.volumeMenuOpen = false
            root.wifiMenuOpen = false
            root.powerMenuOpen = false
            root.systemStatusMenuOpen = false
          }
          onTogglePowerMenu: {
            root.powerMenuOpen = !root.powerMenuOpen
            root.notificationCenterOpen = false
            root.volumeMenuOpen = false
            root.wifiMenuOpen = false
            root.bluetoothMenuOpen = false
            root.trayMenuOpen = false
            root.systemStatusMenuOpen = false
          }
          onTrayMenuRequested: function(menu, x, y) {
            root.trayMenuHandle = menu
            root.trayMenuX = Theme.outerGap + x
            root.trayMenuScreen = panel.modelData
            root.trayMenuOpen = true
            root.notificationCenterOpen = false
            root.volumeMenuOpen = false
            root.wifiMenuOpen = false
            root.bluetoothMenuOpen = false
            root.powerMenuOpen = false
            root.systemStatusMenuOpen = false
          }
        }

        CenterSection {
          anchors.left: left.right
          anchors.right: right.left
          anchors.leftMargin: Theme.innerGap
          anchors.rightMargin: Theme.innerGap
          anchors.verticalCenter: parent.verticalCenter
          anchors.verticalCenterOffset: 3
          height: parent.height
          niri: root.niri
          stats: root.stats
          mediaMenuOpen: root.mediaMenuOpen
          onToggleMediaMenu: {
            root.mediaMenuOpen = !root.mediaMenuOpen
            root.systemStatusMenuOpen = false
          }
          onToggleSystemStatusMenu: {
            root.systemStatusMenuOpen = !root.systemStatusMenuOpen
            root.mediaMenuOpen = false
            root.notificationCenterOpen = false
            root.volumeMenuOpen = false
            root.wifiMenuOpen = false
            root.bluetoothMenuOpen = false
            root.powerMenuOpen = false
            root.trayMenuOpen = false
          }
        }
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: dismissLayer

      required property var modelData
      screen: modelData

      visible: root.anyPopupOpen
      color: "transparent"

      anchors {
        top: true
        left: true
        right: true
        bottom: true
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: root.closeAllPopups()
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: systemStatusMenu

      required property var modelData
      screen: modelData

      visible: root.systemStatusMenuOpen
      color: "transparent"
      implicitWidth: 220
      implicitHeight: 156

      anchors {
        top: true
        left: true
      }

      margins {
        top: Theme.outerGap * 2 + Theme.barHeight - 1 + root.notificationCenterVerticalOffset
        left: Math.max(Theme.outerGap, (modelData.width - implicitWidth) / 2 - 110)
      }

      SystemStatusMenu {
        anchors.fill: parent
        open: root.systemStatusMenuOpen
        stats: root.stats
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: trayMenuPopup

      required property var modelData
      screen: modelData

      visible: root.trayMenuOpen && root.trayMenuScreen === modelData
      color: "transparent"
      implicitWidth: 230
      implicitHeight: 260

      anchors {
        top: true
        left: true
      }

      margins {
        top: Theme.outerGap * 2 + Theme.barHeight - 1 + root.notificationCenterVerticalOffset
        left: root.trayMenuX
      }

      ThemedTrayMenu {
        anchors.fill: parent
        open: root.trayMenuOpen
        menu: root.trayMenuHandle
        onItemTriggered: root.trayMenuOpen = false
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: mediaMenu

      required property var modelData
      screen: modelData

      visible: root.mediaMenuOpen || mediaPopup.opacity > 0.02
      color: "transparent"
      implicitWidth: 420
      implicitHeight: 170

      anchors {
        top: true
        left: true
      }

      margins {
        top: Theme.outerGap * 2 + Theme.barHeight - 1 + root.notificationCenterVerticalOffset
        left: Math.max(Theme.outerGap, (modelData.width - implicitWidth) / 2)
      }

      MediaPopup {
        id: mediaPopup
        anchors.fill: parent
        open: root.mediaMenuOpen
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: volumeMenu

      required property var modelData
      screen: modelData

      visible: root.volumeMenuOpen || volumePopup.opacity > 0.02
      color: "transparent"
      implicitWidth: 280
      implicitHeight: 240

      anchors {
        top: true
        right: true
      }

      margins {
        top: Theme.outerGap * 2 + Theme.barHeight - 1 + root.notificationCenterVerticalOffset
        right: Theme.outerGap + 96
      }

      VolumeMenu {
        id: volumePopup
        anchors.fill: parent
        open: root.volumeMenuOpen
        audio: root.audio
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: wifiMenu

      required property var modelData
      screen: modelData

      visible: root.wifiMenuOpen || wifiPopup.opacity > 0.02
      color: "transparent"
      implicitWidth: 280
      implicitHeight: 260

      anchors {
        top: true
        right: true
      }

      margins {
        top: Theme.outerGap * 2 + Theme.barHeight - 1 + root.notificationCenterVerticalOffset
        right: Theme.outerGap + 136
      }

      WifiMenu {
        id: wifiPopup
        anchors.fill: parent
        open: root.wifiMenuOpen
        wifi: root.wifi
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bluetoothMenu

      required property var modelData
      screen: modelData

      visible: root.bluetoothMenuOpen || bluetoothPopup.opacity > 0.02
      color: "transparent"
      implicitWidth: 280
      implicitHeight: 260

      anchors {
        top: true
        right: true
      }

      margins {
        top: Theme.outerGap * 2 + Theme.barHeight - 1 + root.notificationCenterVerticalOffset
        right: Theme.outerGap + 176
      }

      BluetoothMenu {
        id: bluetoothPopup
        anchors.fill: parent
        open: root.bluetoothMenuOpen
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: powerMenu

      required property var modelData
      screen: modelData

      visible: root.powerMenuOpen || powerPopup.opacity > 0.02
      color: "transparent"
      implicitWidth: 200
      implicitHeight: 206

      anchors {
        top: true
        right: true
      }

      margins {
        top: Theme.outerGap * 2 + Theme.barHeight - 1 + root.notificationCenterVerticalOffset
        right: Theme.outerGap
      }

      PowerMenu {
        id: powerPopup
        anchors.fill: parent
        open: root.powerMenuOpen
        onActionTriggered: root.powerMenuOpen = false
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: notificationCenter

      required property var modelData
      screen: modelData

      visible: root.notificationCenterOpen || notificationPopup.opacity > 0.02
      color: "transparent"
      implicitWidth: 360
      implicitHeight: 280

      anchors {
        top: true
        right: true
      }

      margins {
        top: Theme.outerGap * 2 + Theme.barHeight - 1 + root.notificationCenterVerticalOffset
        right: Theme.outerGap
      }

      NotificationCenter {
        id: notificationPopup
        anchors.fill: parent
        notifications: root.notifications
        open: root.notificationCenterOpen
      }
    }
  }
}
