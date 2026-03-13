import QtQuick
import Qt5Compat.GraphicalEffects

import "../../Theme/theme.js" as Theme
import "../../Theme/profileMenuConfig.js" as ProfileConfig

Row {
    id: root

    required property var niri
    required property var stats
    required property bool systemStatusMenuOpen

    signal systemStatusMenuRequested(real x, real y)
    signal avatarMenuRequested(real x, real y)

    function hasUrlScheme(path) {
        return /^[A-Za-z][A-Za-z0-9+.-]*:/.test(path) || path.indexOf("/") === 0;
    }

    function resolveProfileConfigPath(path) {
        if (typeof path !== "string" || path.length === 0)
            return "";
        if (root.hasUrlScheme(path))
            return path;
        return Qt.resolvedUrl("../../Theme/" + path);
    }

    property string avatarSource: {
        if (typeof ProfileConfig.profileImagePath === "string" && ProfileConfig.profileImagePath.length > 0)
            return root.resolveProfileConfigPath(ProfileConfig.profileImagePath);
        if (typeof Theme.avatarImagePath === "string" && Theme.avatarImagePath.length > 0)
            return root.resolveProfileConfigPath(Theme.avatarImagePath);
        return "";
    }
    property bool hasAvatarImage: root.avatarSource.length > 0
    property string windowMeta: {
        if (root.niri && root.niri.activeWorkspaceId > -1)
            return "workspace " + String(root.niri.activeWorkspaceId);
        if (root.niri && root.niri.focusedWindowId && String(root.niri.focusedWindowId).length > 0)
            return "window #" + String(root.niri.focusedWindowId);
        return "desktop";
    }
    property string windowTitle: {
        if (root.niri && root.niri.focusedWindowAppId && String(root.niri.focusedWindowAppId).length > 0)
            return String(root.niri.focusedWindowAppId);
        if (root.niri && root.niri.focusedWindowTitle && String(root.niri.focusedWindowTitle).length > 0)
            return String(root.niri.focusedWindowTitle);
        if (root.niri && root.niri.activeWorkspaceName && String(root.niri.activeWorkspaceName).length > 0)
            return String(root.niri.activeWorkspaceName);
        return "Overview";
    }
    property string windowGlyph: {
        var source = root.windowTitle;
        if (source && source.length > 0)
            return source.charAt(0).toUpperCase();
        return "󰖲 ";
    }

    height: 30
    spacing: 10

    Item {
        id: avatarChip
        width: root.height
        height: root.height
        scale: avatarMouse.containsMouse ? 1.05 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: avatarMouse.containsMouse ? Theme.colors.barAvatarShellHover : Theme.colors.barAvatarShell
            border.width: 1
            border.color: avatarMouse.containsMouse ? Theme.colors.accentStrong : Theme.colors.barAvatarBorder
            antialiasing: true
        }

        Item {
            id: avatarVisual
            anchors.fill: parent
            anchors.margins: 2
            visible: root.hasAvatarImage && avatarSourceImage.status === Image.Ready

            Image {
                id: avatarSourceImage
                anchors.fill: parent
                source: root.avatarSource
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                mipmap: true
                smooth: true
                visible: false
            }

            Rectangle {
                id: avatarMask
                anchors.fill: parent
                radius: width / 2
                visible: false
                antialiasing: true
            }

            OpacityMask {
                anchors.fill: parent
                source: avatarSourceImage
                maskSource: avatarMask
                cached: true
            }
        }

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -1
            visible: !avatarVisual.visible
            text: typeof ProfileConfig.displayName === "string" && ProfileConfig.displayName.length > 0 ? ProfileConfig.displayName.charAt(0).toUpperCase() : "•"
            color: Theme.colors.accentStrong
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 4
            font.bold: true
        }

        MouseArea {
            id: avatarMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                var p = avatarChip.mapToItem(null, avatarChip.width / 2, avatarChip.height);
                root.avatarMenuRequested(p.x, p.y);
            }
        }
    }
    Row {
        id: statsRow
        height: root.height
        spacing: 8

        Repeater {
            model: [
                {
                    icon: "",
                    value: root.stats ? root.stats.cpuPercent : 0,
                    color: Theme.colors.accentStrong
                },
                {
                    icon: "",
                    value: root.stats ? root.stats.memPercent : 0,
                    color: Theme.colors.accent
                }
            ]

            Item {
                id: metricButton
                required property var modelData
                property real metricValue: modelData.value
                property real displayedMetricValue: modelData.value
                property color metricColor: modelData.color

                width: root.height
                height: root.height
                scale: metricMouse.containsMouse ? 1.05 : 1

                onMetricValueChanged: displayedMetricValue = metricValue
                onDisplayedMetricValueChanged: ringCanvas.requestPaint()
                onWidthChanged: ringCanvas.requestPaint()
                onHeightChanged: ringCanvas.requestPaint()

                Behavior on scale {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutQuad
                    }
                }
                Behavior on displayedMetricValue {
                    NumberAnimation {
                        duration: 280
                        easing.type: Easing.OutCubic
                    }
                }

                Canvas {
                    id: ringCanvas
                    anchors.fill: parent
                    antialiasing: true

                    onPaint: {
                        var ctx = getContext("2d");
                        var size = Math.min(width, height);
                        var line = 2.4;
                        var radius = size / 2 - line;
                        var center = size / 2;
                        var start = -Math.PI / 2;
                        var value = Math.max(0, Math.min(100, metricButton.displayedMetricValue));
                        var end = start + Math.PI * 2 * value / 100;

                        ctx.clearRect(0, 0, width, height);
                        ctx.lineCap = "round";
                        ctx.lineWidth = line;

                        ctx.strokeStyle = Theme.colors.barStatusRingTrack;
                        ctx.beginPath();
                        ctx.arc(center, center, radius, 0, Math.PI * 2, false);
                        ctx.stroke();

                        ctx.strokeStyle = metricButton.metricColor;
                        ctx.beginPath();
                        ctx.arc(center, center, radius, start, end, false);
                        ctx.stroke();
                    }

                    Component.onCompleted: requestPaint()
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    radius: Math.min(Theme.uiRadius, height / 2)
                    color: root.systemStatusMenuOpen ? Theme.colors.barStatusCenterActiveBg : Theme.colors.barStatusCenterBg

                    Text {
                        anchors.centerIn: parent
                        text: metricButton.modelData.icon
                        color: metricButton.metricColor
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 5
                    }
                }

                MouseArea {
                    id: metricMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var p = metricButton.mapToItem(null, metricButton.width / 2, metricButton.height);
                        root.systemStatusMenuRequested(p.x, p.y);
                    }
                }
            }
        }
    }

    Row {
        id: windowInfo
        height: root.height
        spacing: 8

        Item {
            width: 18
            height: parent.height

            Text {
                anchors.centerIn: parent
                text: root.windowGlyph
                color: Theme.colors.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 5
                font.bold: true
            }
        }

        Item {
            id: windowTextBox
            width: 176
            height: parent.height

            Column {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                spacing: -2

                Text {
                    width: windowTextBox.width
                    text: root.windowMeta
                    color: Theme.colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 7
                    elide: Text.ElideRight
                }

                Text {
                    width: windowTextBox.width
                    text: root.windowTitle
                    color: Theme.colors.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 4
                    font.bold: true
                    elide: Text.ElideRight
                }
            }
        }
    }
}
