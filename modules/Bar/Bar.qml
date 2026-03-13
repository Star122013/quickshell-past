pragma ComponentBehavior: Bound

import Quickshell

import "../Theme/theme.js" as Theme
import "../Theme/barPopupStyle.js" as PopupStyle
import "controllers"
import "layout"
import "popups"

Scope {
    id: root

    required property var niri
    required property var notifications
    required property var stats
    required property var audio
    required property var brightness
    required property var wifi

    property var popupController: popupControllerImpl

    property bool mediaMenuOpen: false
    property bool controlHubOpen: false
    property bool trayMenuOpen: false
    property bool systemStatusMenuOpen: false
    property bool notificationToastOpen: false
    property bool avatarMenuOpen: false
    property bool avatarSubmenuOpen: false
    property bool doNotDisturbEnabled: false

    property var trayMenuHandle: null
    property real trayMenuX: 0
    property real trayMenuY: 0
    property real trayMenuHitWidth: PopupStyle.panel.tray.hitWidth
    property real trayMenuHitHeight: PopupStyle.panel.tray.hitHeight

    property real mediaMenuX: 0
    property real mediaMenuY: 0
    property real systemStatusMenuX: 0
    property real systemStatusMenuY: 0
    property real avatarMenuX: 0
    property real avatarMenuY: 0
    property real avatarMenuWidth: Theme.profileMenuWidth
    property real avatarMenuHeight: Theme.profileMenuHeight
    property real avatarSubmenuX: 0
    property real avatarSubmenuY: 0
    property real avatarSubmenuWidth: 0
    property real avatarSubmenuHeight: 0

    property real systemStatusMenuWidth: PopupStyle.panel.systemStatus.width
    property real systemStatusMenuHeight: PopupStyle.panel.systemStatus.height
    property real mediaMenuWidth: PopupStyle.panel.media.width
    property real mediaMenuHeight: PopupStyle.panel.media.height
    property real volumeMenuWidth: PopupStyle.panel.leftSubmenu.volume.width
    property real volumeMenuHeight: PopupStyle.panel.leftSubmenu.volume.height
    property real wifiMenuWidth: PopupStyle.panel.leftSubmenu.wifi.width
    property real wifiMenuHeight: PopupStyle.panel.leftSubmenu.wifi.height
    property real bluetoothMenuWidth: PopupStyle.panel.leftSubmenu.bluetooth.width
    property real bluetoothMenuHeight: PopupStyle.panel.leftSubmenu.bluetooth.height
    property real powerMenuWidth: PopupStyle.panel.leftSubmenu.power.width
    property real powerMenuHeight: PopupStyle.panel.leftSubmenu.power.height
    property real notificationMenuWidth: PopupStyle.panel.leftSubmenu.notifications.width
    property real notificationMenuHeight: PopupStyle.panel.leftSubmenu.notifications.height

    property real controlHubX: 0
    property real controlHubY: 0
    property real controlHubWidth: PopupStyle.panel.controlHub.width
    property real controlHubHeight: PopupStyle.panel.controlHub.height
    property string controlHubSection: "sound"
    property string avatarSubmenuSection: ""

    property var trayMenuScreen: null
    property var popupScreen: null
    property var toastScreen: null
    property var notificationToastHandle: null
    property real notificationToastWidth: PopupStyle.panel.toast.width

    property bool anyPopupOpen: root.mediaMenuOpen || root.controlHubOpen || root.trayMenuOpen || root.systemStatusMenuOpen || root.avatarMenuOpen || root.avatarSubmenuOpen

    BarPopupController {
        id: popupControllerImpl
        barState: root
    }

    BarNotificationController {
        barState: root
    }

    Variants {
        model: Quickshell.screens

        BarScreen {
            barState: root
        }
    }

    BarDismissLayer {
        barState: root
    }

    BarPopupWindows {
        barState: root
    }

    BarProfilePopupWindows {
        barState: root
    }

    BarNotificationToast {
        barState: root
    }
}
