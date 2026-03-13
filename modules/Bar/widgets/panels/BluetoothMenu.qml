import Quickshell.Bluetooth
import QtQuick

import "../../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property bool open
  property bool compactMode: false
  property real popupScale: root.open ? 1 : 0.96
  property var adapter: Bluetooth.defaultAdapter
  property var devices: root.adapter && root.adapter.devices && root.adapter.devices.values ? root.adapter.devices.values : []
  property int connectedCount: {
    var count = 0
    var i
    for (i = 0; i < root.devices.length; i++) {
      if (root.devices[i] && root.devices[i].connected) count++
    }
    return count
  }
  property var sortedDevices: {
    var list = []
    var i
    for (i = 0; i < root.devices.length; i++) {
      if (root.devices[i]) list.push(root.devices[i])
    }

    list.sort(function(left, right) {
      var leftRank = root.deviceRank(left)
      var rightRank = root.deviceRank(right)
      if (leftRank !== rightRank) return leftRank - rightRank

      var leftName = root.deviceName(left).toLowerCase()
      var rightName = root.deviceName(right).toLowerCase()
      if (leftName < rightName) return -1
      if (leftName > rightName) return 1
      return 0
    })

    return list
  }

  radius: Theme.radiusMd
  color: Theme.colors.surface
  border.width: 1
  border.color: Theme.colors.surfaceRaised
  opacity: root.open ? 1 : 0

  transform: Scale {
    origin.x: root.width
    origin.y: 0
    xScale: root.popupScale
    yScale: root.popupScale
  }

  Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
  Behavior on popupScale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

  function deviceRank(device) {
    if (!device) return 9
    if (device.connected) return 0
    if (device.state === BluetoothDeviceState.Connecting) return 1
    if (device.pairing) return 2
    if (device.paired) return 3
    return 4
  }

  function deviceName(device) {
    if (!device) return "Unknown"
    if (device.name && device.name.length > 0) return device.name
    if (device.deviceName && device.deviceName.length > 0) return device.deviceName
    return device.address || "Unknown"
  }

  function statusText() {
    if (!root.adapter) return "No adapter"
    if (!root.adapter.enabled) return "Bluetooth is off"
    if (root.adapter.discovering) return "Scanning nearby devices"
    if (root.connectedCount > 0) return root.connectedCount + " device" + (root.connectedCount > 1 ? "s" : "") + " connected"
    return "Ready"
  }

  function batteryText(device) {
    if (!device || !device.batteryAvailable) return ""
    var percent = device.battery <= 1 ? Math.round(device.battery * 100) : Math.round(device.battery)
    return percent + "%"
  }

  function deviceSubtitle(device) {
    if (!device) return ""

    var parts = []
    if (device.connected) parts.push("Connected")
    else if (device.state === BluetoothDeviceState.Connecting) parts.push("Connecting")
    else if (device.state === BluetoothDeviceState.Disconnecting) parts.push("Disconnecting")
    else if (device.pairing) parts.push("Pairing")
    else if (device.paired) parts.push("Paired")
    else parts.push("Nearby")

    if (device.trusted) parts.push("Trusted")
    if (device.batteryAvailable) parts.push(root.batteryText(device))

    return parts.join(" · ")
  }

  function primaryActionLabel(device) {
    if (!device) return ""
    if (device.state === BluetoothDeviceState.Connecting || device.state === BluetoothDeviceState.Disconnecting) return "Wait"
    if (device.connected) return "Disconnect"
    if (device.pairing) return "Cancel"
    if (!device.paired) return "Pair"
    return "Connect"
  }

  function runPrimaryAction(device) {
    if (!device) return

    if (device.connected) {
      if (device.disconnect) device.disconnect()
      return
    }

    if (device.pairing) {
      if (device.cancelPair) device.cancelPair()
      return
    }

    if (!device.paired) {
      if (device.pair) device.pair()
      return
    }

    if (device.connect) device.connect()
  }

  onOpenChanged: {
    if (!root.adapter) return
    if (root.open && root.adapter.enabled) root.adapter.discovering = true
    if (!root.open) root.adapter.discovering = false
  }

  Column {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 9

    Row {
      width: parent.width
      spacing: 8

      Text {
        width: parent.width - adapterToggle.width - 8
        text: "Bluetooth"
        color: Theme.colors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 1
        font.bold: true
        elide: Text.ElideRight
      }

      Rectangle {
        id: adapterToggle
        width: 78
        height: 24
        radius: Theme.radiusSm
        color: root.adapter && root.adapter.enabled ? Theme.colors.workspaceActive : Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: root.adapter && root.adapter.enabled ? "On" : "Off"
          color: root.adapter && root.adapter.enabled ? Theme.colors.accentText : Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
          font.bold: root.adapter && root.adapter.enabled
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
        }
      }
    }

    Row {
      width: parent.width
      spacing: 8

      Rectangle {
        visible: !root.compactMode
        width: root.compactMode ? 0 : parent.width - scanButton.width - 8
        height: 28
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong

        Text {
          anchors.left: parent.left
          anchors.leftMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          text: root.statusText()
          color: Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
          elide: Text.ElideRight
          width: parent.width - 20
        }
      }

      Rectangle {
        id: scanButton
        width: root.compactMode ? parent.width : 88
        height: 28
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: root.adapter && root.adapter.discovering ? "Stop scan" : "Scan"
          color: root.adapter && root.adapter.enabled ? Theme.colors.textPrimary : Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 3
        }

        MouseArea {
          anchors.fill: parent
          enabled: root.adapter && root.adapter.enabled
          cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
          onClicked: if (root.adapter) root.adapter.discovering = !root.adapter.discovering
        }
      }
    }

    Rectangle {
      width: parent.width
      height: 60
      radius: Theme.radiusSm
      color: Theme.colors.surfaceStrong

      Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 3

        Text {
          width: parent.width
          text: root.connectedCount > 0 ? (root.connectedCount + " connected") : (root.adapter && root.adapter.enabled ? "No active connections" : "Adapter unavailable")
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
          font.bold: true
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          visible: !root.compactMode
          text: root.adapter && root.adapter.name ? root.adapter.name : "BlueZ default adapter"
          color: Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
          elide: Text.ElideRight
        }
      }
    }

    Text {
      visible: !root.compactMode
      text: "Devices"
      color: Theme.colors.textMuted
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 1
      font.bold: true
    }

    Item {
      width: parent.width
      height: parent.height - 158

      Text {
        anchors.centerIn: parent
        visible: !root.adapter
        text: "No Bluetooth adapter found"
        color: Theme.colors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
      }

      Text {
        anchors.centerIn: parent
        visible: root.adapter && !root.adapter.enabled
        text: "Bluetooth is disabled"
        color: Theme.colors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
      }

      Text {
        anchors.centerIn: parent
        visible: root.adapter && root.adapter.enabled && root.sortedDevices.length === 0
        text: root.adapter && root.adapter.discovering ? "Scanning for devices…" : "No devices available"
        color: Theme.colors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
      }

      Flickable {
        anchors.fill: parent
        clip: true
        visible: root.adapter && root.adapter.enabled && root.sortedDevices.length > 0
        contentWidth: width
        contentHeight: devicesColumn.height

        Column {
          id: devicesColumn
          width: parent.width
          spacing: 6

          Repeater {
            model: root.sortedDevices

            Rectangle {
              required property var modelData

              width: devicesColumn.width
              height: 56
              radius: Theme.radiusSm
              color: modelData.connected ? Theme.colors.workspaceOccupied : Theme.colors.surfaceStrong
              border.width: modelData.connected ? 1 : 0
              border.color: modelData.connected ? Theme.colors.workspaceActive : "transparent"

              Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                text: modelData.connected ? "󰂱" : "󰂯"
                color: modelData.connected ? Theme.colors.info : Theme.colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
                horizontalAlignment: Text.AlignHCenter
              }

              Column {
                anchors.left: parent.left
                anchors.leftMargin: 36
                anchors.right: deviceActions.left
                anchors.rightMargin: 8
                anchors.top: parent.top
                anchors.topMargin: 8
                spacing: 2

                Text {
                  width: parent.width
                  text: root.deviceName(modelData)
                  color: Theme.colors.textPrimary
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize - 1
                  font.bold: modelData.connected
                  elide: Text.ElideRight
                }

                Text {
                  width: parent.width
                  visible: !root.compactMode
                  text: root.deviceSubtitle(modelData)
                  color: Theme.colors.textMuted
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize - 4
                  elide: Text.ElideRight
                }
              }

              Row {
                id: deviceActions
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Rectangle {
                  width: modelData.paired && !modelData.connected && !modelData.pairing ? 54 : 0
                  height: 24
                  radius: Theme.radiusSm
                  color: Theme.colors.surfaceRaised
                  visible: modelData.paired && !modelData.connected && !modelData.pairing

                  Text {
                    anchors.centerIn: parent
                    text: "Forget"
                    color: Theme.colors.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 4
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (modelData.forget) modelData.forget()
                  }
                }

                Rectangle {
                  width: 78
                  height: 24
                  radius: Theme.radiusSm
                  color: modelData.connected ? Theme.colors.workspaceActive : Theme.colors.surfaceRaised

                  Text {
                    anchors.centerIn: parent
                    text: root.primaryActionLabel(modelData)
                    color: modelData.connected ? Theme.colors.accentText : Theme.colors.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 4
                    font.bold: modelData.connected
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: modelData.state !== BluetoothDeviceState.Connecting && modelData.state !== BluetoothDeviceState.Disconnecting
                    onClicked: root.runPrimaryAction(modelData)
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
