pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import "../widgets/panels"

Scope {
    id: root

    required property var barState

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: systemStatusMenu

            required property var modelData
            screen: modelData

            visible: root.barState.systemStatusMenuOpen && root.barState.popupScreen === modelData
            color: "transparent"
            implicitWidth: root.barState.systemStatusMenuWidth
            implicitHeight: root.barState.systemStatusMenuHeight

            anchors {
                top: true
                left: true
            }

            margins {
                top: root.barState.systemStatusMenuY
                left: root.barState.systemStatusMenuX
            }

            SystemStatusMenu {
                anchors.fill: parent
                open: root.barState.systemStatusMenuOpen
                stats: root.barState.stats
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: trayMenuPopup

            required property var modelData
            screen: modelData

            visible: root.barState.trayMenuOpen && root.barState.trayMenuScreen === modelData
            color: "transparent"
            implicitWidth: trayMenuContent.implicitWidth
            implicitHeight: trayMenuContent.implicitHeight

            anchors {
                top: true
                left: true
            }

            margins {
                top: root.barState.trayMenuY
                left: root.barState.trayMenuX
            }

            ThemedTrayMenu {
                id: trayMenuContent
                anchors.fill: parent
                open: root.barState.trayMenuOpen
                menu: root.barState.trayMenuHandle
                onImplicitWidthChanged: root.barState.trayMenuHitWidth = implicitWidth
                onImplicitHeightChanged: root.barState.trayMenuHitHeight = implicitHeight
                onItemTriggered: root.barState.trayMenuOpen = false
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: mediaMenu

            required property var modelData
            screen: modelData
            property bool retainVisible: root.barState.mediaMenuOpen

            visible: (root.barState.mediaMenuOpen || mediaMenu.retainVisible) && root.barState.popupScreen === modelData
            color: "transparent"
            implicitWidth: root.barState.mediaMenuWidth
            implicitHeight: root.barState.mediaMenuHeight

            anchors {
                top: true
                left: true
            }

            margins {
                top: root.barState.mediaMenuY
                left: root.barState.mediaMenuX
            }

            Connections {
                target: root.barState

                function onMediaMenuOpenChanged() {
                    if (root.barState.mediaMenuOpen) {
                        mediaMenu.retainVisible = true;
                        mediaMenuCloseTimer.stop();
                    } else {
                        mediaMenu.retainVisible = true;
                        mediaMenuCloseTimer.stop();
                        mediaMenuCloseTimer.start();
                    }
                }
            }

            Timer {
                id: mediaMenuCloseTimer
                interval: 190
                repeat: false
                onTriggered: mediaMenu.retainVisible = false
            }

            MediaPopup {
                id: mediaPopup
                anchors.fill: parent
                open: root.barState.mediaMenuOpen
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: controlHubMenu

            required property var modelData
            screen: modelData
            property bool retainVisible: root.barState.controlHubOpen

            visible: (root.barState.controlHubOpen || controlHubMenu.retainVisible) && root.barState.popupScreen === modelData
            color: "transparent"
            implicitWidth: root.barState.controlHubWidth
            implicitHeight: root.barState.controlHubHeight

            anchors {
                top: true
                left: true
            }

            margins {
                top: root.barState.controlHubY
                left: root.barState.controlHubX
            }

            Connections {
                target: root.barState

                function onControlHubOpenChanged() {
                    if (root.barState.controlHubOpen) {
                        controlHubMenu.retainVisible = true;
                        controlHubCloseTimer.stop();
                    } else {
                        controlHubMenu.retainVisible = true;
                        controlHubCloseTimer.stop();
                        controlHubCloseTimer.start();
                    }
                }
            }

            Timer {
                id: controlHubCloseTimer
                interval: 190
                repeat: false
                onTriggered: controlHubMenu.retainVisible = false
            }

            ControlHubMenu {
                id: controlHubPopup
                anchors.fill: parent
                open: root.barState.controlHubOpen
                activeSection: root.barState.controlHubSection
                notifications: root.barState.notifications
                audio: root.barState.audio
                wifi: root.barState.wifi
                onSectionRequested: function (section) {
                    root.barState.popupController.setControlHubSection(modelData, section);
                }
                onCloseRequested: root.barState.controlHubOpen = false
            }
        }
    }
}
