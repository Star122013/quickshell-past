pragma ComponentBehavior: Bound

import QtQuick

import "../../Theme/theme.js" as Theme

Rectangle {
    id: root

    required property var notifications
    required property bool open

    signal toggleRequested()
    signal clearRequested()

    width: 30
    height: parent.height
    radius: Theme.radiusSm
    color: root.notificationCount > 0 ? Theme.colors.surfaceRaised : Theme.colors.surfaceStrong
    border.width: 0

    property int notificationCount: {
        if (!notifications || !notifications.trackedNotifications || !notifications.trackedNotifications.values)
            return 0;
        return notifications.trackedNotifications.values.length || 0;
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: 150
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton) {
                root.clearRequested();
                return;
            }

            root.toggleRequested();
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.open ? "" : ""
        color: root.notificationCount > 0 ? Theme.colors.accent : Theme.colors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 2
        font.bold: false
    }

    Rectangle {
        visible: root.notificationCount > 0
        width: 14
        height: 14
        radius: 7
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 1
        anchors.rightMargin: 1
        color: Theme.colors.accent

        Text {
            anchors.centerIn: parent
            text: root.notificationCount > 9 ? "9+" : String(root.notificationCount)
            color: Theme.colors.accentText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            font.bold: true
        }
    }
}
