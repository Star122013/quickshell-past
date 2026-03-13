import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property int brightnessPercent: 32
  property bool available: false

  function clampPercent(percent) {
    return Math.max(1, Math.min(100, Math.round(percent)))
  }

  function scheduleRefresh() {
    delayedRefresh.running = false
    delayedRefresh.running = true
  }

  function refresh() {
    queryProc.running = true
  }

  function setBrightnessPercent(percent) {
    var clamped = root.clampPercent(percent)
    root.brightnessPercent = clamped
    actionProc.exec(["sh", "-lc", "if command -v brightnessctl >/dev/null 2>&1; then brightnessctl set " + clamped + "% >/dev/null 2>&1; elif command -v brillo >/dev/null 2>&1; then brillo -q -S " + clamped + " >/dev/null 2>&1; elif command -v light >/dev/null 2>&1; then light -S " + clamped + " >/dev/null 2>&1; fi"])
    root.scheduleRefresh()
  }

  function stepBrightness(delta) {
    if (delta === 0)
      return
    root.setBrightnessPercent(root.brightnessPercent + delta)
  }

  function applyBrightness(payload) {
    var text = (payload || "").trim()
    if (text.length === 0) {
      root.available = false
      return
    }

    var value = parseFloat(text)
    if (isNaN(value)) {
      root.available = false
      return
    }

    root.available = true
    root.brightnessPercent = root.clampPercent(value)
  }

  Process {
    id: queryProc
    command: [
      "sh",
      "-lc",
      "if command -v brightnessctl >/dev/null 2>&1; then current=$(brightnessctl get 2>/dev/null); max=$(brightnessctl max 2>/dev/null); awk -v c=\"$current\" -v m=\"$max\" 'BEGIN { if (m > 0) printf \"%.0f\", (c / m) * 100; }'; elif command -v brillo >/dev/null 2>&1; then brillo -G 2>/dev/null | awk '{ printf \"%.0f\", $1 }'; elif command -v light >/dev/null 2>&1; then light -G 2>/dev/null | awk '{ printf \"%.0f\", $1 }'; fi"
    ]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.applyBrightness(this.text)
    }
  }

  Process {
    id: actionProc
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Timer {
    id: delayedRefresh
    interval: 260
    repeat: false
    onTriggered: root.refresh()
  }
}
