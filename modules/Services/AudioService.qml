import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property int volumePercent: 0
  property bool muted: false
  property var sinks: []

  function refresh() {
    volumeProc.running = true
    sinksProc.running = true
  }

  function setDefaultSink(id) {
    if (!id) return
    actionProc.exec(["sh", "-lc", "wpctl set-default " + id])
    delayedRefresh.running = true
  }

  function stepVolume(delta) {
    if (delta === 0) return
    var suffix = delta > 0 ? "+" : "-"
    actionProc.exec(["sh", "-lc", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.abs(delta) + "%" + suffix])
    delayedRefresh.running = true
  }

  function toggleMute() {
    actionProc.exec(["sh", "-lc", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"])
    delayedRefresh.running = true
  }

  function applyVolume(payload) {
    var text = (payload || "").trim()
    if (text.length === 0) return
    var m = text.match(/Volume:\s*([0-9.]+)/)
    if (m && m[1]) root.volumePercent = Math.max(0, Math.min(150, Math.round(parseFloat(m[1]) * 100)))
    root.muted = text.indexOf("MUTED") >= 0
  }

  function applySinks(payload) {
    var lines = (payload || "").split(/\r?\n/)
    var parsed = []
    var inSinks = false
    var i
    for (i = 0; i < lines.length; i++) {
      var raw = lines[i]
      var line = raw.trim()
      if (line.indexOf("Sinks:") === 0) {
        inSinks = true
        continue
      }
      if (line.indexOf("Sources:") === 0) {
        inSinks = false
        continue
      }
      if (!inSinks || line.length === 0) continue

      var m = raw.match(/^\s*([*])?[^0-9]*([0-9]+)\.\s+(.*)$/)
      if (!m) continue
      parsed.push({
        id: m[2],
        name: m[3],
        isDefault: m[1] === "*"
      })
    }
    root.sinks = parsed
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
    id: sinksProc
    command: ["sh", "-lc", "wpctl status -n 2>/dev/null || true"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.applySinks(this.text)
    }
  }

  Process { id: actionProc }

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
