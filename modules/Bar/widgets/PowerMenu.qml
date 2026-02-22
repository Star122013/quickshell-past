import Quickshell.Io
import QtQuick

import "../../Theme/theme.js" as Theme

Rectangle {
    id: root

    required property bool open
    property real popupScale: root.open ? 1 : 0.96
    property string pendingAction: ""
    property string pendingCommand: ""

    signal actionTriggered

    radius: Theme.radiusMd
    color: Theme.colors.surface
    border.width: 0
    opacity: root.open ? 1 : 0

    transform: Scale {
        origin.x: root.width
        origin.y: 0
        xScale: root.popupScale
        yScale: root.popupScale
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }
    Behavior on popupScale {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutCubic
        }
    }

    function runAction(cmd) {
        actionProc.exec(["sh", "-lc", cmd]);
        root.pendingAction = "";
        root.pendingCommand = "";
        root.actionTriggered();
    }

    function askConfirm(label, cmd) {
        root.pendingAction = label;
        root.pendingCommand = cmd;
    }

    Process {
        id: actionProc
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Rectangle {
            visible: root.pendingAction.length > 0
            width: parent.width
            height: 30
            radius: Theme.radiusSm
            color: Theme.colors.surfaceRaised

            Text {
                anchors.centerIn: parent
                text: "Confirm " + root.pendingAction + "?"
                color: Theme.colors.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }

        Rectangle {
            width: parent.width
            height: 30
            radius: Theme.radiusSm
            color: Theme.colors.surfaceStrong

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    width: 16
                    horizontalAlignment: Text.AlignHCenter
                    text: "⏻"
                    color: Theme.colors.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                Text {
                    width: 72
                    horizontalAlignment: Text.AlignLeft
                    text: "Shutdown"
                    color: Theme.colors.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.askConfirm("Shutdown", "systemctl poweroff")
            }
        }

        Rectangle {
            width: parent.width
            height: 30
            radius: Theme.radiusSm
            color: Theme.colors.surfaceStrong

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    width: 16
                    horizontalAlignment: Text.AlignHCenter
                    text: ""
                    color: Theme.colors.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                Text {
                    width: 72
                    horizontalAlignment: Text.AlignLeft
                    text: "Reboot"
                    color: Theme.colors.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.askConfirm("Reboot", "systemctl reboot")
            }
        }

        Rectangle {
            width: parent.width
            height: 30
            radius: Theme.radiusSm
            color: Theme.colors.surfaceStrong

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    width: 16
                    horizontalAlignment: Text.AlignHCenter
                    text: "⏾"
                    color: Theme.colors.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                Text {
                    width: 72
                    horizontalAlignment: Text.AlignLeft
                    text: "Suspend"
                    color: Theme.colors.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.askConfirm("Suspend", "systemctl suspend")
            }
        }

        Row {
            visible: root.pendingAction.length > 0
            width: parent.width
            spacing: 8

            Rectangle {
                width: (parent.width - 8) / 2
                height: 30
                radius: Theme.radiusSm
                color: Theme.colors.workspaceActive

                Text {
                    anchors.centerIn: parent
                    text: "Confirm"
                    color: Theme.colors.accentText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.pendingCommand.length > 0)
                        root.runAction(root.pendingCommand)
                }
            }

            Rectangle {
                width: (parent.width - 8) / 2
                height: 30
                radius: Theme.radiusSm
                color: Theme.colors.surfaceStrong

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: Theme.colors.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.pendingAction = "";
                        root.pendingCommand = "";
                    }
                }
            }
        }
    }
}
