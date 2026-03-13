import QtQuick

import "../../../Theme/theme.js" as Theme

Rectangle {
    id: root

    required property bool open
    required property var stats
    property real popupScale: root.open ? 1 : 0.96

    radius: Theme.radiusMd
    color: Theme.colors.surface
    border.width: 1
    border.color: Theme.colors.surfaceRaised
    opacity: root.open ? 1 : 0

    transform: Scale {
        origin.x: root.width / 2
        origin.y: 0
        xScale: root.popupScale
        yScale: root.popupScale
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 130
            easing.type: Easing.OutCubic
        }
    }

    Behavior on popupScale {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text {
            text: "System"
            color: Theme.colors.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            font.bold: true
        }

        Repeater {
            model: [
                {
                    label: "CPU",
                    icon: " ",
                    value: root.stats ? root.stats.cpuPercent : 0,
                    color: Theme.colors.info
                },
                {
                    label: "Memory",
                    icon: " ",
                    value: root.stats ? root.stats.memPercent : 0,
                    color: Theme.colors.accent
                }
            ]

            Rectangle {
                id: statCard
                required property var modelData
                width: root.width - 20
                height: 34
                radius: Theme.radiusSm
                color: Theme.colors.surfaceStrong

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: statCard.modelData.icon + "  " + statCard.modelData.label
                    color: Theme.colors.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    text: statCard.modelData.value + "%"
                    color: statCard.modelData.color
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                }
            }
        }
    }
}
