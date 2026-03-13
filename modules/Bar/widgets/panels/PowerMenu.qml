import Quickshell.Io
import QtQuick

import "../../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property bool open
  property bool compactMode: false
  property real popupScale: root.open ? 1 : 0.96
  property string pendingAction: ""
  property string pendingCommand: ""
  property int summaryHeight: root.compactMode ? 42 : 56
  property int actionRowHeight: root.compactMode ? 40 : 44

  signal actionTriggered

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

  Behavior on opacity {
    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
  }
  Behavior on popupScale {
    NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
  }

  function clearPending() {
    root.pendingAction = ""
    root.pendingCommand = ""
  }

  function runAction(cmd) {
    if (!cmd || cmd.length === 0) return
    actionProc.exec(["sh", "-lc", cmd])
    root.clearPending()
    root.actionTriggered()
  }

  function askConfirm(label, cmd) {
    root.pendingAction = label
    root.pendingCommand = cmd
  }

  function handleAction(mode, label, cmd) {
    if (mode === "direct") root.runAction(cmd)
    else root.askConfirm(label, cmd)
  }

  function pendingDescription() {
    if (root.pendingAction === "Shutdown") return "This will power off the machine immediately."
    if (root.pendingAction === "Reboot") return "This will restart the machine immediately."
    return "Choose an action below."
  }

  onOpenChanged: {
    if (!root.open) root.clearPending()
  }

  Process {
    id: actionProc
  }

  Column {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 9

    Row {
      width: parent.width
      spacing: 8

      Text {
        width: parent.width - 64
        text: "Power"
        color: Theme.colors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 1
        font.bold: true
        elide: Text.ElideRight
      }

      Rectangle {
        width: 56
        height: 22
        radius: Theme.radiusSm
        color: root.pendingAction.length > 0 ? Theme.colors.workspaceActive : Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: root.pendingAction.length > 0 ? "Confirm" : "Ready"
          color: root.pendingAction.length > 0 ? Theme.colors.accentText : Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 3
          font.bold: root.pendingAction.length > 0
        }
      }
    }

    Rectangle {
      width: parent.width
      height: root.summaryHeight
      radius: Theme.radiusSm
      color: root.pendingAction.length > 0 ? Theme.colors.surfaceRaised : Theme.colors.surfaceStrong

      Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: root.compactMode ? 0 : 2

        Text {
          width: parent.width
          text: root.pendingAction.length > 0 ? ("Confirm " + root.pendingAction + "?") : "Choose a power action"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
          font.bold: true
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          visible: !root.compactMode
          text: root.pendingDescription()
          color: Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 3
          wrapMode: Text.Wrap
          maximumLineCount: 2
          elide: Text.ElideRight
        }
      }
    }

    Rectangle {
      width: parent.width
      height: root.actionRowHeight
      radius: Theme.radiusSm
      color: Theme.colors.surfaceStrong
      border.width: 0

      Text {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 22
        text: "⏾"
        color: Theme.colors.info
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 3
        horizontalAlignment: Text.AlignHCenter
      }

      Column {
        anchors.left: parent.left
        anchors.leftMargin: 42
        anchors.right: parent.right
        anchors.rightMargin: 66
        anchors.top: parent.top
        anchors.topMargin: root.compactMode ? Math.max(0, Math.round((parent.height - suspendTitle.implicitHeight) / 2)) : 8
        spacing: 2

        Text {
          id: suspendTitle
          width: parent.width
          text: "Suspend"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
          font.bold: true
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          visible: !root.compactMode
          text: "Sleep now and keep your session in memory"
          color: Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 4
          elide: Text.ElideRight
        }
      }

      Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 48
        height: 24
        radius: Theme.radiusSm
        color: Theme.colors.surfaceRaised

        Text {
          anchors.centerIn: parent
          text: "Now"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 4
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.handleAction("direct", "Suspend", "systemctl suspend")
      }
    }

    Rectangle {
      width: parent.width
      height: root.actionRowHeight
      radius: Theme.radiusSm
      color: root.pendingAction === "Reboot" ? Theme.colors.workspaceOccupied : Theme.colors.surfaceStrong
      border.width: root.pendingAction === "Reboot" ? 1 : 0
      border.color: root.pendingAction === "Reboot" ? Theme.colors.workspaceActive : "transparent"

      Text {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 22
        text: ""
        color: Theme.colors.accentStrong
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 2
        horizontalAlignment: Text.AlignHCenter
      }

      Column {
        anchors.left: parent.left
        anchors.leftMargin: 42
        anchors.right: parent.right
        anchors.rightMargin: 78
        anchors.top: parent.top
        anchors.topMargin: root.compactMode ? Math.max(0, Math.round((parent.height - rebootTitle.implicitHeight) / 2)) : 8
        spacing: 2

        Text {
          id: rebootTitle
          width: parent.width
          text: "Reboot"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
          font.bold: true
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          visible: !root.compactMode
          text: "Restart the system and reopen your environment"
          color: Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 4
          elide: Text.ElideRight
        }
      }

      Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 60
        height: 24
        radius: Theme.radiusSm
        color: root.pendingAction === "Reboot" ? Theme.colors.workspaceActive : Theme.colors.surfaceRaised

        Text {
          anchors.centerIn: parent
          text: root.pendingAction === "Reboot" ? "Selected" : "Confirm"
          color: root.pendingAction === "Reboot" ? Theme.colors.accentText : Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 4
          font.bold: root.pendingAction === "Reboot"
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.handleAction("confirm", "Reboot", "systemctl reboot")
      }
    }

    Rectangle {
      width: parent.width
      height: root.actionRowHeight
      radius: Theme.radiusSm
      color: root.pendingAction === "Shutdown" ? Theme.colors.workspaceOccupied : Theme.colors.surfaceStrong
      border.width: root.pendingAction === "Shutdown" ? 1 : 0
      border.color: root.pendingAction === "Shutdown" ? Theme.colors.danger : "transparent"

      Text {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 22
        text: "⏻"
        color: Theme.colors.danger
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 3
        horizontalAlignment: Text.AlignHCenter
      }

      Column {
        anchors.left: parent.left
        anchors.leftMargin: 42
        anchors.right: parent.right
        anchors.rightMargin: 78
        anchors.top: parent.top
        anchors.topMargin: root.compactMode ? Math.max(0, Math.round((parent.height - shutdownTitle.implicitHeight) / 2)) : 8
        spacing: 2

        Text {
          id: shutdownTitle
          width: parent.width
          text: "Shutdown"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
          font.bold: true
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          visible: !root.compactMode
          text: "Power off the machine completely"
          color: Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 4
          elide: Text.ElideRight
        }
      }

      Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 60
        height: 24
        radius: Theme.radiusSm
        color: root.pendingAction === "Shutdown" ? Theme.colors.danger : Theme.colors.surfaceRaised

        Text {
          anchors.centerIn: parent
          text: root.pendingAction === "Shutdown" ? "Selected" : "Confirm"
          color: root.pendingAction === "Shutdown" ? Theme.colors.accentText : Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 4
          font.bold: root.pendingAction === "Shutdown"
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.handleAction("confirm", "Shutdown", "systemctl poweroff")
      }
    }

    Row {
      visible: root.pendingAction.length > 0
      width: parent.width
      spacing: 8

      Rectangle {
        width: (parent.width - 8) / 2
        height: 32
        radius: Theme.radiusSm
        color: Theme.colors.workspaceActive

        Text {
          anchors.centerIn: parent
          text: "Run " + root.pendingAction
          color: Theme.colors.accentText
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
          font.bold: true
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.runAction(root.pendingCommand)
        }
      }

      Rectangle {
        width: (parent.width - 8) / 2
        height: 32
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: "Cancel"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.clearPending()
        }
      }
    }
  }
}
