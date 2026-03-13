pragma ComponentBehavior: Bound

import Quickshell.Bluetooth
import QtQuick
import Qt5Compat.GraphicalEffects

import "../../../Theme/theme.js" as Theme
import "../../../Theme/profileMenuConfig.js" as ProfileConfig
import "../../../Theme/profileMenuStyle.js" as Style

Rectangle {
    id: root

    required property bool open
    required property var audio
    required property var brightness
    required property var wifi
    required property bool doNotDisturbEnabled

    signal closeRequested
    signal actionRequested(string key)
    signal tileRequested(string key)

    property real popupScale: root.open ? 1 : 0.982
    property var adapter: Bluetooth.defaultAdapter
    property var devices: root.adapter && root.adapter.devices && root.adapter.devices.values ? root.adapter.devices.values : []
    property string avatarSource: {
        if (typeof ProfileConfig.profileImagePath === "string" && ProfileConfig.profileImagePath.length > 0)
            return root.resolveProfileConfigPath(ProfileConfig.profileImagePath);
        if (typeof Theme.avatarImagePath === "string" && Theme.avatarImagePath.length > 0)
            return root.resolveProfileConfigPath(Theme.avatarImagePath);
        return "";
    }
    property string greetingImageSource: typeof ProfileConfig.greetingImagePath === "string" ? root.resolveProfileConfigPath(ProfileConfig.greetingImagePath) : ""
    property int volumePercent: root.audio && root.audio.volumePercent !== undefined ? Math.max(0, Math.min(100, root.audio.volumePercent)) : 0
    property int brightnessPercent: root.brightness && root.brightness.brightnessPercent !== undefined ? Math.max(0, Math.min(100, root.brightness.brightnessPercent)) : Math.max(0, Math.min(100, ProfileConfig.brightnessPercent))
    property real displayedVolumePercent: 0
    property real displayedBrightnessPercent: 0
    property bool volumeSliderDragging: false
    property bool brightnessSliderDragging: false
    property string currentTimeText: ""
    property string currentDateText: ""

    function hasUrlScheme(path) {
        return /^[A-Za-z][A-Za-z0-9+.-]*:/.test(path) || path.indexOf("/") === 0;
    }

    function resolveLocalPath(path) {
        if (typeof path !== "string" || path.length === 0)
            return "";
        if (root.hasUrlScheme(path))
            return path;
        return Qt.resolvedUrl(path);
    }

    function resolveProfileConfigPath(path) {
        if (typeof path !== "string" || path.length === 0)
            return "";
        if (root.hasUrlScheme(path))
            return path;
        return Qt.resolvedUrl("../../../Theme/" + path);
    }

    implicitWidth: Theme.profileMenuWidth
    implicitHeight: contentColumn.implicitHeight + Style.layout.padding * 2
    radius: Theme.uiRadius
    color: Theme.colors.profileMenuBg
    border.width: 1
    border.color: Theme.colors.profileMenuBorder
    opacity: root.open ? 1 : 0
    clip: true

    transform: Scale {
        origin.x: 34
        origin.y: 0
        xScale: root.popupScale
        yScale: root.popupScale
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 170
            easing.type: Easing.OutCubic
        }
    }

    Behavior on popupScale {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }



    Component.onCompleted: {
        root.refreshClock();
        root.displayedVolumePercent = root.open ? root.volumePercent : 0;
        root.displayedBrightnessPercent = root.open ? root.brightnessPercent : 0;
    }

    onOpenChanged: {
        root.displayedVolumePercent = root.open ? root.volumePercent : 0;
        root.displayedBrightnessPercent = root.open ? root.brightnessPercent : 0;
    }

    onVolumePercentChanged: {
        if (!root.volumeSliderDragging)
            root.displayedVolumePercent = root.open ? root.volumePercent : 0;
    }

    onBrightnessPercentChanged: {
        if (!root.brightnessSliderDragging)
            root.displayedBrightnessPercent = root.open ? root.brightnessPercent : 0;
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.refreshClock()
    }

    function pad(value) {
        return value < 10 ? "0" + value : String(value);
    }

    function refreshClock() {
        var now = new Date();
        var week = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        root.currentTimeText = root.pad(now.getHours()) + ":" + root.pad(now.getMinutes());
        root.currentDateText = week[now.getDay()];
    }

    function connectedBluetoothName() {
        var i;
        for (i = 0; i < root.devices.length; i++) {
            var device = root.devices[i];
            if (device && device.connected) {
                if (device.name && device.name.length > 0)
                    return device.name;
                if (device.deviceName && device.deviceName.length > 0)
                    return device.deviceName;
            }
        }

        if (root.audio && root.audio.defaultSinkName && root.audio.defaultSinkName.length > 0)
            return root.audio.defaultSinkName;
        return "";
    }

    function tileIsAccent(tile) {
        if (!tile)
            return false;
        if (tile.key === "wifi")
            return root.wifi && root.wifi.enabled && ((root.wifi.connectedSsid && root.wifi.connectedSsid.length > 0) || (root.wifi.networks && root.wifi.networks.length > 0));
        if (tile.key === "audio")
            return root.connectedBluetoothName().length > 0;
        if (tile.key === "dnd")
            return root.doNotDisturbEnabled;
        return !!tile.active || !!tile.accent;
    }

    function tileBackground(tile) {
        return root.tileIsAccent(tile) ? Theme.colors.accent : Theme.colors.profileTileBg;
    }

    function tileTitleColor(tile) {
        return root.tileIsAccent(tile) ? Theme.colors.accentText : Theme.colors.textPrimary;
    }

    function tileTitle(tile) {
        if (!tile)
            return "";
        if (tile.key === "wifi") {
            if (!root.wifi || !root.wifi.enabled)
                return "Wi-Fi Off";
            if (root.wifi.connectedSsid && root.wifi.connectedSsid.length > 0)
                return root.wifi.connectedSsid;
            return tile.title;
        }
        if (tile.key === "audio") {
            var bluetoothName = root.connectedBluetoothName();
            return bluetoothName.length > 0 ? bluetoothName : tile.title;
        }
        if (tile.key === "dnd")
            return root.doNotDisturbEnabled ? "Notifications off" : tile.title;
        return tile.title;
    }

    function greetingTitleText() {
        if (typeof ProfileConfig.greetingTitle === "string" && ProfileConfig.greetingTitle.length > 0)
            return ProfileConfig.greetingTitle;

        var hour = (new Date()).getHours();
        if (hour < 11)
            return "Good morning";
        if (hour < 18)
            return "Good afternoon";
        return "Good evening";
    }

    function greetingMessageText() {
        if (typeof ProfileConfig.greetingMessage === "string" && ProfileConfig.greetingMessage.length > 0)
            return ProfileConfig.greetingMessage;
        return "Take a breath, tune your setup, and enjoy the rest of the day.";
    }

    function setVolumeFromPosition(position, width) {
        if (width <= 0)
            return;
        var percent = Math.max(0, Math.min(100, Math.round(position / width * 100)));
        root.displayedVolumePercent = percent;
        if (root.audio && root.audio.setVolumePercent)
            root.audio.setVolumePercent(percent);
    }

    function setBrightnessFromPosition(position, width) {
        if (width <= 0)
            return;
        var percent = Math.max(1, Math.min(100, Math.round(position / width * 100)));
        root.displayedBrightnessPercent = percent;
        if (root.brightness && root.brightness.setBrightnessPercent)
            root.brightness.setBrightnessPercent(percent);
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        color: Theme.colors.profileMenuInnerOverlay
        border.width: 0
    }

    Column {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Style.layout.padding
        spacing: Style.layout.spacing

        Row {
            id: headerRow
            width: parent.width
            spacing: 14

            Rectangle {
                id: headerAvatar
                width: Style.header.avatarSize
                height: Style.header.avatarSize
                radius: Style.header.avatarRadius()
                color: Theme.colors.profileHeaderAvatarShell
                border.width: 0
                clip: true
                antialiasing: true

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Style.header.avatarInset
                    radius: Style.header.avatarImageRadius()
                    color: Theme.colors.profileHeaderAvatarInner
                    clip: true
                    antialiasing: true
                    Item {
                        id: headerAvatarVisual
                        anchors.fill: parent
                        visible: root.avatarSource.length > 0 && headerAvatarImage.status === Image.Ready

                        Image {
                            id: headerAvatarImage
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
                            id: headerAvatarMask
                            anchors.fill: parent
                            radius: Style.header.avatarImageRadius()
                            visible: false
                            antialiasing: true
                        }

                        OpacityMask {
                            anchors.fill: parent
                            source: headerAvatarImage
                            maskSource: headerAvatarMask
                            cached: true
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !headerAvatarVisual.visible
                        text: ProfileConfig.displayName && ProfileConfig.displayName.length > 0 ? ProfileConfig.displayName.charAt(0).toUpperCase() : "•"
                        color: Theme.colors.accentStrong
                        font.family: Theme.fontFamily
                        font.pixelSize: Style.header.titleSize - 2
                        font.bold: true
                    }
                }
            }

            Item {
                width: headerRow.width - headerAvatar.width - headerControls.width - 28
                height: headerAvatar.height

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    spacing: 6

                    Text {
                        width: parent.width
                        text: ProfileConfig.displayName
                        color: Theme.colors.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Style.header.titleSize
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Row {
                        spacing: 6

                        Text {
                            text: ProfileConfig.statusIcon
                            color: Theme.colors.info
                            font.family: Theme.fontFamily
                            font.pixelSize: Style.header.statusIconSize
                        }

                        Text {
                            text: ProfileConfig.statusText
                            color: Theme.colors.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Style.header.statusTextSize
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            Row {
                id: headerControls
                anchors.verticalCenter: headerAvatar.verticalCenter
                spacing: 10

                Rectangle {
                    width: Style.header.clockWidth
                    height: Style.header.clockHeight
                    radius: Style.header.clockRadius()
                    color: Theme.colors.profileClockBg
                    border.width: 1
                    border.color: Theme.colors.profileClockBorder

                    Column {
                        anchors.centerIn: parent
                        spacing: -1

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.currentTimeText
                            color: Theme.colors.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Style.header.clockTimeSize
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.currentDateText
                            color: Theme.colors.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Style.header.clockDateSize
                        }
                    }
                }

                Repeater {
                    model: ProfileConfig.headerActions

                    Rectangle {
                        id: actionButton
                        required property var modelData
                        property bool hovered: actionMouse.containsMouse

                        width: Style.header.actionSize
                        height: Style.header.actionSize
                        radius: Style.header.actionRadius()
                        color: hovered ? Theme.colors.profileActionHoverBg : Theme.colors.profileActionBg
                        border.width: 1
                        border.color: Theme.colors.profileActionBorder

                        Behavior on color {
                            ColorAnimation {
                                duration: 130
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: actionButton.modelData.icon
                            color: Theme.colors.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Style.header.actionIconSize
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.actionRequested(actionButton.modelData.key)
                        }
                    }
                }
            }
        }

        Grid {
            id: quickTilesGrid
            width: parent.width
            columns: 2
            columnSpacing: Style.tile.gap
            rowSpacing: Style.tile.gap

            Repeater {
                model: ProfileConfig.quickTiles

                Rectangle {
                    id: quickTile
                    required property var modelData
                    property bool hovered: tileMouse.containsMouse

                    width: (quickTilesGrid.width - quickTilesGrid.columnSpacing) / 2
                    height: Style.tile.height
                    radius: Style.tile.radius()
                    color: root.tileBackground(modelData)
                    border.width: hovered ? 1 : 0
                    border.color: root.tileIsAccent(modelData) ? Theme.colors.profileTileAccentBorder : Theme.colors.profileTileBorder

                    Behavior on color {
                        ColorAnimation {
                            duration: 140
                        }
                    }

                    Rectangle {
                        width: Style.tile.iconBadgeSize
                        height: Style.tile.iconBadgeSize
                        radius: Style.tile.iconBadgeRadius()
                        anchors.left: parent.left
                        anchors.leftMargin: Style.tile.padding
                        anchors.top: parent.top
                        anchors.topMargin: Style.tile.padding
                        color: root.tileIsAccent(quickTile.modelData) ? Theme.colors.profileTileAccentBadgeBg : Theme.colors.profileTileBadgeBg

                        Text {
                            anchors.centerIn: parent
                            text: quickTile.modelData.icon
                            color: root.tileTitleColor(quickTile.modelData)
                            font.family: Theme.fontFamily
                            font.pixelSize: Style.tile.iconSize
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: Style.tile.padding
                        anchors.right: parent.right
                        anchors.rightMargin: Style.tile.padding
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Style.tile.titleBottomMargin
                        text: root.tileTitle(quickTile.modelData)
                        color: root.tileTitleColor(quickTile.modelData)
                        font.family: Theme.fontFamily
                        font.pixelSize: Style.tile.titleSize
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: tileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.tileRequested(quickTile.modelData.key)
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Qt.alpha(Theme.colors.profileDivider, Style.layout.dividerOpacity)
        }

        Column {
            width: parent.width
            spacing: Style.layout.spacing

            Item {
                width: parent.width
                height: 48

                Row {
                    width: parent.width
                    anchors.top: parent.top

                    Text {
                        text: "󰕾  Volume"
                        color: Theme.colors.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 1
                        font.bold: true
                    }

                    Item {
                        width: parent.width - volumeValue.implicitWidth - 96
                        height: 1
                    }

                    Text {
                        id: volumeValue
                        text: Math.round(root.displayedVolumePercent) + "%"
                        color: Theme.colors.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                    }
                }

                Item {
                    width: parent.width
                    height: 22
                    anchors.bottom: parent.bottom

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: Style.slider.trackHeight
                        radius: Style.slider.trackRadius()
                        color: Theme.colors.profileSliderTrack
                    }

                    Rectangle {
                        id: volumeFill
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.max(Style.slider.trackHeight, parent.width * root.displayedVolumePercent / 100)
                        height: Style.slider.trackHeight
                        radius: Style.slider.trackRadius()
                        color: Theme.colors.accent

                        Behavior on width {
                            enabled: !root.volumeSliderDragging

                            NumberAnimation {
                                duration: Style.slider.animationDuration
                                easing.type: Easing.OutQuart
                            }
                        }
                    }

                    Rectangle {
                        id: volumeHandle
                        x: Math.max(0, Math.min(parent.width - width, parent.width * root.displayedVolumePercent / 100 - width / 2))
                        anchors.verticalCenter: parent.verticalCenter
                        width: Style.slider.handleWidth
                        height: Style.slider.handleHeight
                        radius: Style.slider.handleRadius()
                        color: Theme.colors.accentStrong

                        Behavior on x {
                            enabled: !root.volumeSliderDragging

                            NumberAnimation {
                                duration: Style.slider.animationDuration
                                easing.type: Easing.OutQuart
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: {
                            root.volumeSliderDragging = true;
                            root.setVolumeFromPosition(mouseX, width);
                        }
                        onReleased: root.volumeSliderDragging = false
                        onCanceled: root.volumeSliderDragging = false
                        onPositionChanged: if (pressed)
                            root.setVolumeFromPosition(mouseX, width)
                    }
                }
            }

            Item {
                width: parent.width
                height: 48

                Row {
                    width: parent.width
                    anchors.top: parent.top

                    Text {
                        text: "󰃠  Brightness"
                        color: Theme.colors.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 1
                        font.bold: true
                    }

                    Item {
                        width: parent.width - brightnessValue.implicitWidth - 128
                        height: 1
                    }

                    Text {
                        id: brightnessValue
                        text: Math.round(root.displayedBrightnessPercent) + "%"
                        color: Theme.colors.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                    }
                }

                Item {
                    width: parent.width
                    height: 22
                    anchors.bottom: parent.bottom

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: Style.slider.trackHeight
                        radius: Style.slider.trackRadius()
                        color: Theme.colors.profileSliderTrack
                    }

                    Rectangle {
                        id: brightnessFill
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.max(Style.slider.trackHeight, parent.width * root.displayedBrightnessPercent / 100)
                        height: Style.slider.trackHeight
                        radius: Style.slider.trackRadius()
                        color: Theme.colors.accent

                        Behavior on width {
                            enabled: !root.brightnessSliderDragging

                            NumberAnimation {
                                duration: Style.slider.animationDuration
                                easing.type: Easing.OutQuart
                            }
                        }
                    }

                    Rectangle {
                        id: brightnessHandle
                        x: Math.max(0, Math.min(parent.width - width, parent.width * root.displayedBrightnessPercent / 100 - width / 2))
                        anchors.verticalCenter: parent.verticalCenter
                        width: Style.slider.handleWidth
                        height: Style.slider.handleHeight
                        radius: Style.slider.handleRadius()
                        color: Theme.colors.accentStrong

                        Behavior on x {
                            enabled: !root.brightnessSliderDragging

                            NumberAnimation {
                                duration: Style.slider.animationDuration
                                easing.type: Easing.OutQuart
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: {
                            root.brightnessSliderDragging = true;
                            root.setBrightnessFromPosition(mouseX, width);
                        }
                        onReleased: root.brightnessSliderDragging = false
                        onCanceled: root.brightnessSliderDragging = false
                        onPositionChanged: if (pressed)
                            root.setBrightnessFromPosition(mouseX, width)
                        onWheel: function(wheel) {
                            if (root.brightness && root.brightness.stepBrightness)
                                root.brightness.stepBrightness(wheel.angleDelta.y > 0 ? 4 : -4);
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Qt.alpha(Theme.colors.profileDivider, Style.layout.dividerOpacity)
        }

        Rectangle {
            width: parent.width
            height: Style.greeting.cardHeight
            radius: Style.greeting.cardRadius()
            color: Theme.colors.profileGreetingBg
            border.width: 1
            border.color: Theme.colors.profileGreetingBorder
            clip: true

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius - 1
                color: Theme.colors.profileGreetingInner
                border.width: 0
            }

            Item {
                anchors.fill: parent
                anchors.margins: Style.greeting.cardPadding

                Column {
                    id: greetingTextColumn
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.right: greetingArtworkFrame.left
                    anchors.rightMargin: Style.greetingContentSpacing
                    spacing: 10

                    Text {
                        width: parent.width
                        text: root.greetingTitleText()
                        color: Theme.colors.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Style.greeting.titleSize
                        font.bold: true
                        wrapMode: Text.Wrap
                    }

                    Text {
                        width: parent.width
                        text: root.greetingMessageText()
                        color: Theme.colors.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Style.greeting.messageSize
                        wrapMode: Text.Wrap
                        maximumLineCount: Style.greetingMessageMaxLines
                    }
                }

                Rectangle {
                    id: greetingArtworkFrame
                    width: Style.greeting.artworkWidth
                    height: Style.greeting.artworkHeight
                    radius: Style.greeting.artworkRadius()
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    color: Theme.colors.profileGreetingArtworkBg
                    border.width: 1
                    border.color: Theme.colors.profileGreetingArtworkBorder
                    clip: true

                    Item {
                        id: greetingArtworkVisual
                        anchors.fill: parent
                        anchors.margins: Style.greeting.artworkInset
                        visible: root.greetingImageSource.length > 0 && greetingImage.status === Image.Ready

                        Image {
                            id: greetingImage
                            anchors.fill: parent
                            source: root.greetingImageSource
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            mipmap: true
                            smooth: true
                            visible: false
                        }

                        Rectangle {
                            id: greetingImageMask
                            anchors.fill: parent
                            radius: Math.max(0, Style.greeting.artworkRadius() - Style.greeting.artworkInset)
                            visible: false
                            antialiasing: true
                        }

                        OpacityMask {
                            anchors.fill: parent
                            source: greetingImage
                            maskSource: greetingImageMask
                            cached: true
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: typeof ProfileConfig.greetingPatternText === "string" && ProfileConfig.greetingPatternText.length > 0 ? ProfileConfig.greetingPatternText : "✦"
                        color: Theme.colors.accentStrong
                        font.family: Theme.fontFamily
                        font.pixelSize: Style.greeting.patternSize
                        visible: !greetingArtworkVisual.visible
                    }
                }
            }
        }
    }
}
