pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import "../../Theme/theme.js" as Theme
import "../../Theme/barPopupStyle.js" as PopupStyle
import "../controllers/barUtils.js" as BarUtils
import "../sections"
import "../widgets/chrome"

PanelWindow {
    id: panel

    required property var barState
    property var modelData: null
    screen: modelData

    Component.onCompleted: if (!barState.toastScreen)
        barState.toastScreen = panel.modelData

    color: "transparent"
    implicitHeight: Theme.barHeight + Theme.barBottomSpacing + Theme.barOuterCornerHeight + Theme.barTopMargin

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: Theme.barTopMargin
        left: 0
        right: 0
    }

    exclusiveZone: Theme.barHeight + Theme.barBottomSpacing + Theme.barTopMargin

    Item {
        id: frame
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Theme.barHeight

        Rectangle {
            id: barShell
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Theme.barHeight
            radius: 0
            color: Theme.colors.surface
            border.width: 0
        }

        Rectangle {
            anchors.fill: barShell
            anchors.margins: 1
            radius: 0
            color: Theme.colors.barShellOverlay
            border.width: 0
        }

        BarOuterCorner {
            width: Theme.barOuterCornerWidth
            height: Theme.barOuterCornerHeight
            anchors.left: barShell.left
            anchors.top: barShell.bottom
            anchors.topMargin: -1
            rightSide: false
            fillColor: Theme.colors.surface
            z: 2
        }

        BarOuterCorner {
            width: Theme.barOuterCornerWidth
            height: Theme.barOuterCornerHeight
            anchors.right: barShell.right
            anchors.top: barShell.bottom
            anchors.topMargin: -1
            rightSide: true
            fillColor: Theme.colors.surface
            z: 2
        }

        LeftSection {
            id: left
            anchors.left: barShell.left
            anchors.leftMargin: Theme.innerGap
            anchors.verticalCenter: barShell.verticalCenter
            niri: barState.niri
            stats: barState.stats
            systemStatusMenuOpen: barState.systemStatusMenuOpen && barState.popupScreen === panel.modelData
            onAvatarMenuRequested: function (x, y) {
                var w = barState.avatarMenuWidth;
                var wasOpen = barState.avatarMenuOpen && barState.popupScreen === panel.modelData;
                barState.popupController.closeAllPopups();
                if (wasOpen)
                    return;
                barState.popupScreen = panel.modelData;
                barState.avatarMenuX = BarUtils.avatarMenuLeft(x, w, panel.modelData.width, Theme.outerGap, Theme.profileMenuMarginLeft, PopupStyle.panel.avatar.anchorOffset);
                barState.avatarMenuY = Theme.popupTopMargin;
                barState.avatarMenuOpen = true;
            }
            onSystemStatusMenuRequested: function (x, y) {
                var w = barState.systemStatusMenuWidth;
                var wasOpen = barState.systemStatusMenuOpen && barState.popupScreen === panel.modelData;
                barState.popupController.closeAllPopups();
                if (wasOpen)
                    return;
                barState.popupScreen = panel.modelData;
                barState.systemStatusMenuX = BarUtils.popupLeft(x, w, panel.modelData.width, Theme.outerGap);
                barState.systemStatusMenuY = BarUtils.popupTop(Theme.popupTopMargin);
                barState.systemStatusMenuOpen = true;
            }
        }

        RightSection {
            id: right
            anchors.right: barShell.right
            anchors.rightMargin: Theme.innerGap
            anchors.verticalCenter: barShell.verticalCenter
            notifications: barState.notifications
            audio: barState.audio
            wifi: barState.wifi
            panelWindow: panel
            mediaMenuOpen: barState.mediaMenuOpen
            notificationCenterOpen: barState.controlHubOpen && barState.controlHubSection === "notifications"
            volumeMenuOpen: barState.controlHubOpen && barState.controlHubSection === "sound"
            wifiMenuOpen: barState.controlHubOpen && barState.controlHubSection === "wifi"
            bluetoothMenuOpen: barState.controlHubOpen && barState.controlHubSection === "bluetooth"
            powerMenuOpen: barState.controlHubOpen && barState.controlHubSection === "power"
            onNotificationMenuRequested: function (x, y) {
                barState.popupController.openControlHub(panel.modelData, "notifications");
            }
            onClearNotifications: BarUtils.dismissTrackedNotifications(barState.notifications)
            onMediaMenuRequested: function (x, y) {
                var w = barState.mediaMenuWidth;
                var wasOpen = barState.mediaMenuOpen && barState.popupScreen === panel.modelData;
                barState.popupController.closeAllPopups();
                if (wasOpen)
                    return;
                barState.popupScreen = panel.modelData;
                barState.mediaMenuX = BarUtils.popupLeft(x, w, panel.modelData.width, Theme.outerGap);
                barState.mediaMenuY = BarUtils.popupTop(Theme.popupTopMargin);
                barState.mediaMenuOpen = true;
            }
            onTrayMenuRequested: function (menu, x, y) {
                var sameMenu = barState.trayMenuOpen && barState.trayMenuHandle === menu && barState.trayMenuScreen === panel.modelData;
                if (sameMenu) {
                    barState.trayMenuOpen = false;
                    return;
                }
                barState.popupController.closeAllPopups();
                barState.trayMenuHandle = menu;
                barState.trayMenuX = BarUtils.popupLeft(x, PopupStyle.panel.tray.width, panel.modelData.width, Theme.outerGap);
                barState.trayMenuY = BarUtils.popupTop(Theme.popupTopMargin);
                barState.trayMenuHitWidth = PopupStyle.panel.tray.hitWidth;
                barState.trayMenuHitHeight = PopupStyle.panel.tray.hitHeight;
                barState.trayMenuScreen = panel.modelData;
                barState.popupScreen = panel.modelData;
                barState.trayMenuOpen = true;
            }
            onVolumeMenuRequested: function (x, y) {
                barState.popupController.openControlHub(panel.modelData, "sound");
            }
            onVolumeStep: function (delta) {
                barState.audio.stepVolume(delta);
            }
            onToggleMute: barState.audio.toggleMute()
            onWifiMenuRequested: function (x, y) {
                barState.popupController.openControlHub(panel.modelData, "wifi");
            }
            onBluetoothMenuRequested: function (x, y) {
                barState.popupController.openControlHub(panel.modelData, "bluetooth");
            }
            onPowerMenuRequested: function (x, y) {
                barState.popupController.openControlHub(panel.modelData, "power");
            }
        }

        CenterSection {
            anchors.left: left.right
            anchors.right: right.left
            anchors.leftMargin: Theme.innerGap
            anchors.rightMargin: Theme.innerGap
            anchors.verticalCenter: barShell.verticalCenter
            anchors.verticalCenterOffset: 0
            height: barShell.height
            niri: barState.niri
            mediaMenuOpen: barState.mediaMenuOpen
            onToggleMediaMenu: function (x, y) {
                var w = barState.mediaMenuWidth;
                var wasOpen = barState.mediaMenuOpen && barState.popupScreen === panel.modelData;
                barState.popupController.closeAllPopups();
                if (wasOpen)
                    return;
                barState.popupScreen = panel.modelData;
                barState.mediaMenuX = BarUtils.popupLeft(x, w, panel.modelData.width, Theme.outerGap);
                barState.mediaMenuY = BarUtils.popupTop(Theme.popupTopMargin);
                barState.mediaMenuOpen = true;
            }
        }
    }
}
