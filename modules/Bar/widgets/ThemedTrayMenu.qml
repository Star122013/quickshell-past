import Quickshell
import QtQuick

import "../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property bool open
  required property var menu
  property real popupScale: root.open ? 1 : 0.97

  signal itemTriggered()

  radius: Theme.radiusMd
  color: Theme.colors.surface
  border.width: 1
  border.color: Theme.colors.surfaceRaised
  opacity: root.open ? 1 : 0

  transform: Scale {
    origin.x: 0
    origin.y: 0
    xScale: root.popupScale
    yScale: root.popupScale
  }

  Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
  Behavior on popupScale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

  QsMenuOpener {
    id: opener
    menu: root.menu
  }

  onOpenChanged: {
    if (!root.menu || !root.menu.menu) return
    if (root.open) {
      if (root.menu.menu.sendOpened) root.menu.menu.sendOpened()
      if (root.menu.menu.updateLayout) root.menu.menu.updateLayout()
    } else {
      if (root.menu.menu.sendClosed) root.menu.menu.sendClosed()
    }
  }

  implicitWidth: 230
  implicitHeight: Math.min(menuColumn.implicitHeight + 16, 320)

  Flickable {
    anchors.fill: parent
    anchors.margins: 8
    clip: true
    contentWidth: width
    contentHeight: menuColumn.implicitHeight

    Column {
      id: menuColumn
      width: parent.width
      spacing: 4

      Repeater {
        model: opener.children

        Item {
          required property var modelData
          width: menuColumn.width
          height: modelData && modelData.isSeparator ? 8 : 34

          Rectangle {
            visible: modelData && modelData.isSeparator
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 1
            color: Theme.colors.surfaceRaised
          }

          Rectangle {
            visible: modelData && !modelData.isSeparator
            anchors.fill: parent
            radius: Theme.radiusSm
            color: trayHover.containsMouse ? Theme.colors.surfaceStrong : "transparent"

            Text {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: iconImage.visible ? iconImage.right : parent.left
              anchors.leftMargin: iconImage.visible ? 8 : 10
              anchors.right: chevron.visible ? chevron.left : parent.right
              anchors.rightMargin: 10
              text: modelData ? modelData.text : ""
              color: modelData && modelData.enabled ? Theme.colors.textPrimary : Theme.colors.textMuted
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
              elide: Text.ElideRight
            }

            Image {
              id: iconImage
              visible: modelData && modelData.icon && modelData.icon.length > 0
              anchors.left: parent.left
              anchors.leftMargin: 10
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              source: modelData ? modelData.icon : ""
              fillMode: Image.PreserveAspectFit
            }

            Text {
              id: chevron
              visible: modelData && modelData.hasChildren
              anchors.right: parent.right
              anchors.rightMargin: 10
              anchors.verticalCenter: parent.verticalCenter
              text: "▸"
              color: Theme.colors.textMuted
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
            }

            MouseArea {
              id: trayHover
              anchors.fill: parent
              hoverEnabled: true
              enabled: modelData && !modelData.isSeparator && (modelData.enabled !== false)
              cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
              onClicked: {
                if (modelData && modelData.hasChildren && modelData.opened) {
                  modelData.opened()
                  return
                }
                if (modelData && modelData.sendTriggered) modelData.sendTriggered()
                else if (modelData && modelData.triggered) modelData.triggered()
                root.itemTriggered()
              }
            }
          }
        }
      }
    }
  }
}
