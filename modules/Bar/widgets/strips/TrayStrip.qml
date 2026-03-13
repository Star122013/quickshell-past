pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

import "../../../Theme/theme.js" as Theme

Row {
  id: root

  required property var window

  signal trayMenuRequested(var menu, real x, real y)

  spacing: 4

  Repeater {
    model: SystemTray.items

    Item {
      id: trayButton

      required property var modelData
      property var trayWindow: root.window

      width: Math.max(22, root.height - 10)
      height: width
      scale: trayMouse.containsMouse ? 1.06 : 1

      Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

      Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: trayMouse.containsMouse ? Theme.colors.barTrayButtonHoverBg : "transparent"
        border.width: trayMouse.containsMouse ? 1 : 0
        border.color: Theme.colors.barTrayButtonBorder
      }

      IconImage {
        anchors.centerIn: parent
        implicitSize: 16
        source: trayButton.modelData.icon
        asynchronous: true
      }

      MouseArea {
        id: trayMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: function(mouse) {
          if (mouse.button === Qt.RightButton) {
            if (trayButton.modelData.hasMenu) {
              var pos = trayButton.mapToItem(null, trayButton.width / 2, trayButton.height)
              root.trayMenuRequested(trayButton.modelData.menu, pos.x, pos.y)
            } else {
              trayButton.modelData.secondaryActivate()
            }
            return
          }

          if (mouse.button === Qt.MiddleButton) {
            trayButton.modelData.secondaryActivate()
            return
          }

          trayButton.modelData.activate()
        }

        onWheel: function(wheel) {
          trayButton.modelData.scroll(wheel.angleDelta.y, wheel.angleDelta.x !== 0)
        }
      }
    }
  }
}
