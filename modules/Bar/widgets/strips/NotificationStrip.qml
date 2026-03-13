pragma ComponentBehavior: Bound

import QtQuick

import "../../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property var notifications
  required property bool open

  signal toggleRequested()
  signal clearRequested()

  width: Theme.barCompactButtonSize()
  height: parent.height
  radius: height / 2
  color: root.open ? Theme.colors.barControlButtonActiveBg : (buttonMouse.containsMouse ? Theme.colors.barControlButtonHoverBg : "transparent")
  border.width: 0

  property int notificationCount: {
    if (!notifications || !notifications.trackedNotifications || !notifications.trackedNotifications.values)
      return 0
    return notifications.trackedNotifications.values.length || 0
  }

  Behavior on color { ColorAnimation { duration: 140 } }

  MouseArea {
    id: buttonMouse
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        root.clearRequested()
        return
      }
      root.toggleRequested()
    }
  }

  Text {
    anchors.centerIn: parent
    text: ""
    color: Theme.colors.textPrimary
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize - 2
  }

  Rectangle {
    visible: root.notificationCount > 0
    width: root.notificationCount > 9 ? 14 : 12
    height: 12
    radius: Theme.halfRadius(12)
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.topMargin: 0
    anchors.rightMargin: -1
    color: Theme.colors.accentStrong

    Text {
      anchors.centerIn: parent
      text: root.notificationCount > 9 ? "9+" : String(root.notificationCount)
      color: Theme.colors.accentText
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 8
      font.bold: true
    }
  }
}
