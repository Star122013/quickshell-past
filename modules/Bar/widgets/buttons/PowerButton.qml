import QtQuick

import "../../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property bool open

  signal toggleRequested()

  width: 28
  height: parent.height
  radius: height / 2
  color: root.open ? Theme.colors.danger : (buttonMouse.containsMouse ? Theme.colors.surfaceRaised : "transparent")
  border.width: root.open ? 1 : 0
  border.color: root.open ? Theme.colors.danger : Theme.colors.borderSoft

  Behavior on color { ColorAnimation { duration: 140 } }
  scale: buttonMouse.containsMouse ? 1.04 : 1
  Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }

  Text {
    anchors.centerIn: parent
    text: ""
    color: root.open ? Theme.colors.accentText : Theme.colors.textPrimary
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize + 1
  }

  MouseArea {
    id: buttonMouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggleRequested()
  }
}
