import QtQuick

import "../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property bool open
  required property var wifi
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
    if (root.open && root.wifi && root.wifi.scanNow) root.wifi.scanNow()
  }

  Column {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 8

    Text {
      text: root.wifi && root.wifi.enabled ? (root.wifi.connectedSsid.length > 0 ? "Wi-Fi: " + root.wifi.connectedSsid : "Wi-Fi: enabled") : "Wi-Fi: disabled"
      color: Theme.colors.textPrimary
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
      font.bold: true
      elide: Text.ElideRight
      width: parent.width
    }

    Flickable {
      width: parent.width
      height: parent.height - 30
      clip: true
      contentWidth: width
      contentHeight: networksColumn.height

      Column {
        id: networksColumn
        width: parent.width
        spacing: 6

        Repeater {
          model: root.wifi && root.wifi.networks ? root.wifi.networks : []

          Rectangle {
            required property var modelData
            width: networksColumn.width
            height: 30
            radius: Theme.radiusSm
            color: modelData.active ? Theme.colors.workspaceOccupied : Theme.colors.surfaceStrong

            Text {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: 8
              width: parent.width - 16
              text: (modelData.active ? "● " : "○ ") + (modelData.ssid.length > 0 ? modelData.ssid : "(hidden)") + "  " + modelData.signal + "%"
              color: Theme.colors.textPrimary
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
              elide: Text.ElideRight
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: if (root.wifi && modelData.ssid.length > 0) root.wifi.connect(modelData.ssid)
            }
          }
        }
      }
    }
  }
}
