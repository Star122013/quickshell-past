import QtQuick

import "../../../Theme/theme.js" as Theme

Rectangle {
    id: root

    required property bool enabled
    required property int connectedCount
    required property bool open

    signal toggleRequested

    width: Theme.barCompactButtonSize()
    height: parent.height
    radius: height / 2
    color: root.open ? Theme.colors.barControlButtonActiveBg : (buttonMouse.containsMouse ? Theme.colors.barControlButtonHoverBg : "transparent")
    border.width: 0

    Behavior on color {
        ColorAnimation {
            duration: 140
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.enabled ? "󰂱 " : "󰂲"
        color: Theme.colors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
    }

    MouseArea {
        id: buttonMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleRequested()
    }
}
