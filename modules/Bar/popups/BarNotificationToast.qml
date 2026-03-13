pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import "../../Theme/theme.js" as Theme
import "../../Theme/barPopupStyle.js" as PopupStyle
import "../widgets/panels"

Scope {
    id: root

    required property var barState

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: notificationToast

            required property var modelData
            screen: modelData
            property bool retainVisible: root.barState.notificationToastOpen

            visible: (root.barState.notificationToastOpen || notificationToast.retainVisible) && root.barState.toastScreen === modelData
            color: "transparent"
            implicitWidth: root.barState.notificationToastWidth
            implicitHeight: toastCard.implicitHeight

            anchors {
                top: true
                right: true
            }

            margins {
                top: Theme.popupTopMargin
                right: PopupStyle.panel.toast.marginRight
            }

            Connections {
                target: root.barState

                function onNotificationToastOpenChanged() {
                    if (root.barState.notificationToastOpen) {
                        notificationToast.retainVisible = true;
                        notificationToastCloseTimer.stop();
                    } else {
                        notificationToast.retainVisible = true;
                        notificationToastCloseTimer.stop();
                        notificationToastCloseTimer.start();
                    }
                }
            }

            Timer {
                id: notificationToastCloseTimer
                interval: 220
                repeat: false
                onTriggered: notificationToast.retainVisible = false
            }

            NotificationToast {
                id: toastCard
                anchors.fill: parent
                open: root.barState.notificationToastOpen
                notification: root.barState.notificationToastHandle
                onCloseRequested: {
                    if (root.barState.notificationToastHandle && root.barState.notificationToastHandle.dismiss)
                        root.barState.notificationToastHandle.dismiss();
                    root.barState.notificationToastOpen = false;
                }
            }
        }
    }
}
