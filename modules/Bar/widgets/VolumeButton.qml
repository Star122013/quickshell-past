import QtQuick

import "../../Theme/theme.js" as Theme

Rectangle {
    id: root

    required property int volumePercent
    required property bool muted
    required property bool open

    signal toggleRequested
    signal wheelStep(int delta)
    signal muteToggleRequested

    width: 30
    height: parent.height
    radius: Theme.radiusMd
    color: root.open ? Theme.colors.workspaceOccupied : Theme.colors.surfaceStrong

    Text {
        anchors.centerIn: parent
        text: hover.hovered ? (root.volumePercent + "%") : (root.muted ? " 󰝟 " : " 󰕾 ")
        color: Theme.colors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: hover.hovered ? Theme.fontSize - 3 : Theme.fontSize + 1
    }

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: function (mouse) {
            if (mouse.button === Qt.MiddleButton) {
                root.muteToggleRequested();
                return;
            }
            root.toggleRequested();
        }

        onWheel: function (wheel) {
            root.wheelStep(wheel.angleDelta.y > 0 ? 4 : -4);
        }
    }
}
