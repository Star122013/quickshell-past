pragma ComponentBehavior: Bound

import Quickshell.Widgets
import QtQuick

import "../../../Theme/theme.js" as Theme
import "../../../Theme/barPopupStyle.js" as PopupStyle

Rectangle {
  id: root

  required property bool open
  required property var notification

  signal closeRequested()

  property real popupScale: root.open ? 1 : 0.97
  property string appNameText: {
    if (root.notification && root.notification.appName && String(root.notification.appName).length > 0)
      return String(root.notification.appName)
    if (root.notification && root.notification.summary && String(root.notification.summary).length > 0)
      return String(root.notification.summary)
    return "Notification"
  }
  property string messageText: {
    var summary = root.notification && root.notification.summary ? String(root.notification.summary) : ""
    var body = root.notification && root.notification.body ? String(root.notification.body).replace(/\s+/g, " ").trim() : ""
    if (summary.length > 0 && body.length > 0)
      return summary + " — " + body
    if (body.length > 0)
      return body
    if (summary.length > 0)
      return summary
    return "New notification"
  }
  property var iconSource: {
    if (root.notification && root.notification.appIcon) return root.notification.appIcon
    if (root.notification && root.notification.image) return root.notification.image
    if (root.notification && root.notification.icon) return root.notification.icon
    return ""
  }
  property string fallbackGlyph: {
    if (root.appNameText.length > 0)
      return root.appNameText.charAt(0).toUpperCase()
    return "󰍡"
  }

  implicitWidth: PopupStyle.panel.toast.width
  implicitHeight: PopupStyle.panel.toast.height
  radius: Theme.uiRadius
  color: Theme.colors.notificationToastBg
  border.width: 1
  border.color: Theme.colors.notificationToastBorder
  opacity: root.open ? 1 : 0

  transform: Scale {
    origin.x: root.width / 2
    origin.y: 0
    xScale: root.popupScale
    yScale: root.popupScale
  }

  Behavior on opacity {
    NumberAnimation {
      duration: 160
      easing.type: Easing.OutCubic
    }
  }

  Behavior on popupScale {
    NumberAnimation {
      duration: 170
      easing.type: Easing.OutCubic
    }
  }

  Rectangle {
    anchors.fill: parent
    anchors.margins: 1
    radius: parent.radius - 1
    color: Theme.colors.notificationToastInnerOverlay
    border.width: 0
  }

  Row {
    anchors.fill: parent
    anchors.margins: PopupStyle.panel.toast.padding
    spacing: PopupStyle.panel.toast.spacing

    Rectangle {
      width: PopupStyle.panel.toast.iconSize
      height: PopupStyle.panel.toast.iconSize
      radius: Math.min(Theme.uiRadius, height / 2)
      color: Theme.colors.notificationToastIconBg
      border.width: 1
      border.color: Theme.colors.notificationToastIconBorder

      IconImage {
        id: notificationIcon
        anchors.centerIn: parent
        implicitSize: PopupStyle.panel.toast.iconGlyphSize
        source: root.iconSource
        asynchronous: true
        visible: !!root.iconSource
      }

      Text {
        anchors.centerIn: parent
        visible: !notificationIcon.visible
        text: root.fallbackGlyph
        color: Theme.colors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 6
        font.bold: true
      }
    }

    Column {
      width: parent.width - 120
      anchors.verticalCenter: parent.verticalCenter
      spacing: PopupStyle.panel.toast.textSpacing

      Row {
        width: parent.width
        spacing: 8

        Text {
          width: parent.width - 54
          text: root.appNameText
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize + 1
          font.bold: true
          elide: Text.ElideRight
        }

        Text {
          text: "now"
          color: Theme.colors.textPrimary
          opacity: 0.88
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 3
        }
      }

      Text {
        width: parent.width
        text: root.messageText
        color: Theme.colors.accentStrong
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
      }
    }

    Item {
      width: PopupStyle.panel.toast.closeButtonSize
      height: PopupStyle.panel.toast.closeButtonSize

      Text {
        anchors.centerIn: parent
        text: "×"
        color: Theme.colors.textPrimary
        opacity: 0.86
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 2
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.closeRequested()
      }
    }
  }
}
