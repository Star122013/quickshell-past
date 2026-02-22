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
  property real trayMenuY: 0
  property real trayMenuHitWidth: 460
  property real trayMenuHitHeight: 440
  property real notificationMenuX: 0
  property real notificationMenuY: 0
  property real volumeMenuX: 0
  property real volumeMenuY: 0
  property real wifiMenuX: 0
  property real wifiMenuY: 0
  property real bluetoothMenuX: 0
  property real bluetoothMenuY: 0
  property real powerMenuX: 0
  property real powerMenuY: 0
  property real mediaMenuX: 0
  property real mediaMenuY: 0
  property real systemStatusMenuX: 0
  property real systemStatusMenuY: 0
  property var trayMenuScreen: null
  property var popupScreen: null
  property int notificationCenterVerticalOffset: -40
  property bool anyPopupOpen: root.notificationCenterOpen || root.mediaMenuOpen || root.powerMenuOpen || root.volumeMenuOpen || root.wifiMenuOpen || root.bluetoothMenuOpen || root.trayMenuOpen || root.systemStatusMenuOpen

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

  function popupLeft(anchorX, popupWidth, screenWidth) {
    var minX = Theme.outerGap
    var maxX = Math.max(minX, screenWidth - Theme.outerGap - popupWidth)
    var centeredX = Theme.outerGap + anchorX - popupWidth / 2
    return Math.max(minX, Math.min(maxX, centeredX))
  }

  function popupTop(anchorY) {
    return Theme.outerGap + anchorY - 40
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
          onNotificationMenuRequested: function(x, y) {
            var w = 360
            var wasOpen = root.notificationCenterOpen && root.popupScreen === panel.modelData
            root.closeAllPopups()
            if (wasOpen) return
            root.popupScreen = panel.modelData
            root.notificationMenuX = root.popupLeft(x, w, panel.modelData.width)
            root.notificationMenuY = root.popupTop(y)
            root.notificationCenterOpen = true
          }
          onClearNotifications: root.clearNotifications()
          onVolumeMenuRequested: function(x, y) {
            var w = 280
            var wasOpen = root.volumeMenuOpen && root.popupScreen === panel.modelData
            root.closeAllPopups()
            if (wasOpen) return
            root.popupScreen = panel.modelData
            root.volumeMenuX = root.popupLeft(x, w, panel.modelData.width)
            root.volumeMenuY = root.popupTop(y)
            root.volumeMenuOpen = true
          }
          onVolumeStep: function(delta) { root.audio.stepVolume(delta) }
          onToggleMute: root.audio.toggleMute()
          onWifiMenuRequested: function(x, y) {
            var w = 280
            var wasOpen = root.wifiMenuOpen && root.popupScreen === panel.modelData
            root.closeAllPopups()
            if (wasOpen) return
            root.popupScreen = panel.modelData
            root.wifiMenuX = root.popupLeft(x, w, panel.modelData.width)
            root.wifiMenuY = root.popupTop(y)
            root.wifiMenuOpen = true
          }
          onBluetoothMenuRequested: function(x, y) {
            var w = 280
            var wasOpen = root.bluetoothMenuOpen && root.popupScreen === panel.modelData
            root.closeAllPopups()
            if (wasOpen) return
            root.popupScreen = panel.modelData
            root.bluetoothMenuX = root.popupLeft(x, w, panel.modelData.width)
            root.bluetoothMenuY = root.popupTop(y)
            root.bluetoothMenuOpen = true
          }
          onPowerMenuRequested: function(x, y) {
            var w = 200
            var wasOpen = root.powerMenuOpen && root.popupScreen === panel.modelData
            root.closeAllPopups()
            if (wasOpen) return
            root.popupScreen = panel.modelData
            root.powerMenuX = root.popupLeft(x, w, panel.modelData.width)
            root.powerMenuY = root.popupTop(y)
            root.powerMenuOpen = true
          }
          onTrayMenuRequested: function(menu, x, y) {
            var w = 230
            var sameMenu = root.trayMenuOpen && root.trayMenuHandle === menu && root.trayMenuScreen === panel.modelData
            if (sameMenu) {
              root.trayMenuOpen = false
              return
            }
            root.closeAllPopups()
            root.trayMenuHandle = menu
            root.trayMenuX = root.popupLeft(x, w, panel.modelData.width)
            root.trayMenuY = root.popupTop(y)
            root.trayMenuHitWidth = 460
            root.trayMenuHitHeight = 440
            root.trayMenuScreen = panel.modelData
            root.popupScreen = panel.modelData
            root.trayMenuOpen = true
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
          onToggleMediaMenu: function(x, y) {
            var w = 420
            var wasOpen = root.mediaMenuOpen && root.popupScreen === panel.modelData
            root.closeAllPopups()
            if (wasOpen) return
            root.popupScreen = panel.modelData
            root.mediaMenuX = root.popupLeft(x, w, panel.modelData.width)
            root.mediaMenuY = root.popupTop(y)
            root.mediaMenuOpen = true
          }
          onToggleSystemStatusMenu: function(x, y) {
            var w = 220
            var wasOpen = root.systemStatusMenuOpen && root.popupScreen === panel.modelData
            root.closeAllPopups()
            if (wasOpen) return
            root.popupScreen = panel.modelData
            root.systemStatusMenuX = root.popupLeft(x, w, panel.modelData.width)
            root.systemStatusMenuY = root.popupTop(y)
            root.systemStatusMenuOpen = true
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
        onPressed: function(mouse) {
          if (root.trayMenuOpen && root.trayMenuScreen === modelData) {
            var insideTray = mouse.x >= root.trayMenuX && mouse.x <= (root.trayMenuX + root.trayMenuHitWidth)
              && mouse.y >= root.trayMenuY && mouse.y <= (root.trayMenuY + root.trayMenuHitHeight)
            if (insideTray) {
              mouse.accepted = false
              return
            }
          }
          root.closeAllPopups()
        }
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: systemStatusMenu

      required property var modelData
      screen: modelData

      visible: root.systemStatusMenuOpen && root.popupScreen === modelData
      color: "transparent"
      implicitWidth: 220
      implicitHeight: 156

      anchors {
        top: true
        left: true
      }

      margins {
        top: root.systemStatusMenuY
        left: root.systemStatusMenuX
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
      implicitWidth: trayMenuContent.implicitWidth
      implicitHeight: trayMenuContent.implicitHeight

      anchors {
        top: true
        left: true
      }

      margins {
        top: root.trayMenuY
        left: root.trayMenuX
      }

      ThemedTrayMenu {
        id: trayMenuContent
        anchors.fill: parent
        open: root.trayMenuOpen
        menu: root.trayMenuHandle
        onImplicitWidthChanged: root.trayMenuHitWidth = implicitWidth
        onImplicitHeightChanged: root.trayMenuHitHeight = implicitHeight
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

      visible: (root.mediaMenuOpen || mediaPopup.opacity > 0.02) && root.popupScreen === modelData
      color: "transparent"
      implicitWidth: 420
      implicitHeight: 170

      anchors {
        top: true
        left: true
      }

      margins {
        top: root.mediaMenuY
        left: root.mediaMenuX
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

      visible: (root.volumeMenuOpen || volumePopup.opacity > 0.02) && root.popupScreen === modelData
      color: "transparent"
      implicitWidth: 280
      implicitHeight: 240

      anchors {
        top: true
        left: true
      }

      margins {
        top: root.volumeMenuY
        left: root.volumeMenuX
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

      visible: (root.wifiMenuOpen || wifiPopup.opacity > 0.02) && root.popupScreen === modelData
      color: "transparent"
      implicitWidth: 280
      implicitHeight: 260

      anchors {
        top: true
        left: true
      }

      margins {
        top: root.wifiMenuY
        left: root.wifiMenuX
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

      visible: (root.bluetoothMenuOpen || bluetoothPopup.opacity > 0.02) && root.popupScreen === modelData
      color: "transparent"
      implicitWidth: 280
      implicitHeight: 260

      anchors {
        top: true
        left: true
      }

      margins {
        top: root.bluetoothMenuY
        left: root.bluetoothMenuX
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

      visible: (root.powerMenuOpen || powerPopup.opacity > 0.02) && root.popupScreen === modelData
      color: "transparent"
      implicitWidth: 200
      implicitHeight: 206

      anchors {
        top: true
        left: true
      }

      margins {
        top: root.powerMenuY
        left: root.powerMenuX
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

      visible: (root.notificationCenterOpen || notificationPopup.opacity > 0.02) && root.popupScreen === modelData
      color: "transparent"
      implicitWidth: 360
      implicitHeight: 280

      anchors {
        top: true
        left: true
      }

      margins {
        top: root.notificationMenuY
        left: root.notificationMenuX
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
