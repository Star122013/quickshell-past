pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

import "../../Theme/theme.js" as Theme

Row {
  id: root

  required property var window

  signal trayMenuRequested(var menu, real x, real y)

  spacing: 4

  Repeater {
    model: SystemTray.items

      Rectangle {
        id: trayButton

        required property var modelData
        property var trayWindow: root.window

        width: 30
        height: parent.height
        radius: Theme.radiusSm
        
        // Dynamic color based on hover
        color: trayMouse.containsMouse ? Theme.colors.surfaceRaised : Theme.colors.surfaceStrong
        border.width: 0

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        
        // Scale on hover
        scale: trayMouse.containsMouse ? 1.03 : 1.0
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        IconImage {
          anchors.centerIn: parent
          implicitSize: 17
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
