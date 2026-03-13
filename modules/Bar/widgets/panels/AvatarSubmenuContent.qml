import QtQuick

Rectangle {
    id: root

    required property bool open
    required property string section
    required property var audio
    required property var wifi
    required property var notifications

    signal closeRequested

    color: "transparent"

    Loader {
        anchors.fill: parent
        sourceComponent: {
            if (root.section === "wifi")
                return wifiPage;
            if (root.section === "sound")
                return volumePage;
            if (root.section === "bluetooth")
                return bluetoothPage;
            if (root.section === "notifications")
                return notificationsPage;
            if (root.section === "power")
                return powerPage;
            return null;
        }
    }

    Component {
        id: wifiPage

        WifiMenu {
            anchors.fill: parent
            open: root.open
            compactMode: true
            wifi: root.wifi
        }
    }

    Component {
        id: volumePage

        VolumeMenu {
            anchors.fill: parent
            open: root.open
            compactMode: true
            audio: root.audio
        }
    }

    Component {
        id: bluetoothPage

        BluetoothMenu {
            anchors.fill: parent
            open: root.open
            compactMode: true
        }
    }

    Component {
        id: notificationsPage

        NotificationCenter {
            anchors.fill: parent
            open: root.open
            notifications: root.notifications
        }
    }

    Component {
        id: powerPage

        PowerMenu {
            anchors.fill: parent
            open: root.open
            compactMode: true
            onActionTriggered: root.closeRequested()
        }
    }
}
