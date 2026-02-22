pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import "../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property bool open
  required property var menu
  property var activeSubmenu: null
  property real activeSubmenuY: 0
  property real popupScale: root.open ? 1 : 0.97

  signal itemTriggered()

  radius: 0
  color: "transparent"
  border.width: 0
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
      root.activeSubmenu = null
      if (root.menu.menu.sendOpened) root.menu.menu.sendOpened()
      if (root.menu.menu.updateLayout) root.menu.menu.updateLayout()
      Qt.callLater(function() {
        if (root.menu && root.menu.menu && root.menu.menu.updateLayout) root.menu.menu.updateLayout()
      })
    } else {
      if (root.activeSubmenu && root.activeSubmenu.sendClosed) root.activeSubmenu.sendClosed()
      root.activeSubmenu = null
      if (root.menu.menu.sendClosed) root.menu.menu.sendClosed()
    }
  }

  implicitWidth: root.activeSubmenu ? 446 : 230
  implicitHeight: Math.max(mainPane.height, submenuPane.visible ? (submenuPane.y + submenuPane.height) : mainPane.height)

  Rectangle {
    id: mainPane
    width: 230
    height: Math.min(menuColumn.implicitHeight + 16, 320)
    radius: Theme.radiusMd
    color: Theme.colors.surface
    border.width: 1
    border.color: Theme.colors.surfaceRaised
  }

  Flickable {
    anchors.fill: mainPane
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
          id: entryItem
          required property var modelData

          width: menuColumn.width
          height: entryItem.modelData && entryItem.modelData.isSeparator ? 8 : 34

          Rectangle {
            visible: entryItem.modelData && entryItem.modelData.isSeparator
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 1
            color: Theme.colors.surfaceRaised
          }

          Rectangle {
            visible: entryItem.modelData && !entryItem.modelData.isSeparator
            anchors.fill: parent
            radius: Theme.radiusSm
            color: rowHover.containsMouse ? Theme.colors.surfaceStrong : "transparent"

            Image {
              id: rowIcon
              visible: entryItem.modelData && entryItem.modelData.icon && entryItem.modelData.icon.length > 0
              anchors.left: parent.left
              anchors.leftMargin: 10
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              source: entryItem.modelData ? entryItem.modelData.icon : ""
              fillMode: Image.PreserveAspectFit
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: rowIcon.visible ? rowIcon.right : parent.left
              anchors.leftMargin: rowIcon.visible ? 8 : 10
              anchors.right: rowChevron.visible ? rowChevron.left : parent.right
              anchors.rightMargin: 10
              text: entryItem.modelData ? entryItem.modelData.text : ""
              color: entryItem.modelData && entryItem.modelData.enabled !== false ? Theme.colors.textPrimary : Theme.colors.textMuted
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
              elide: Text.ElideRight
            }

            Text {
              id: rowChevron
              visible: entryItem.modelData && entryItem.modelData.hasChildren
              anchors.right: parent.right
              anchors.rightMargin: 10
              anchors.verticalCenter: parent.verticalCenter
              text: "▸"
              color: Theme.colors.textMuted
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
            }

            MouseArea {
              id: rowHover
              anchors.fill: parent
              hoverEnabled: true
              enabled: entryItem.modelData && !entryItem.modelData.isSeparator && (entryItem.modelData.enabled !== false)
              cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
              onClicked: {
                if (!entryItem.modelData) return
                if (entryItem.modelData.hasChildren) {
                  if (root.activeSubmenu === entryItem.modelData) {
                    if (root.activeSubmenu && root.activeSubmenu.sendClosed) root.activeSubmenu.sendClosed()
                    root.activeSubmenu = null
                    return
                  }
                  if (root.activeSubmenu && root.activeSubmenu.sendClosed) root.activeSubmenu.sendClosed()
                  if (entryItem.modelData.sendOpened) entryItem.modelData.sendOpened()
                  if (entryItem.modelData.opened) entryItem.modelData.opened()
                  if (entryItem.modelData.updateLayout) entryItem.modelData.updateLayout()
                  Qt.callLater(function() {
                    if (entryItem.modelData && entryItem.modelData.updateLayout) entryItem.modelData.updateLayout()
                  })
                  var p = entryItem.mapToItem(root, 0, 0)
                  root.activeSubmenu = entryItem.modelData
                  root.activeSubmenuY = Math.max(8, Math.min(p.y, mainPane.height - 140))
                  Qt.callLater(function() {
                    var hasChildren = submenuOpener.children && ((submenuOpener.children.values && submenuOpener.children.values.length > 0) || submenuOpener.children.count > 0)
                    if (!hasChildren && entryItem.modelData.display && root.Window && root.Window.window) {
                      var gp = entryItem.mapToItem(null, entryItem.width, 0)
                      entryItem.modelData.display(root.Window.window, gp.x, gp.y)
                    }
                  })
                  return
                }
                if (entryItem.modelData.sendTriggered) entryItem.modelData.sendTriggered()
                else if (entryItem.modelData.triggered) entryItem.modelData.triggered()
                root.itemTriggered()
              }
            }
          }
        }
      }
    }
  }

  Rectangle {
    id: submenuPane
    visible: !!root.activeSubmenu
    z: 10
    x: mainPane.width + 6
    y: root.activeSubmenuY
    width: 210
    height: Math.min(submenuColumn.implicitHeight + 12, 260)
    radius: Theme.radiusMd
    color: Theme.colors.surface
    border.width: 1
    border.color: Theme.colors.surfaceRaised

    QsMenuOpener {
      id: submenuOpener
      menu: root.activeSubmenu
    }

    Flickable {
      anchors.fill: parent
      anchors.margins: 6
      clip: true
      contentWidth: width
      contentHeight: submenuColumn.implicitHeight

      Column {
        id: submenuColumn
        width: parent.width
        spacing: 3

        Repeater {
          model: submenuOpener.children

          Item {
            id: subEntry
            required property var modelData

            width: submenuColumn.width
            height: subEntry.modelData && subEntry.modelData.isSeparator ? 8 : 30

            Rectangle {
              visible: subEntry.modelData && subEntry.modelData.isSeparator
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 12
              x: 6
              height: 1
              color: Theme.colors.surfaceRaised
            }

            Rectangle {
              visible: subEntry.modelData && !subEntry.modelData.isSeparator
              anchors.fill: parent
              radius: Theme.radiusSm
              color: subHover.containsMouse ? Theme.colors.surfaceStrong : "transparent"

              Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                text: subEntry.modelData ? subEntry.modelData.text : ""
                color: subEntry.modelData && subEntry.modelData.enabled !== false ? Theme.colors.textPrimary : Theme.colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                elide: Text.ElideRight
              }

              MouseArea {
                id: subHover
                anchors.fill: parent
                hoverEnabled: true
                enabled: subEntry.modelData && !subEntry.modelData.isSeparator && (subEntry.modelData.enabled !== false)
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                  if (!subEntry.modelData) return
                  if (subEntry.modelData.sendTriggered) subEntry.modelData.sendTriggered()
                  else if (subEntry.modelData.triggered) subEntry.modelData.triggered()
                  root.itemTriggered()
                }
              }
            }
          }
        }
      }
    }
  }
}
