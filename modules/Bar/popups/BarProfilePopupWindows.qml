pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

import "../../Theme/theme.js" as Theme
import "../../Theme/barPopupStyle.js" as PopupStyle
import "../../Theme/profileMenuConfig.js" as ProfileConfig
import "../controllers/barUtils.js" as BarUtils
import "../widgets/panels"

Scope {
    id: root

    required property var barState

    function setAvatarSubmenuSection(screenModel, section) {
        if (!screenModel)
            return;

        var width = BarUtils.avatarSubmenuWidthFor(section, PopupStyle);
        root.barState.avatarSubmenuSection = section;
        root.barState.avatarSubmenuWidth = width;
        root.barState.avatarSubmenuHeight = BarUtils.avatarSubmenuHeightFor(section, PopupStyle);
        root.barState.avatarSubmenuX = BarUtils.avatarSubmenuLeft(root.barState.avatarMenuX, root.barState.avatarMenuWidth, Theme.popupSideGap, screenModel.width, width, Theme.outerGap);
        root.barState.avatarSubmenuY = Theme.popupTopMargin;
    }

    function openAvatarSubmenu(section) {
        if (!root.barState.popupScreen || !section || section.length === 0)
            return;

        var wasOpen = root.barState.avatarSubmenuOpen && root.barState.avatarSubmenuSection === section;
        if (wasOpen) {
            root.barState.avatarSubmenuOpen = false;
            root.barState.avatarSubmenuSection = "";
            return;
        }

        root.setAvatarSubmenuSection(root.barState.popupScreen, section);
        root.barState.avatarSubmenuOpen = true;
    }

    function triggerProfileMenuItem(item) {
        if (!item)
            return;
        if (item.key === "dnd") {
            root.barState.doNotDisturbEnabled = !root.barState.doNotDisturbEnabled;
            root.barState.notificationToastOpen = false;
            root.barState.avatarSubmenuOpen = false;
            root.barState.avatarSubmenuSection = "";
            return;
        }

        if (item.section && item.section.length > 0) {
            root.openAvatarSubmenu(item.section);
            return;
        }

        if (item.command && item.command.length > 0) {
            profileActionProc.exec(["sh", "-lc", item.command]);
            root.barState.avatarSubmenuOpen = false;
            root.barState.avatarSubmenuSection = "";
            root.barState.avatarMenuOpen = false;
        }
    }

    Process {
        id: profileActionProc
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: profileMenu

            required property var modelData
            screen: modelData

            visible: root.barState.avatarMenuOpen && root.barState.popupScreen === modelData
            color: "transparent"
            implicitWidth: root.barState.avatarMenuWidth
            implicitHeight: root.barState.avatarMenuHeight

            anchors {
                top: true
                left: true
            }

            margins {
                top: root.barState.avatarMenuY
                left: root.barState.avatarMenuX
            }

            ProfileMenu {
                id: profileMenuContent
                anchors.fill: parent
                open: root.barState.avatarMenuOpen
                audio: root.barState.audio
                brightness: root.barState.brightness
                wifi: root.barState.wifi
                doNotDisturbEnabled: root.barState.doNotDisturbEnabled
                onActionRequested: function (key) {
                    root.triggerProfileMenuItem(BarUtils.findItemByKey(ProfileConfig.headerActions, key));
                }
                onTileRequested: function (key) {
                    root.triggerProfileMenuItem(BarUtils.findItemByKey(ProfileConfig.quickTiles, key));
                }
                onImplicitWidthChanged: root.barState.avatarMenuWidth = implicitWidth
                onImplicitHeightChanged: root.barState.avatarMenuHeight = implicitHeight
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: avatarSubmenu

            required property var modelData
            screen: modelData

            visible: root.barState.avatarSubmenuOpen && root.barState.popupScreen === modelData
            color: "transparent"
            implicitWidth: root.barState.avatarSubmenuWidth
            implicitHeight: root.barState.avatarSubmenuHeight

            anchors {
                top: true
                left: true
            }

            margins {
                top: root.barState.avatarSubmenuY
                left: root.barState.avatarSubmenuX
            }

            AvatarSubmenuContent {
                anchors.fill: parent
                open: root.barState.avatarSubmenuOpen
                section: root.barState.avatarSubmenuSection
                audio: root.barState.audio
                wifi: root.barState.wifi
                notifications: root.barState.notifications
                onCloseRequested: root.barState.popupController.closeAllPopups()
            }
        }
    }
}
