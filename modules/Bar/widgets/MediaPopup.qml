import Quickshell.Services.Mpris
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
    origin.x: root.width / 2
    origin.y: 0
    xScale: root.popupScale
    yScale: root.popupScale
  }

  Behavior on opacity {
    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
  }
  Behavior on popupScale {
    NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
  }

  property var activePlayer: {
    var values = Mpris.players && Mpris.players.values ? Mpris.players.values : []
    var first = null
    var i
    for (i = 0; i < values.length; i++) {
      if (!values[i]) continue
      if (!first) first = values[i]
      if (values[i].isPlaying) return values[i]
    }
    return first
  }

  function sourceText() {
    if (!activePlayer) return "No active source"
    return activePlayer.identity || "Unknown player"
  }

  function titleText() {
    if (!activePlayer) return "No media"
    return activePlayer.trackTitle && activePlayer.trackTitle.length > 0 ? activePlayer.trackTitle : "Unknown title"
  }

  function artistText() {
    if (!activePlayer) return ""
    if (activePlayer.trackArtist && activePlayer.trackArtist.length > 0) return activePlayer.trackArtist
    return activePlayer.trackAlbum || ""
  }

  function togglePlayPause() {
    if (!activePlayer) return
    if (activePlayer.canTogglePlaying) activePlayer.togglePlaying()
    else if (activePlayer.isPlaying && activePlayer.canPause) activePlayer.pause()
    else if (!activePlayer.isPlaying && activePlayer.canPlay) activePlayer.play()
  }

  Column {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 8

    Text {
      text: root.sourceText()
      color: Theme.colors.textMuted
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 1
      elide: Text.ElideRight
      width: parent.width
    }

    Text {
      text: root.titleText()
      color: Theme.colors.textPrimary
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize + 1
      font.bold: true
      elide: Text.ElideRight
      width: parent.width
    }

    Text {
      text: root.artistText()
      color: Theme.colors.textMuted
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
      elide: Text.ElideRight
      width: parent.width
    }

    Row {
      spacing: 12
      anchors.horizontalCenter: parent.horizontalCenter

      Rectangle {
        width: 32
        height: 32
        radius: 16
        color: Theme.colors.surfaceRaised

        Text {
          anchors.centerIn: parent
          text: "󰒮"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize + 1
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          enabled: root.activePlayer && root.activePlayer.canGoPrevious
          onClicked: if (root.activePlayer) root.activePlayer.previous()
        }
      }

      Rectangle {
        width: 38
        height: 38
        radius: 19
        color: Theme.colors.workspaceActive

        Text {
          anchors.centerIn: parent
          text: root.activePlayer && root.activePlayer.isPlaying ? "󰏤" : "󰐊"
          color: Theme.colors.accentText
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize + 3
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          enabled: !!root.activePlayer
          onClicked: root.togglePlayPause()
        }
      }

      Rectangle {
        width: 32
        height: 32
        radius: 16
        color: Theme.colors.surfaceRaised

        Text {
          anchors.centerIn: parent
          text: "󰒭"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize + 1
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          enabled: root.activePlayer && root.activePlayer.canGoNext
          onClicked: if (root.activePlayer) root.activePlayer.next()
        }
      }
    }
  }
}
