pragma ComponentBehavior: Bound

import QtQuick

import "../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property var notifications
  required property bool open
  property real popupScale: root.open ? 1 : 0.96
  property bool hasNotifications: notifications && notifications.trackedNotifications && notifications.trackedNotifications.values && notifications.trackedNotifications.values.length > 0

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

  Behavior on opacity {
    NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
  }
  Behavior on popupScale {
    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
  }

  function dismissAll() {
    if (!notifications || !notifications.trackedNotifications) return
    var values = notifications.trackedNotifications.values
    if (!values) return

    var i
    for (i = values.length - 1; i >= 0; i--) {
      if (values[i] && values[i].dismiss) values[i].dismiss()
    }
  }

  Column {
    anchors.fill: parent
    anchors.margins: 9
    spacing: 7

    Row {
      width: parent.width
      spacing: 8

      Text {
        width: parent.width - clearButton.width - 8
        text: "Notifications"
        color: Theme.colors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 1
        font.bold: true
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
      }

      Rectangle {
        id: clearButton
        width: 74
        height: 22
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong
        border.width: 0

        Text {
          anchors.centerIn: parent
          text: "Clear all"
          color: Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.dismissAll()
        }
      }
    }

    Rectangle {
      width: parent.width
      height: 1
      color: Theme.colors.border
    }

    Item {
      width: parent.width
      height: parent.height - 40

      Text {
        anchors.centerIn: parent
        visible: !root.hasNotifications
        text: "No active notifications"
        color: Theme.colors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
      }

      Flickable {
        anchors.fill: parent
        visible: root.hasNotifications
        clip: true
        contentWidth: width
        contentHeight: notificationsColumn.height

        Column {
          id: notificationsColumn
          width: parent.width
          spacing: 6

          Repeater {
            model: root.notifications && root.notifications.trackedNotifications && root.notifications.trackedNotifications.values ? root.notifications.trackedNotifications.values : []

            Rectangle {
              id: card

              required property var modelData

              width: notificationsColumn.width
              radius: Theme.radiusSm
              color: Theme.colors.surfaceStrong
              border.width: 0
              implicitHeight: Math.max(summaryText.implicitHeight + bodyText.implicitHeight + appText.implicitHeight + 20, 50)

              Column {
                anchors.fill: parent
                anchors.margins: 7
                spacing: 2

                Text {
                  id: summaryText
                  text: card.modelData.summary || "(no title)"
                  color: Theme.colors.textPrimary
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize
                  font.bold: true
                  elide: Text.ElideRight
                }

                Text {
                  id: bodyText
                  text: card.modelData.body || ""
                  color: Theme.colors.textMuted
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize - 1
                  wrapMode: Text.Wrap
                  maximumLineCount: 3
                  elide: Text.ElideRight
                }

                Text {
                  id: appText
                  text: card.modelData.appName || "unknown"
                  color: Theme.colors.info
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize - 2
                  elide: Text.ElideRight
                }
              }

              MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: function(mouse) {
                  if (mouse.button === Qt.RightButton) card.modelData.dismiss()
                }
              }
            }
          }
        }
      }
    }
  }
}
