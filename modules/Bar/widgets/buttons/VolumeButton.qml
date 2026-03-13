import QtQuick

import "../../../Theme/theme.js" as Theme

Rectangle {
    id: root

    required property int volumePercent
    required property bool muted
    required property bool open

    signal toggleRequested
    signal wheelStep(int delta)
    signal muteToggleRequested

    width: Theme.barCompactButtonSize()
    height: parent.height
    radius: height / 2
    color: root.open ? Theme.colors.barControlButtonActiveBg : (buttonMouse.containsMouse ? Theme.colors.barControlButtonHoverBg : "transparent")
    border.width: 0

    function iconText() {
        if (root.muted || root.volumePercent === 0)
            return "󰝟 ";
        return "󰕾 ";
    }

    Behavior on color {
        ColorAnimation {
            duration: 140
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.iconText()
        color: Theme.colors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
    }

    MouseArea {
        id: buttonMouse
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
