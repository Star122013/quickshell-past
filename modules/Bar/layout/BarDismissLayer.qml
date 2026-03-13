pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

Scope {
    id: root

    required property var barState

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: dismissLayer

            required property var modelData
            screen: modelData

            visible: root.barState.anyPopupOpen
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            mask: Region {
                x: 0
                y: 0
                width: dismissLayer.width
                height: dismissLayer.height

                Region {
                    intersection: Intersection.Subtract
                    x: root.barState.trayMenuOpen && root.barState.trayMenuScreen === modelData  ? root.barState.trayMenuX : 0
                    y: root.barState.trayMenuOpen && root.barState.trayMenuScreen === modelData ? root.barState.trayMenuY : 0
                    width: root.barState.trayMenuOpen && root.barState.trayMenuScreen === modelData ? root.barState.trayMenuHitWidth : 0
                    height: root.barState.trayMenuOpen && root.barState.trayMenuScreen === modelData ? root.barState.trayMenuHitHeight : 0
                }

                Region {
                    intersection: Intersection.Subtract
                    x: root.barState.systemStatusMenuOpen && root.barState.popupScreen === modelData ? root.barState.systemStatusMenuX : 0
                    y: root.barState.systemStatusMenuOpen && root.barState.popupScreen === modelData ? root.barState.systemStatusMenuY : 0
                    width: root.barState.systemStatusMenuOpen && root.barState.popupScreen === modelData ? root.barState.systemStatusMenuWidth : 0
                    height: root.barState.systemStatusMenuOpen && root.barState.popupScreen === modelData ? root.barState.systemStatusMenuHeight : 0
                }

                Region {
                    intersection: Intersection.Subtract
                    x: root.barState.avatarMenuOpen && root.barState.popupScreen === modelData ? root.barState.avatarMenuX : 0
                    y: root.barState.avatarMenuOpen && root.barState.popupScreen === modelData ? root.barState.avatarMenuY : 0
                    width: root.barState.avatarMenuOpen && root.barState.popupScreen === modelData ? root.barState.avatarMenuWidth : 0
                    height: root.barState.avatarMenuOpen && root.barState.popupScreen === modelData ? root.barState.avatarMenuHeight : 0
                }

                Region {
                    intersection: Intersection.Subtract
                    x: root.barState.avatarSubmenuOpen && root.barState.popupScreen === modelData ? root.barState.avatarSubmenuX : 0
                    y: root.barState.avatarSubmenuOpen && root.barState.popupScreen === modelData ? root.barState.avatarSubmenuY : 0
                    width: root.barState.avatarSubmenuOpen && root.barState.popupScreen === modelData ? root.barState.avatarSubmenuWidth : 0
                    height: root.barState.avatarSubmenuOpen && root.barState.popupScreen === modelData ? root.barState.avatarSubmenuHeight : 0
                }

                Region {
                    intersection: Intersection.Subtract
                    x: root.barState.mediaMenuOpen && root.barState.popupScreen === modelData ? root.barState.mediaMenuX : 0
                    y: root.barState.mediaMenuOpen && root.barState.popupScreen === modelData ? root.barState.mediaMenuY : 0
                    width: root.barState.mediaMenuOpen && root.barState.popupScreen === modelData ? root.barState.mediaMenuWidth : 0
                    height: root.barState.mediaMenuOpen && root.barState.popupScreen === modelData ? root.barState.mediaMenuHeight : 0
                }

                Region {
                    intersection: Intersection.Subtract
                    x: root.barState.controlHubOpen && root.barState.popupScreen === modelData ? root.barState.controlHubX : 0
                    y: root.barState.controlHubOpen && root.barState.popupScreen === modelData ? root.barState.controlHubY : 0
                    width: root.barState.controlHubOpen && root.barState.popupScreen === modelData ? root.barState.controlHubWidth : 0
                    height: root.barState.controlHubOpen && root.barState.popupScreen === modelData ? root.barState.controlHubHeight : 0
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onPressed: function (mouse) {
                    root.barState.popupController.closeAllPopups();
                }
            }
        }
    }
}
