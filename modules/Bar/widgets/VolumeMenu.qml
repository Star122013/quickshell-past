import QtQuick

import "../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property bool open
  required property var audio
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
    if (root.open && root.audio && root.audio.refresh) root.audio.refresh()
  }

  Column {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 8

    Text {
      text: "Volume " + (root.audio ? root.audio.volumePercent : 0) + "%"
      color: Theme.colors.textPrimary
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
      font.bold: true
    }

    Row {
      spacing: 8

      Rectangle {
        width: 56
        height: 28
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong
        Text { anchors.centerIn: parent; text: "-"; color: Theme.colors.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 3 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (root.audio) root.audio.stepVolume(-5) }
      }

      Rectangle {
        width: 56
        height: 28
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong
        Text { anchors.centerIn: parent; text: root.audio && root.audio.muted ? "Unmute" : "Mute"; color: Theme.colors.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (root.audio) root.audio.toggleMute() }
      }

      Rectangle {
        width: 56
        height: 28
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong
        Text { anchors.centerIn: parent; text: "+"; color: Theme.colors.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 3 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (root.audio) root.audio.stepVolume(5) }
      }
    }

    Text {
      text: "Output"
      color: Theme.colors.textMuted
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 1
    }

    Flickable {
      width: parent.width
      height: parent.height - 92
      clip: true
      contentWidth: width
      contentHeight: sinksColumn.height

      Column {
        id: sinksColumn
        width: parent.width
        spacing: 6

        Repeater {
          model: root.audio && root.audio.sinks ? root.audio.sinks : []

          Rectangle {
            required property var modelData
            width: sinksColumn.width
            height: 28
            radius: Theme.radiusSm
            color: modelData.isDefault ? Theme.colors.workspaceOccupied : Theme.colors.surfaceStrong

            Text {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: 8
              width: parent.width - 16
              text: (modelData.isDefault ? "● " : "○ ") + modelData.name
              color: Theme.colors.textPrimary
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
              elide: Text.ElideRight
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: if (root.audio) root.audio.setDefaultSink(modelData.id)
            }
          }
        }
      }
    }
  }
}
