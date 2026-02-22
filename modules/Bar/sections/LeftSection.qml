import QtQuick

import "../../Theme/theme.js" as Theme
import "../widgets"

Row {
    id: root

    required property var niri

    height: parent.height - 6
    spacing: 8

    Rectangle {
        width: 30
        height: parent.height
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong
        border.width: 0

        Text {
            anchors.centerIn: parent
            text: " 󰣨 "
            color: Theme.colors.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 1
            font.bold: true
        }
    }

    WorkspaceStrip {
        height: parent.height
        niri: root.niri
    }
}
