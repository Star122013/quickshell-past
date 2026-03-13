import QtQuick

import "../../../Theme/theme.js" as Theme
import "../../../Theme/barPopupStyle.js" as PopupStyle

Rectangle {
  id: root

  required property bool open
  required property var wifi
  property bool compactMode: false
  property real popupScale: root.open ? 1 : 0.96
  property string passwordSsid: ""
  property bool revealPassword: false

  implicitWidth: PopupStyle.panel.leftSubmenu.wifi.width
  implicitHeight: PopupStyle.panel.leftSubmenu.wifi.height
  radius: Theme.radiusMd
  color: Theme.colors.surface
  border.width: 1
  border.color: Theme.colors.surfaceRaised
  opacity: root.open ? 1 : 0
  clip: true

  transform: Scale {
    origin.x: root.width
    origin.y: 0
    xScale: root.popupScale
    yScale: root.popupScale
  }

  Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
  Behavior on popupScale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

  function signalGlyph(signal) {
    if (signal >= 75) return "󰤨"
    if (signal >= 55) return "󰤥"
    if (signal >= 35) return "󰤢"
    if (signal > 0) return "󰤟"
    return "󰤯"
  }

  function currentSummary() {
    if (!root.wifi || !root.wifi.enabled)
      return "Wi-Fi is turned off"
    if (root.wifi.connectedSsid && root.wifi.connectedSsid.length > 0)
      return root.wifi.connectedSsid
    if (root.wifi.pendingSsid && root.wifi.pendingSsid.length > 0)
      return "Connecting…"
    return root.wifi.scanning ? "Scanning for networks…" : "Ready to connect"
  }

  function summaryDetail() {
    if (!root.wifi || !root.wifi.enabled)
      return root.wiredConnectedCount() > 0 ? (root.wiredConnectedCount() + " wired link active") : "Turn it on to see nearby networks"
    if (root.wifi.connectedSsid && root.wifi.connectedSsid.length > 0)
      return "Signal " + root.wifi.connectedSignal + "%"
    if (root.wifi.networks && root.wifi.networks.length > 0)
      return root.wifi.networks.length + " networks found"
    return "No networks nearby"
  }

  function wiredConnectedCount() {
    if (!root.wifi || !root.wifi.ethernetConnections)
      return 0

    var count = 0
    var i
    for (i = 0; i < root.wifi.ethernetConnections.length; i++) {
      if (root.wifi.ethernetConnections[i] && root.wifi.ethernetConnections[i].state === "connected")
        count++
    }
    return count
  }

  function networkTitle(network) {
    if (!network)
      return "Unknown network"
    return network.ssid && network.ssid.length > 0 ? network.ssid : "Hidden network"
  }

  function networkSubtitle(network) {
    if (!network)
      return ""

    var parts = []
    if (network.active)
      parts.push("Connected")
    else if (root.wifi && root.wifi.pendingSsid && root.wifi.pendingSsid === network.ssid)
      parts.push("Connecting")
    else if (network.secure && !network.saved)
      parts.push("Password required")
    else if (network.secure && network.saved)
      parts.push("Saved network")
    else
      parts.push("Open network")

    if (!network.ssid || network.ssid.length === 0)
      parts.push("Unavailable here")
    else
      parts.push(network.signal + "%")

    return parts.join(" · ")
  }

  function actionLabel(network) {
    if (!network)
      return ""
    if (!root.wifi || !root.wifi.enabled)
      return "Off"
    if (!network.ssid || network.ssid.length === 0)
      return "Hidden"
    if (network.active)
      return "Connected"
    if (root.wifi && root.wifi.pendingSsid && root.wifi.pendingSsid === network.ssid)
      return "…"
    if (network.secure && !network.saved)
      return "Password"
    return "Connect"
  }

  function ethernetTitle(entry) {
    if (!entry)
      return "Ethernet"
    if (entry.connection && entry.connection.length > 0)
      return entry.connection
    if (entry.device && entry.device.length > 0)
      return entry.device
    return "Ethernet"
  }

  function ethernetSubtitle(entry) {
    if (!entry)
      return ""

    var parts = []
    if (entry.device && entry.device.length > 0)
      parts.push(entry.device)
    if (entry.state === "connected")
      parts.push("Connected")
    else if (entry.state === "connecting")
      parts.push("Connecting")
    else if (entry.state === "unavailable")
      parts.push("Unavailable")
    else
      parts.push("Disconnected")
    return parts.join(" · ")
  }

  function openPasswordPrompt(ssid) {
    root.passwordSsid = ssid
    root.revealPassword = false
    passwordInput.text = ""
    passwordFocusTimer.running = false
    passwordFocusTimer.running = true
  }

  function closePasswordPrompt() {
    root.passwordSsid = ""
    root.revealPassword = false
    passwordInput.text = ""
  }

  function runNetworkAction(network) {
    if (!network || !root.wifi || !root.wifi.enabled)
      return
    if (!network.ssid || network.ssid.length === 0 || network.active)
      return

    if (network.secure && !network.saved) {
      root.openPasswordPrompt(network.ssid)
      return
    }

    root.closePasswordPrompt()
    if (root.wifi.connect)
      root.wifi.connect(network.ssid)
  }

  function submitPassword() {
    if (!root.passwordSsid || root.passwordSsid.length === 0)
      return
    if (passwordInput.text.length === 0 || !root.wifi || !root.wifi.connectWithPassword)
      return

    root.wifi.connectWithPassword(root.passwordSsid, passwordInput.text)
    root.closePasswordPrompt()
  }

  onOpenChanged: {
    if (!root.wifi)
      return

    if (!root.open) {
      root.closePasswordPrompt()
      return
    }

    if (root.wifi.refresh)
      root.wifi.refresh()
    if (root.wifi.enabled && root.wifi.scanNow)
      root.wifi.scanNow()
  }

  Timer {
    id: passwordFocusTimer
    interval: 1
    repeat: false
    onTriggered: passwordInput.forceActiveFocus()
  }

  Flickable {
    anchors.fill: parent
    anchors.margins: 0
    clip: true
    contentWidth: width
    contentHeight: contentColumn.height + 24

    Column {
      id: contentColumn
      width: root.width - 24
      x: 12
      y: 12
      spacing: 10

      Row {
        width: parent.width
        spacing: 10

        Text {
          width: parent.width - wifiToggle.width - 10
          text: "Wi-Fi"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize + 2
          font.bold: true
          elide: Text.ElideRight
        }

        Rectangle {
          id: wifiToggle
          width: 82
          height: 28
          radius: Math.min(Theme.uiRadius, height / 2)
          color: root.wifi && root.wifi.enabled ? Theme.colors.workspaceActive : Theme.colors.surfaceStrong
          border.width: root.wifi && root.wifi.enabled ? 0 : 1
          border.color: Theme.colors.wifiToggleBorder

          Text {
            anchors.centerIn: parent
            text: root.wifi && root.wifi.enabled ? "Enabled" : "Disabled"
            color: root.wifi && root.wifi.enabled ? Theme.colors.accentText : Theme.colors.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            font.bold: true
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.wifi && root.wifi.setEnabled) root.wifi.setEnabled(!(root.wifi && root.wifi.enabled))
          }
        }
      }

      Rectangle {
        width: parent.width
        height: 88
        radius: Theme.radiusMd + 2
        color: Theme.colors.wifiCardBg
        border.width: 1
        border.color: Theme.colors.wifiCardBorder

        Row {
          anchors.fill: parent
          anchors.margins: 14
          spacing: 12

          Rectangle {
            width: 52
            height: 52
            radius: Math.min(Theme.uiRadius, height / 2)
            anchors.verticalCenter: parent.verticalCenter
            color: root.wifi && root.wifi.enabled ? Theme.colors.wifiSummaryIconActiveBg : Theme.colors.wifiSummaryIconInactiveBg

            Text {
              anchors.centerIn: parent
              text: root.signalGlyph(root.wifi ? root.wifi.connectedSignal : 0)
              color: root.wifi && root.wifi.enabled ? Theme.colors.info : Theme.colors.textMuted
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize + 12
            }
          }

          Column {
            width: parent.width - 64
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
              width: parent.width
              text: root.currentSummary()
              color: Theme.colors.textPrimary
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize + 1
              font.bold: true
              elide: Text.ElideRight
            }

            Text {
              width: parent.width
              visible: !root.compactMode
              text: root.summaryDetail()
              color: Theme.colors.textMuted
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 2
              elide: Text.ElideRight
            }
          }
        }
      }

      Row {
        width: parent.width
        spacing: 10

        Rectangle {
          width: (parent.width - 10) / 2
          height: 32
          radius: Math.min(Theme.uiRadius, height / 2)
          color: Theme.colors.wifiActionBg
          border.width: 1
          border.color: Theme.colors.wifiActionBorder

          Text {
            anchors.centerIn: parent
            text: root.wifi && root.wifi.scanning ? "Scanning…" : "Scan"
            color: root.wifi && root.wifi.enabled ? Theme.colors.textPrimary : Theme.colors.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            font.bold: true
          }

          MouseArea {
            anchors.fill: parent
            enabled: root.wifi && root.wifi.enabled && root.wifi.scanNow
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.wifi.scanNow()
          }
        }

        Rectangle {
          width: (parent.width - 10) / 2
          height: 32
          radius: Math.min(Theme.uiRadius, height / 2)
          color: Theme.colors.wifiActionBg
          border.width: 1
          border.color: Theme.colors.wifiActionBorder

          Text {
            anchors.centerIn: parent
            text: "Refresh"
            color: Theme.colors.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            font.bold: true
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.wifi && root.wifi.refresh) root.wifi.refresh()
          }
        }
      }

      Rectangle {
        visible: root.wifi && ((root.wifi.connectionError && root.wifi.connectionError.length > 0) || (root.wifi.connectionMessage && root.wifi.connectionMessage.length > 0))
        width: parent.width
        height: statusColumn.implicitHeight + 20
        radius: Theme.radiusSm + 2
        color: root.wifi && root.wifi.connectionError && root.wifi.connectionError.length > 0 ? Theme.colors.wifiStatusErrorBg : Theme.colors.wifiStatusInfoBg
        border.width: 1
        border.color: root.wifi && root.wifi.connectionError && root.wifi.connectionError.length > 0 ? Theme.colors.wifiStatusErrorBorder : Theme.colors.wifiStatusInfoBorder

        Column {
          id: statusColumn
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.margins: 10
          spacing: 2

          Text {
            width: parent.width
            text: root.compactMode ? (root.wifi && root.wifi.connectionError && root.wifi.connectionError.length > 0 ? root.wifi.connectionError : root.wifi.connectionMessage) : (root.wifi && root.wifi.connectionError && root.wifi.connectionError.length > 0 ? "Connection issue" : "Network status")
            color: Theme.colors.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: root.compactMode ? Theme.fontSize - 1 : Theme.fontSize - 2
            font.bold: true
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            visible: !root.compactMode
            text: root.wifi && root.wifi.connectionError && root.wifi.connectionError.length > 0 ? root.wifi.connectionError : root.wifi.connectionMessage
            color: Theme.colors.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 4
            wrapMode: Text.Wrap
          }
        }
      }

      Column {
        visible: root.wifi && root.wifi.ethernetConnections && root.wifi.ethernetConnections.length > 0
        width: parent.width
        spacing: 8

        Text {
          visible: !root.compactMode
          text: "Ethernet"
          color: Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
          font.bold: true
        }

        Repeater {
          model: root.wifi && root.wifi.ethernetConnections ? root.wifi.ethernetConnections : []

          Rectangle {
            required property var modelData

            width: parent.width
            height: 58
            radius: Math.min(Theme.uiRadius, height / 2)
            color: modelData.state === "connected" ? Theme.colors.wifiConnectedCardBg : Theme.colors.wifiListCardBg
            border.width: 1
            border.color: modelData.state === "connected" ? Theme.colors.wifiConnectedCardBorder : Theme.colors.wifiListCardBorder

            Row {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 10

              Rectangle {
                width: 34
                height: 34
                radius: Math.min(Theme.uiRadius, height / 2)
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.colors.wifiListIconBg

                Text {
                  anchors.centerIn: parent
                  text: "󰈀"
                  color: modelData.state === "connected" ? Theme.colors.accentStrong : Theme.colors.textMuted
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize + 2
                }
              }

              Column {
                width: parent.width - 122
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                  width: parent.width
                  text: root.ethernetTitle(modelData)
                  color: Theme.colors.textPrimary
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize - 1
                  font.bold: true
                  elide: Text.ElideRight
                }

                Text {
                  width: parent.width
                  visible: !root.compactMode
                  text: root.ethernetSubtitle(modelData)
                  color: Theme.colors.textMuted
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize - 4
                  elide: Text.ElideRight
                }
              }

              Rectangle {
                width: 64
                height: 24
                radius: Math.min(Theme.uiRadius, height / 2)
                anchors.verticalCenter: parent.verticalCenter
                color: modelData.state === "connected" ? Theme.colors.workspaceActive : Theme.colors.surfaceStrong

                Text {
                  anchors.centerIn: parent
                  text: modelData.state === "connected" ? "Online" : "Idle"
                  color: modelData.state === "connected" ? Theme.colors.accentText : Theme.colors.textMuted
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize - 4
                  font.bold: modelData.state === "connected"
                }
              }
            }
          }
        }
      }

      Rectangle {
        visible: root.passwordSsid.length > 0
        width: parent.width
        height: passwordCardColumn.implicitHeight + 24
        radius: Theme.radiusMd + 2
        color: Theme.colors.wifiCardBg
        border.width: 1
        border.color: Theme.colors.wifiCardBorder

        Column {
          id: passwordCardColumn
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: 12
          spacing: 10

          Text {
            width: parent.width
            text: "Connect to “" + root.passwordSsid + "”"
            color: Theme.colors.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            font.bold: true
            elide: Text.ElideRight
          }

          Rectangle {
            width: parent.width
            height: 40
            radius: Math.min(Theme.uiRadius, height / 2)
            color: Theme.colors.surfaceStrong
            border.width: passwordInput.activeFocus ? 1 : 0
            border.color: Theme.colors.workspaceActive

            TextInput {
              id: passwordInput
              anchors.left: parent.left
              anchors.leftMargin: 12
              anchors.right: revealButton.left
              anchors.rightMargin: 8
              anchors.verticalCenter: parent.verticalCenter
              color: Theme.colors.textPrimary
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
              echoMode: root.revealPassword ? TextInput.Normal : TextInput.Password
              clip: true
              selectByMouse: true
              selectionColor: Theme.colors.workspaceActive
              selectedTextColor: Theme.colors.accentText
              Keys.onReturnPressed: root.submitPassword()
              Keys.onEnterPressed: root.submitPassword()
            }

            Text {
              anchors.left: parent.left
              anchors.leftMargin: 12
              anchors.verticalCenter: parent.verticalCenter
              visible: passwordInput.text.length === 0 && !passwordInput.activeFocus
              text: "Input password"
              color: Theme.colors.textMuted
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 2
            }

            Rectangle {
              id: revealButton
              width: 52
              height: 28
              radius: Math.min(Theme.uiRadius, height / 2)
              anchors.right: parent.right
              anchors.rightMargin: 6
              anchors.verticalCenter: parent.verticalCenter
              color: Theme.colors.wifiPasswordRevealBg

              Text {
                anchors.centerIn: parent
                text: root.revealPassword ? "Hide" : "Show"
                color: Theme.colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 4
                font.bold: true
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.revealPassword = !root.revealPassword
              }
            }
          }

          Row {
            width: parent.width
            spacing: 10

            Rectangle {
              width: (parent.width - 10) / 2
              height: 34
              radius: Math.min(Theme.uiRadius, height / 2)
              color: Theme.colors.surfaceStrong

              Text {
                anchors.centerIn: parent
                text: "Cancel"
                color: Theme.colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
                font.bold: true
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closePasswordPrompt()
              }
            }

            Rectangle {
              width: (parent.width - 10) / 2
              height: 34
              radius: Math.min(Theme.uiRadius, height / 2)
              color: passwordInput.text.length > 0 ? Theme.colors.workspaceActive : Theme.colors.surfaceStrong

              Text {
                anchors.centerIn: parent
                text: "Connect"
                color: passwordInput.text.length > 0 ? Theme.colors.accentText : Theme.colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
                font.bold: true
              }

              MouseArea {
                anchors.fill: parent
                enabled: passwordInput.text.length > 0
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.submitPassword()
              }
            }
          }
        }
      }

      Text {
        visible: !root.compactMode
        text: "Nearby networks"
        color: Theme.colors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        font.bold: true
      }

      Text {
        width: parent.width
        visible: !root.wifi || !root.wifi.enabled
        text: "Enable Wi-Fi to view nearby networks"
        color: Theme.colors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
      }

      Text {
        width: parent.width
        visible: root.wifi && root.wifi.enabled && (!root.wifi.networks || root.wifi.networks.length === 0)
        text: root.wifi && root.wifi.scanning ? "Scanning for networks…" : "No wireless networks found"
        color: Theme.colors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
      }

      Repeater {
        model: root.wifi && root.wifi.enabled && root.wifi.networks ? root.wifi.networks : []

        Rectangle {
          required property var modelData
          property bool hovered: networkMouse.containsMouse

          width: parent.width
          height: 60
          radius: Math.min(Theme.uiRadius, height / 2)
          color: modelData.active ? Theme.colors.wifiConnectedCardBg : (hovered ? Theme.colors.wifiListCardHoverBg : Theme.colors.wifiListCardBg)
          border.width: 1
          border.color: modelData.active ? Theme.colors.wifiConnectedCardBorder : Theme.colors.wifiListCardBorder

          Row {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Rectangle {
              width: 34
              height: 34
              radius: Math.min(Theme.uiRadius, height / 2)
              anchors.verticalCenter: parent.verticalCenter
              color: modelData.active ? Theme.colors.wifiConnectedIconBg : Theme.colors.wifiListIconBg

              Text {
                anchors.centerIn: parent
                text: root.signalGlyph(modelData.signal)
                color: modelData.active ? Theme.colors.accentStrong : Theme.colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 2
              }
            }

            Column {
              width: parent.width - actionBadge.width - 56
              anchors.verticalCenter: parent.verticalCenter
              spacing: 2

              Row {
                width: parent.width
                spacing: 6

                Text {
                  width: Math.max(0, parent.width - (lockGlyph.visible ? 22 : 0))
                  text: root.networkTitle(modelData)
                  color: Theme.colors.textPrimary
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize - 1
                  font.bold: true
                  elide: Text.ElideRight
                }

                Text {
                  id: lockGlyph
                  visible: modelData.secure
                  text: "󰌾"
                  color: Theme.colors.textMuted
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize - 3
                }
              }

              Text {
                width: parent.width
                visible: !root.compactMode
                text: root.networkSubtitle(modelData)
                color: Theme.colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 4
                elide: Text.ElideRight
              }
            }

            Rectangle {
              id: actionBadge
              width: 74
              height: 28
              radius: Math.min(Theme.uiRadius, height / 2)
              anchors.verticalCenter: parent.verticalCenter
              color: modelData.active ? Theme.colors.workspaceActive : Theme.colors.surfaceStrong

              Text {
                anchors.centerIn: parent
                text: root.actionLabel(modelData)
                color: modelData.active ? Theme.colors.accentText : Theme.colors.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 4
                font.bold: modelData.active
              }
            }
          }

          MouseArea {
            id: networkMouse
            anchors.fill: parent
            enabled: !!(root.wifi && root.wifi.enabled && modelData.ssid && modelData.ssid.length > 0 && !modelData.active)
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.runNetworkAction(modelData)
          }
        }
      }
    }
  }
}
