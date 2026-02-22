import QtQuick

import "../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property bool enabled
  required property int connectedCount
  required property bool open

  signal toggleRequested()

  width: 30
  height: parent.height
  radius: Theme.radiusMd
  color: root.open ? Theme.colors.workspaceOccupied : Theme.colors.surfaceStrong

  Text {
    anchors.centerIn: parent
    text: root.enabled ? "󰂯" : "󰂲"
    color: Theme.colors.textPrimary
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize + 1
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggleRequested()
  }
}
