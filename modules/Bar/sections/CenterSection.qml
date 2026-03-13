import QtQuick

import "../widgets/strips"

Item {
  id: root

  required property var niri
  required property bool mediaMenuOpen

  signal toggleMediaMenu(real x, real y)

  WorkspaceStrip {
    id: workspaceStrip
    anchors.centerIn: parent
    height: 28
    niri: root.niri
  }
}
