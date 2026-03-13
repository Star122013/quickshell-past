pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import "../../Theme/barPopupStyle.js" as PopupStyle
import "barUtils.js" as BarUtils

Scope {
    id: root

    required property var barState

    function showNotificationToast(notification) {
        if (!notification || root.barState.doNotDisturbEnabled)
            return;
        root.barState.notificationToastHandle = notification;
        if (!root.barState.toastScreen && Quickshell.screens && Quickshell.screens.length > 0)
            root.barState.toastScreen = Quickshell.screens[0];
        notificationToastHideTimer.stop();
        notificationToastShowTimer.stop();
        root.barState.notificationToastOpen = false;
        notificationToastShowTimer.start();
    }

    Connections {
        target: root.barState.notifications

        function onNotification(notification) {
            root.showNotificationToast(notification);
        }
    }

    Timer {
        id: notificationToastShowTimer
        interval: 1
        repeat: false
        onTriggered: {
            root.barState.notificationToastOpen = true;
            notificationToastHideTimer.interval = BarUtils.notificationToastTimeout(root.barState.notificationToastHandle, PopupStyle.panel.toast.timeout, PopupStyle.panel.toast.minimumTimeout);
            notificationToastHideTimer.start();
        }
    }

    Timer {
        id: notificationToastHideTimer
        interval: PopupStyle.panel.toast.timeout
        repeat: false
        onTriggered: root.barState.notificationToastOpen = false
    }
}
