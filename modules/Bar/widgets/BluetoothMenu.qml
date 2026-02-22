import Quickshell.Bluetooth
import QtQuick

import "../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property bool open
  property real popupScale: root.open ? 1 : 0.96

  radius: Theme.radiusMd
  color: Theme.colors.surface
  border.width: 0
  opacity: root.open ? 1 : 0

  transform: Scale {
    origin.x: root.width
    origin.y: 0
    xScale: root.popupScale
    yScale: root.popupScale
  }

  Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
  Behavior on popupScale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

  onOpenChanged: {
    if (!Bluetooth.defaultAdapter) return
    if (root.open) Bluetooth.defaultAdapter.discovering = true
    else Bluetooth.defaultAdapter.discovering = false
  }

  function deviceName(device) {
    if (!device) return "Unknown"
    if (device.name && device.name.length > 0) return device.name
    if (device.deviceName && device.deviceName.length > 0) return device.deviceName
    return device.address || "Unknown"
  }

  Column {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 8

    Row {
      width: parent.width
      spacing: 8

      Text {
        width: parent.width - 72
        text: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled ? "Bluetooth" : "Bluetooth off"
        color: Theme.colors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
      }

      Rectangle {
        width: 64
        height: 24
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled ? "Disable" : "Enable"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
        }
      }
    }

    Flickable {
      width: parent.width
      height: parent.height - 36
      clip: true
      contentWidth: width
      contentHeight: devicesColumn.height

      Column {
        id: devicesColumn
        width: parent.width
        spacing: 6

        Repeater {
          model: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.devices && Bluetooth.defaultAdapter.devices.values ? Bluetooth.defaultAdapter.devices.values : []

          Rectangle {
            required property var modelData
            width: devicesColumn.width
            height: 30
            radius: Theme.radiusSm
            color: modelData.connected ? Theme.colors.workspaceOccupied : Theme.colors.surfaceStrong

            Text {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: 8
              width: parent.width - 16
              text: (modelData.connected ? "● " : "○ ") + root.deviceName(modelData)
              color: Theme.colors.textPrimary
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
              elide: Text.ElideRight
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (modelData.connected) modelData.disconnect()
                else modelData.connect()
              }
            }
          }
        }
      }
    }
  }
}
