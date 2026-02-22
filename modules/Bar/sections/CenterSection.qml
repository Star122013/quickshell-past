import Quickshell
import Quickshell.Services.Mpris
import QtQuick

import "../../Theme/theme.js" as Theme

Item {
    id: root

    required property var niri
    required property var stats
    required property bool mediaMenuOpen

    signal toggleMediaMenu(real x, real y)
    signal toggleSystemStatusMenu(real x, real y)

    property var activePlayer: {
        var values = Mpris.players && Mpris.players.values ? Mpris.players.values : [];
        var first = null;
        var i;
        for (i = 0; i < values.length; i++) {
            if (!values[i])
                continue;
            if (!first)
                first = values[i];
            if (values[i].isPlaying)
                return values[i];
        }
        return first;
    }

    function workspaceText() {
        if (!root.niri)
            return "Workspace --";
        if (root.niri.activeWorkspaceId < 0)
            return "Workspace --";
        return "  " + (root.niri.activeWorkspaceName || root.niri.activeWorkspaceId);
    }

    function mediaLabel() {
        if (!root.activePlayer)
            return "No Media";
        if (root.activePlayer.trackTitle && root.activePlayer.trackTitle.length > 0)
            return root.activePlayer.trackTitle;
        return root.activePlayer.identity || "Media";
    }

    function diskLabel() {
        var disk = root.stats ? root.stats.diskPercent : 0;
        return disk + "%";
    }

    Row {
        id: statusRow
        anchors.centerIn: parent
        height: parent.height - 8
        spacing: 12

        Rectangle {
            id: statusCard
            width: 192
            height: statusRow.height
            radius: Theme.radiusMd
            color: Theme.colors.surfaceStrong

            Row {
                id: metricsRow
                anchors.centerIn: parent
                height: parent.height
                spacing: 0

                Item {
                    width: 56
                    height: metricsRow.height

                    Canvas {
                        id: cpuRing
                        width: 16
                        height: 16
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        onPaint: {
                            var ctx = getContext("2d");
                            var line = 1.8;
                            var r = width / 2 - line;
                            var value = root.stats ? root.stats.cpuPercent : 0;
                            var start = -Math.PI / 2;
                            var end = start + (Math.PI * 2 * value / 100);
                            ctx.reset();
                            ctx.beginPath();
                            ctx.arc(width / 2, height / 2, r, 0, Math.PI * 2);
                            ctx.strokeStyle = Theme.colors.surfaceRaised;
                            ctx.lineWidth = line;
                            ctx.stroke();
                            ctx.beginPath();
                            ctx.arc(width / 2, height / 2, r, start, end);
                            ctx.strokeStyle = Theme.colors.info;
                            ctx.lineWidth = line;
                            ctx.stroke();
                        }
                    }

                    Connections {
                        target: root.stats
                        function onCpuPercentChanged() {
                            cpuRing.requestPaint();
                        }
                    }

                    Text {
                        anchors.left: cpuRing.right
                        anchors.leftMargin: 3
                        anchors.verticalCenter: cpuRing.verticalCenter
                        text: (root.stats ? root.stats.cpuPercent : 0) + "%"
                        color: Theme.colors.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                    }
                }

                Item {
                    width: 52
                    height: metricsRow.height

                    Canvas {
                        id: memRing
                        width: 16
                        height: 16
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        onPaint: {
                            var ctx = getContext("2d");
                            var line = 1.8;
                            var r = width / 2 - line;
                            var value = root.stats ? root.stats.memPercent : 0;
                            var start = -Math.PI / 2;
                            var end = start + (Math.PI * 2 * value / 100);
                            ctx.reset();
                            ctx.beginPath();
                            ctx.arc(width / 2, height / 2, r, 0, Math.PI * 2);
                            ctx.strokeStyle = Theme.colors.surfaceRaised;
                            ctx.lineWidth = line;
                            ctx.stroke();
                            ctx.beginPath();
                            ctx.arc(width / 2, height / 2, r, start, end);
                            ctx.strokeStyle = Theme.colors.accent;
                            ctx.lineWidth = line;
                            ctx.stroke();
                        }
                    }

                    Connections {
                        target: root.stats
                        function onMemPercentChanged() {
                            memRing.requestPaint();
                        }
                    }

                    Text {
                        anchors.left: memRing.right
                        anchors.leftMargin: 3
                        anchors.verticalCenter: memRing.verticalCenter
                        text: (root.stats ? root.stats.memPercent : 0) + "%"
                        color: Theme.colors.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                    }
                }

                Item {
                    width: 52
                    height: metricsRow.height

                    Canvas {
                        id: diskRing
                        width: 16
                        height: 16
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        onPaint: {
                            var ctx = getContext("2d");
                            var line = 1.8;
                            var r = width / 2 - line;
                            var value = root.stats ? root.stats.diskPercent : 0;
                            var start = -Math.PI / 2;
                            var end = start + (Math.PI * 2 * value / 100);
                            ctx.reset();
                            ctx.beginPath();
                            ctx.arc(width / 2, height / 2, r, 0, Math.PI * 2);
                            ctx.strokeStyle = Theme.colors.surfaceRaised;
                            ctx.lineWidth = line;
                            ctx.stroke();
                            ctx.beginPath();
                            ctx.arc(width / 2, height / 2, r, start, end);
                            ctx.strokeStyle = Theme.colors.accentStrong;
                            ctx.lineWidth = line;
                            ctx.stroke();
                        }
                    }

                    Connections {
                        target: root.stats
                        function onDiskPercentChanged() {
                            diskRing.requestPaint();
                        }
                    }

                    Text {
                        anchors.left: diskRing.right
                        anchors.leftMargin: 2
                        anchors.verticalCenter: diskRing.verticalCenter
                        text: root.diskLabel()
                        color: Theme.colors.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var p = statusCard.mapToItem(null, statusCard.width / 2, statusCard.height);
                    root.toggleSystemStatusMenu(p.x, p.y);
                }
            }
        }

        Rectangle {
            id: mediaCard
            width: 174
            height: statusRow.height
            radius: Theme.radiusMd
            color: root.mediaMenuOpen ? Theme.colors.workspaceOccupied : Theme.colors.surfaceStrong

            Text {
                anchors.centerIn: parent
                text: "󰎆  " + root.mediaLabel()
                color: Theme.colors.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                elide: Text.ElideRight
                width: parent.width - 14
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var p = mediaCard.mapToItem(null, mediaCard.width / 2, mediaCard.height);
                    root.toggleMediaMenu(p.x, p.y);
                }
            }
        }

        Rectangle {
            width: 146
            height: statusRow.height
            radius: Theme.radiusMd
            color: Theme.colors.surfaceStrong

            Text {
                anchors.centerIn: parent
                text: root.workspaceText()
                color: Theme.colors.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                elide: Text.ElideRight
                width: parent.width - 12
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle {
            width: 156
            height: statusRow.height
            radius: Theme.radiusMd
            color: Theme.colors.surfaceStrong

            Text {
                anchors.centerIn: parent
                text: Qt.formatDateTime(clock.date, "HH:mm · MM/dd")
                color: Theme.colors.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
