import QtQuick

import "../../../Theme/theme.js" as Theme

Row {
  id: root

  required property var niri

  spacing: 0

  property var fallbackWorkspaces: [
    { id: 1, name: "1", active: true, occupied: true },
    { id: 2, name: "2", active: false, occupied: true },
    { id: 3, name: "3", active: false, occupied: false },
    { id: 4, name: "4", active: false, occupied: false }
  ]

  property var displayWorkspaces: {
    if (niri && niri.workspaces && niri.workspaces.length > 0) return niri.workspaces
    return fallbackWorkspaces
  }

  Rectangle {
    width: strip.implicitWidth + Theme.innerGap * 2 + 2
    height: parent.height
    radius: height / 2
    color: Theme.colors.barWorkspaceStripBg
    border.width: 1
    border.color: Theme.colors.barWorkspaceStripBorder

    Rectangle {
      anchors.fill: parent
      anchors.margins: 1
      radius: parent.radius - 1
      color: Theme.colors.barWorkspaceStripOverlay
      border.width: 0
    }

    Row {
      id: strip
      anchors.centerIn: parent
      spacing: Theme.workspaceStripSpacing()

      Repeater {
        model: root.displayWorkspaces

        Rectangle {
          id: dot
          required property var modelData

          property bool isActive: !!modelData.active
          property bool isOccupied: !!modelData.occupied
          property bool hovered: workspaceMouse.containsMouse

          width: isActive ? Theme.workspaceDotActiveWidth() : (isOccupied ? Theme.workspaceDotOccupiedSize() : Theme.workspaceDotEmptySize())
          height: isActive ? Theme.workspaceDotActiveHeight() : (isOccupied ? Theme.workspaceDotOccupiedSize() : Theme.workspaceDotEmptySize())
          radius: height / 2
          color: isActive ? Theme.colors.workspaceActive : (hovered ? Theme.colors.barWorkspaceDotHover : (isOccupied ? Theme.colors.barWorkspaceDotOccupied : Theme.colors.barWorkspaceDotEmpty))
          scale: hovered && !isActive ? 1.08 : 1
          opacity: isActive ? 1 : 0.96
          anchors.verticalCenter: parent.verticalCenter

          Behavior on color { ColorAnimation { duration: 150 } }
          Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
          Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
          Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
          Behavior on opacity { NumberAnimation { duration: 120 } }

          MouseArea {
            id: workspaceMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.niri) root.niri.focusWorkspace(parent.modelData.id)
          }
        }
      }
    }
  }
}
