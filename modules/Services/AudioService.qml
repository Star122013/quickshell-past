import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property int volumePercent: 0
  property bool muted: false
  property var sinks: []
  property var sources: []
  property string defaultSinkId: ""
  property string defaultSinkName: ""
  property string defaultSourceId: ""
  property string defaultSourceName: ""

  function scheduleRefresh() {
    delayedRefresh.running = false
    delayedRefresh.running = true
  }

  function clampPercent(percent) {
    return Math.max(0, Math.min(150, Math.round(percent)))
  }

  function refresh() {
    volumeProc.running = true
    statusProc.running = true
  }

  function setDefaultSink(id) {
    if (!id) return
    actionProc.exec(["sh", "-lc", "wpctl set-default " + id])
    root.scheduleRefresh()
  }

  function setDefaultSource(id) {
    if (!id) return
    actionProc.exec(["sh", "-lc", "wpctl set-default " + id])
    root.scheduleRefresh()
  }

  function setVolumePercent(percent) {
    var clamped = root.clampPercent(percent)
    actionProc.exec(["sh", "-lc", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + clamped + "%"])
    root.scheduleRefresh()
  }

  function stepVolume(delta) {
    if (delta === 0) return
    var suffix = delta > 0 ? "+" : "-"
    actionProc.exec(["sh", "-lc", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.abs(delta) + "%" + suffix])
    root.scheduleRefresh()
  }

  function toggleMute() {
    actionProc.exec(["sh", "-lc", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"])
    root.scheduleRefresh()
  }

  function applyVolume(payload) {
    var text = (payload || "").trim()
    if (text.length === 0) return

    var match = text.match(/Volume:\s*([0-9.]+)/)
    if (match && match[1]) root.volumePercent = root.clampPercent(parseFloat(match[1]) * 100)
    root.muted = text.indexOf("MUTED") >= 0
  }

  function lineStartsSection(line, sectionName) {
    return line.indexOf(sectionName + ":") >= 0
  }

  function isSectionHeader(line) {
    return /^[\s│├└─]*[A-Za-z][A-Za-z\s-]*:\s*$/.test(line)
  }

  function parseSection(lines, sectionName, fallbackPrefix) {
    var parsed = []
    var inSection = false
    var currentDefaultId = ""
    var currentDefaultName = ""
    var index

    for (index = 0; index < lines.length; index++) {
      var raw = lines[index]
      var line = raw.trim()

      if (root.lineStartsSection(line, sectionName)) {
        inSection = true
        continue
      }

      if (inSection && root.isSectionHeader(line) && !root.lineStartsSection(line, sectionName)) {
        inSection = false
      }

      if (!inSection || line.length === 0) continue

      var match = raw.match(/^\s*[│├└─ ]*([*])?\s*([0-9]+)\.\s+(.*)$/)
      if (!match) continue

      var name = (match[3] || "").replace(/\s+\[[^\]]*\]\s*$/, "").trim()
      if (name.length === 0) name = fallbackPrefix + " " + match[2]

      var item = {
        id: match[2],
        name: name,
        isDefault: match[1] === "*"
      }

      if (item.isDefault) {
        currentDefaultId = item.id
        currentDefaultName = item.name
      }

      parsed.push(item)
    }

    parsed.sort(function(left, right) {
      if (left.isDefault !== right.isDefault) return left.isDefault ? -1 : 1
      if (left.name < right.name) return -1
      if (left.name > right.name) return 1
      return 0
    })

    return {
      items: parsed,
      defaultId: currentDefaultId,
      defaultName: currentDefaultName
    }
  }

  function applyStatus(payload) {
    var lines = (payload || "").split(/\r?\n/)
    var sinksResult = root.parseSection(lines, "Sinks", "Sink")
    var sourcesResult = root.parseSection(lines, "Sources", "Source")

    root.sinks = sinksResult.items
    root.defaultSinkId = sinksResult.defaultId
    root.defaultSinkName = sinksResult.defaultName

    root.sources = sourcesResult.items
    root.defaultSourceId = sourcesResult.defaultId
    root.defaultSourceName = sourcesResult.defaultName
  }

  Process {
    id: volumeProc
    command: ["sh", "-lc", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.applyVolume(this.text)
    }
  }

  Process {
    id: statusProc
    command: ["sh", "-lc", "wpctl status 2>/dev/null || wpctl status -n 2>/dev/null || true"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.applyStatus(this.text)
    }
  }

  Process {
    id: actionProc
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Timer {
    id: delayedRefresh
    interval: 350
    repeat: false
    onTriggered: root.refresh()
  }
}
