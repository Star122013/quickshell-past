import QtQuick

import "../../Theme/theme.js" as Theme

Row {
  id: root

  required property var niri

  spacing: 6

  property var fallbackWorkspaces: [
    { id: 1, name: "1", active: true, occupied: true },
    { id: 2, name: "2", active: false, occupied: true },
    { id: 3, name: "3", active: false, occupied: false }
  ]

  property var displayWorkspaces: {
    if (niri && niri.workspaces && niri.workspaces.length > 0) return niri.workspaces
    return fallbackWorkspaces
  }

  Rectangle {
    width: strip.implicitWidth + 6
    height: parent.height
    radius: Theme.radiusSm
    color: Theme.colors.surfaceStrong
    border.width: 0

    Row {
      id: strip
      anchors.left: parent.left
      anchors.leftMargin: 3
      anchors.verticalCenter: parent.verticalCenter
      height: parent.height - 6
      spacing: 3

      Repeater {
        model: root.displayWorkspaces

        Rectangle {
          required property var modelData

          property bool isActive: !!modelData.active
          property bool isOccupied: !!modelData.occupied

          width: strip.height
          height: strip.height
          radius: width / 2
          color: isActive ? Theme.colors.workspaceActive : (isOccupied ? Theme.colors.workspaceOccupied : Theme.colors.workspaceEmpty)
          border.width: 0

          Text {
            anchors.centerIn: parent
            text: modelData.id
            color: isActive ? Theme.colors.accentText : (isOccupied ? Theme.colors.textPrimary : Theme.colors.textMuted)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: isActive
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.niri) root.niri.focusWorkspace(parent.modelData.id)
          }
        }
      }
    }
  }
}
