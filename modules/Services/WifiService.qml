import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property bool enabled: false
  property string connectedSsid: ""
  property int connectedSignal: 0
  property var networks: []

  function refresh() {
    stateProc.running = true
    listProc.running = true
  }

  function scanNow() {
    scanProc.running = true
    delayedRefresh.running = true
  }

  function connect(ssid) {
    if (!ssid || ssid.length === 0) return
    connectProc.exec(["sh", "-lc", "nmcli --wait 3 dev wifi connect \"" + ssid.replace(/\"/g, "\\\"") + "\" >/dev/null 2>&1 || nmcli con up \"" + ssid.replace(/\"/g, "\\\"") + "\" >/dev/null 2>&1"])
    delayedRefresh.running = true
  }

  function applyState(payload) {
    var text = (payload || "").trim()
    root.enabled = text === "enabled"
  }

  function applyList(payload) {
    var lines = (payload || "").split(/\r?\n/)
    var parsed = []
    var activeName = ""
    var activeSig = 0
    var i
    for (i = 0; i < lines.length; i++) {
      var line = lines[i]
      if (!line || line.trim().length === 0) continue
      var parts = line.split(":")
      if (parts.length < 4) continue
      var active = parts[0] === "yes"
      var ssid = parts[1]
      var signal = parseInt(parts[2], 10)
      var secure = parts[3] && parts[3].trim().length > 0
      parsed.push({ active: active, ssid: ssid, signal: isNaN(signal) ? 0 : signal, secure: secure })
      if (active) {
        activeName = ssid
        activeSig = isNaN(signal) ? 0 : signal
      }
    }
    root.networks = parsed
    root.connectedSsid = activeName
    root.connectedSignal = activeSig
  }

  Process {
    id: stateProc
    command: ["sh", "-lc", "nmcli -t -f WIFI g 2>/dev/null || echo disabled"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.applyState(this.text)
    }
  }

  Process {
    id: listProc
    command: ["sh", "-lc", "nmcli -t -f ACTIVE,SSID,SIGNAL,SECURITY dev wifi list --rescan no 2>/dev/null || true"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.applyList(this.text)
    }
  }

  Process {
    id: scanProc
    command: ["sh", "-lc", "nmcli dev wifi rescan >/dev/null 2>&1 || true"]
  }

  Process { id: connectProc }

  Timer {
    interval: 4000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Timer {
    id: delayedRefresh
    interval: 900
    repeat: false
    onTriggered: root.refresh()
  }
}
