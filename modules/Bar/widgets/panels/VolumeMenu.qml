import QtQuick

import "../../../Theme/theme.js" as Theme

Rectangle {
  id: root

  required property bool open
  required property var audio
  property bool compactMode: false
  property real popupScale: root.open ? 1 : 0.96
  property real volumeRatio: Math.max(0, Math.min(1, (root.audio ? root.audio.volumePercent : 0) / 150))
  property string deviceSection: "outputs"
  property var currentDevices: root.deviceSection === "inputs"
    ? (root.audio && root.audio.sources ? root.audio.sources : [])
    : (root.audio && root.audio.sinks ? root.audio.sinks : [])

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

  function containsAny(text, values) {
    var index
    for (index = 0; index < values.length; index++) {
      if (text.indexOf(values[index]) >= 0) return true
    }
    return false
  }

  function displayDeviceName(device, inputDevice) {
    var raw = device && device.name ? device.name : ""
    var name = raw.toLowerCase()
    var prefix = ""
    var cleaned = raw

    cleaned = cleaned.replace(/\s+\[(?:vol|mute):[^\]]*\]\s*$/i, "")
    cleaned = cleaned.replace(/\bAnalog Stereo\b/gi, "")
    cleaned = cleaned.replace(/\bDigital Stereo\b/gi, "")
    cleaned = cleaned.replace(/\bDigital Surround [0-9.]+\b/gi, "")
    cleaned = cleaned.replace(/\bBuilt-?in Audio\b/gi, "Built-in")
    cleaned = cleaned.replace(/\s+/g, " ").trim()

    if (inputDevice) {
      if (root.containsAny(name, ["webcam", "camera"])) prefix = "Webcam Mic"
      else if (root.containsAny(name, ["blue", "bluetooth", "a2dp"])) prefix = "Bluetooth Mic"
      else if (root.containsAny(name, ["usb"])) prefix = "USB Mic"
      else if (root.containsAny(name, ["headset", "headphone", "earbud", "airpods"])) prefix = "Headset Mic"
      else if (root.containsAny(name, ["internal", "built-in", "built in", "pci", "analog"])) prefix = "Built-in Mic"
      else if (root.containsAny(name, ["mic", "microphone", "input"])) prefix = "Microphone"
    } else {
      if (root.containsAny(name, ["hdmi", "displayport", "display port", "display", "monitor"])) prefix = "Monitor Audio"
      else if (root.containsAny(name, ["blue", "bluetooth", "a2dp"])) prefix = "Bluetooth Audio"
      else if (root.containsAny(name, ["headphone", "headset", "earbud", "airpods", "buds"])) prefix = "Headphones"
      else if (root.containsAny(name, ["usb"])) prefix = "USB Audio"
      else if (root.containsAny(name, ["speaker", "internal", "built-in", "built in", "pci", "analog"])) prefix = "Built-in Speakers"
    }

    if (cleaned.length === 0) return prefix.length > 0 ? prefix : (inputDevice ? "Microphone" : "Speakers")
    if (prefix.length === 0) return cleaned
    if (cleaned.toLowerCase() === prefix.toLowerCase()) return cleaned
    if (cleaned.toLowerCase().indexOf(prefix.toLowerCase()) >= 0) return cleaned
    return prefix + " · " + cleaned
  }

  function activeSinkName() {
    var devices = root.audio && root.audio.sinks ? root.audio.sinks : []
    var index
    for (index = 0; index < devices.length; index++) {
      if (devices[index].isDefault) return root.displayDeviceName(devices[index], false)
    }
    return "Default output"
  }

  function activeSourceName() {
    var devices = root.audio && root.audio.sources ? root.audio.sources : []
    var index
    for (index = 0; index < devices.length; index++) {
      if (devices[index].isDefault) return root.displayDeviceName(devices[index], true)
    }
    return "Default input"
  }

  function sliderPercent(posX) {
    var width = Math.max(1, sliderTrack.width)
    var ratio = Math.max(0, Math.min(1, posX / width))
    return Math.round(ratio * 150)
  }

  function deviceGlyph(device, inputDevice) {
    var name = device && device.name ? device.name.toLowerCase() : ""
    if (inputDevice) {
      if (name.indexOf("blue") >= 0) return "󰂯"
      if (name.indexOf("mic") >= 0 || name.indexOf("input") >= 0) return "󰍬"
      return "󰍬"
    }

    if (name.indexOf("blue") >= 0) return "󰂯"
    if (name.indexOf("head") >= 0 || name.indexOf("bud") >= 0 || name.indexOf("ear") >= 0) return "󰋋"
    if (name.indexOf("hdmi") >= 0 || name.indexOf("display") >= 0) return "󰍹"
    return "󰓃"
  }

  function useDevice(device) {
    if (!root.audio || !device || !device.id) return
    if (root.deviceSection === "inputs") root.audio.setDefaultSource(device.id)
    else root.audio.setDefaultSink(device.id)
  }

  function emptyText() {
    return root.deviceSection === "inputs" ? "No audio inputs found" : "No audio outputs found"
  }

  onOpenChanged: {
    if (root.open && root.audio && root.audio.refresh) root.audio.refresh()
  }

  Column {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 9

    Row {
      width: parent.width
      spacing: 8

      Text {
        width: parent.width - muteBadge.width - 8
        text: "Sound"
        color: Theme.colors.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 1
        font.bold: true
        elide: Text.ElideRight
      }

      Rectangle {
        id: muteBadge
        width: 72
        height: 24
        radius: Theme.radiusSm
        color: root.audio && root.audio.muted ? Theme.colors.workspaceActive : Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: root.audio && root.audio.muted ? "Muted" : "Live"
          color: root.audio && root.audio.muted ? Theme.colors.accentText : Theme.colors.textMuted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 3
          font.bold: root.audio && root.audio.muted
        }
      }
    }

    Rectangle {
      width: parent.width
      height: 98
      radius: Theme.radiusSm
      color: Theme.colors.surfaceStrong

      Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        Row {
          width: parent.width
          spacing: 10

          Text {
            width: 28
            text: root.audio && root.audio.muted ? "󰝟" : "󰕾"
            color: root.audio && root.audio.muted ? Theme.colors.textMuted : Theme.colors.info
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 6
            horizontalAlignment: Text.AlignHCenter
          }

          Column {
            width: parent.width - 38
            spacing: 1

            Text {
              text: (root.audio ? root.audio.volumePercent : 0) + "%"
              color: Theme.colors.textPrimary
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize + 6
              font.bold: true
            }

            Text {
              width: parent.width
              visible: !root.compactMode
              text: root.activeSinkName()
              color: Theme.colors.textMuted
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 2
              elide: Text.ElideRight
            }
          }
        }

        Rectangle {
          id: sliderTrack
          width: parent.width
          height: 8
          radius: Math.min(Theme.uiRadius, height / 2)
          color: Theme.colors.surfaceRaised

          Rectangle {
            width: Math.max(0, parent.width * root.volumeRatio)
            height: parent.height
            radius: parent.radius
            color: root.audio && root.audio.muted ? Theme.colors.textMuted : Theme.colors.workspaceActive
          }

          Rectangle {
            width: 14
            height: 14
            radius: height / 2
            x: Math.max(0, Math.min(parent.width - width, parent.width * root.volumeRatio - width / 2))
            y: (parent.height - height) / 2
            color: Theme.colors.textPrimary
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: function(mouse) {
              if (root.audio && root.audio.setVolumePercent) root.audio.setVolumePercent(root.sliderPercent(mouse.x))
            }
            onPositionChanged: function(mouse) {
              if (pressed && root.audio && root.audio.setVolumePercent) root.audio.setVolumePercent(root.sliderPercent(mouse.x))
            }
          }
        }

        Row {
          width: parent.width
          visible: !root.compactMode

          Text {
            text: "0%"
            color: Theme.colors.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 4
          }

          Item {
            width: parent.width - 48
            height: 1
          }

          Text {
            text: "150%"
            color: Theme.colors.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 4
          }
        }
      }
    }

    Row {
      width: parent.width
      spacing: 8

      Rectangle {
        width: (parent.width - 24) / 4
        height: 28
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: "-5"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: if (root.audio) root.audio.stepVolume(-5)
        }
      }

      Rectangle {
        width: (parent.width - 24) / 4
        height: 28
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: root.audio && root.audio.muted ? "Unmute" : "Mute"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: if (root.audio) root.audio.toggleMute()
        }
      }

      Rectangle {
        width: (parent.width - 24) / 4
        height: 28
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: "+5"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: if (root.audio) root.audio.stepVolume(5)
        }
      }

      Rectangle {
        width: (parent.width - 24) / 4
        height: 28
        radius: Theme.radiusSm
        color: Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: "Refresh"
          color: Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 3
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: if (root.audio && root.audio.refresh) root.audio.refresh()
        }
      }
    }

    Row {
      width: parent.width
      spacing: 8

      Rectangle {
        width: (parent.width - 8) / 2
        height: 30
        radius: Theme.radiusSm
        color: root.deviceSection === "outputs" ? Theme.colors.workspaceActive : Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: "Outputs"
          color: root.deviceSection === "outputs" ? Theme.colors.accentText : Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
          font.bold: root.deviceSection === "outputs"
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.deviceSection = "outputs"
        }
      }

      Rectangle {
        width: (parent.width - 8) / 2
        height: 30
        radius: Theme.radiusSm
        color: root.deviceSection === "inputs" ? Theme.colors.workspaceActive : Theme.colors.surfaceStrong

        Text {
          anchors.centerIn: parent
          text: "Inputs"
          color: root.deviceSection === "inputs" ? Theme.colors.accentText : Theme.colors.textPrimary
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
          font.bold: root.deviceSection === "inputs"
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.deviceSection = "inputs"
        }
      }
    }

    Text {
      visible: !root.compactMode
      text: root.deviceSection === "inputs" ? "Input devices" : "Output devices"
      color: Theme.colors.textMuted
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 1
      font.bold: true
    }

    Item {
      width: parent.width
      height: parent.height - 234

      Text {
        anchors.centerIn: parent
        visible: !(root.currentDevices && root.currentDevices.length > 0)
        text: root.emptyText()
        color: Theme.colors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
      }

      Flickable {
        anchors.fill: parent
        clip: true
        visible: root.currentDevices && root.currentDevices.length > 0
        contentWidth: width
        contentHeight: devicesColumn.height

        Column {
          id: devicesColumn
          width: parent.width
          spacing: 6

          Repeater {
            model: root.currentDevices

            Rectangle {
              required property var modelData

              width: devicesColumn.width
              height: 46
              radius: Theme.radiusSm
              color: modelData.isDefault ? Theme.colors.workspaceOccupied : Theme.colors.surfaceStrong
              border.width: modelData.isDefault ? 1 : 0
              border.color: modelData.isDefault ? Theme.colors.workspaceActive : "transparent"

              Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: root.deviceGlyph(modelData, root.deviceSection === "inputs")
                color: modelData.isDefault ? Theme.colors.workspaceActive : Theme.colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 2
              }

              Text {
                anchors.left: parent.left
                anchors.leftMargin: 38
                anchors.right: parent.right
                anchors.rightMargin: 76
                anchors.verticalCenter: parent.verticalCenter
                text: root.displayDeviceName(modelData, root.deviceSection === "inputs")
                color: Theme.colors.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: modelData.isDefault
                elide: Text.ElideRight
              }

              Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 58
                height: 24
                radius: Theme.radiusSm
                color: modelData.isDefault ? Theme.colors.workspaceActive : Theme.colors.surfaceRaised

                Text {
                  anchors.centerIn: parent
                  text: modelData.isDefault ? "Active" : "Use"
                  color: modelData.isDefault ? Theme.colors.accentText : Theme.colors.textPrimary
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize - 3
                  font.bold: modelData.isDefault
                }
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: !modelData.isDefault
                onClicked: root.useDevice(modelData)
              }
            }
          }
        }
      }
    }
  }
}
