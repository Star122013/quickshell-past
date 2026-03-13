import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property bool enabled: false
  property bool scanning: false
  property string connectedSsid: ""
  property int connectedSignal: 0
  property string pendingSsid: ""
  property string connectionMessage: ""
  property string connectionError: ""
  property var networks: []
  property var savedNetworks: []
  property var ethernetConnections: []

  function scheduleRefresh(intervalMs) {
    delayedRefresh.interval = intervalMs || 900
    delayedRefresh.running = false
    delayedRefresh.running = true
  }

  function shellQuote(text) {
    return "'" + String(text || "").replace(/'/g, "'\\''") + "'"
  }

  function parseFields(line) {
    var parts = []
    var current = ""
    var escaping = false
    var index

    for (index = 0; index < line.length; index++) {
      var ch = line.charAt(index)
      if (escaping) {
        current += ch
        escaping = false
        continue
      }

      if (ch === "\\") {
        escaping = true
        continue
      }

      if (ch === ":") {
        parts.push(current)
        current = ""
        continue
      }

      current += ch
    }

    if (escaping) current += "\\"
    parts.push(current)
    return parts
  }

  function containsValue(list, value) {
    var i
    for (i = 0; i < list.length; i++) {
      if (list[i] === value)
        return true
    }
    return false
  }

  function sortNetworks(list) {
    list.sort(function(left, right) {
      if (left.active !== right.active) return left.active ? -1 : 1

      var leftHidden = !left.ssid || left.ssid.length === 0
      var rightHidden = !right.ssid || right.ssid.length === 0
      if (leftHidden !== rightHidden) return leftHidden ? 1 : -1

      if (left.saved !== right.saved) return left.saved ? -1 : 1
      if (left.signal !== right.signal) return right.signal - left.signal

      var leftName = (left.ssid || "").toLowerCase()
      var rightName = (right.ssid || "").toLowerCase()
      if (leftName < rightName) return -1
      if (leftName > rightName) return 1
      return 0
    })
  }

  function refresh() {
    stateProc.running = true
    savedProc.running = true
    listProc.running = true
    wiredProc.running = true
  }

  function setEnabled(nextEnabled) {
    root.enabled = nextEnabled
    toggleProc.exec(["sh", "-lc", "nmcli radio wifi " + (nextEnabled ? "on" : "off") + " >/dev/null 2>&1 || true"])

    if (!nextEnabled) {
      root.scanning = false
      root.pendingSsid = ""
      root.connectedSsid = ""
      root.connectedSignal = 0
      root.connectionMessage = ""
      root.connectionError = ""
      root.networks = []
    }

    root.scheduleRefresh(650)
  }

  function scanNow() {
    if (!root.enabled) {
      root.scanning = false
      return
    }

    root.scanning = true
    root.connectionMessage = "Scanning nearby networks…"
    root.connectionError = ""
    scanProc.running = true
    resultClear.running = false
    resultClear.running = true
    root.scheduleRefresh(1200)
  }

  function connect(ssid) {
    if (!ssid || ssid.length === 0)
      return

    var quoted = root.shellQuote(ssid)
    root.pendingSsid = ssid
    root.connectionMessage = "Connecting to " + ssid + "…"
    root.connectionError = ""
    connectProc.exec(["sh", "-lc", "nmcli --wait 8 connection up id " + quoted + " || nmcli --wait 12 device wifi connect " + quoted])
    pendingClear.running = false
    pendingClear.running = true
    resultClear.running = false
    resultClear.running = true
    root.scheduleRefresh(1300)
  }

  function connectWithPassword(ssid, password) {
    if (!ssid || ssid.length === 0 || !password || password.length === 0)
      return

    var quoted = root.shellQuote(ssid)
    var pass = root.shellQuote(password)
    root.pendingSsid = ssid
    root.connectionMessage = "Connecting to " + ssid + "…"
    root.connectionError = ""
    connectProc.exec(["sh", "-lc", "nmcli --wait 15 device wifi connect " + quoted + " password " + pass])
    pendingClear.running = false
    pendingClear.running = true
    resultClear.running = false
    resultClear.running = true
    root.scheduleRefresh(1600)
  }

  function applySavedFlags() {
    if (!root.networks || root.networks.length === 0)
      return

    var updated = []
    var i
    for (i = 0; i < root.networks.length; i++) {
      var network = root.networks[i]
      updated.push({
        active: network.active,
        ssid: network.ssid,
        signal: network.signal,
        secure: network.secure,
        saved: network.ssid && network.ssid.length > 0 ? root.containsValue(root.savedNetworks, network.ssid) : false
      })
    }

    root.sortNetworks(updated)
    root.networks = updated
  }

  function applyState(payload) {
    var text = (payload || "").trim()
    root.enabled = text === "enabled" || text === "on" || text === "true"

    if (!root.enabled) {
      root.scanning = false
      root.connectedSsid = ""
      root.connectedSignal = 0
      root.pendingSsid = ""
      root.networks = []
    }
  }

  function applySavedNetworks(payload) {
    var lines = (payload || "").split(/\r?\n/)
    var parsed = []
    var index

    for (index = 0; index < lines.length; index++) {
      var line = lines[index]
      if (!line || line.trim().length === 0)
        continue

      var fields = root.parseFields(line)
      if (fields.length < 2)
        continue

      var name = fields[0] || ""
      var type = fields[1] || ""
      if ((type === "802-11-wireless" || type === "wifi") && name.length > 0)
        parsed.push(name)
    }

    parsed.sort()
    root.savedNetworks = parsed
    root.applySavedFlags()
  }

  function applyList(payload) {
    var lines = (payload || "").split(/\r?\n/)
    var bestByKey = {}
    var hiddenCount = 0
    var activeName = ""
    var activeSignal = 0
    var index

    for (index = 0; index < lines.length; index++) {
      var line = lines[index]
      if (!line || line.trim().length === 0)
        continue

      var fields = root.parseFields(line)
      if (fields.length < 4)
        continue

      var active = fields[0] === "yes" || fields[0] === "*"
      var ssid = fields[1] || ""
      var signal = parseInt(fields[2], 10)
      var secure = !!(fields[3] && fields[3].trim().length > 0)
      var network = {
        active: active,
        ssid: ssid,
        signal: isNaN(signal) ? 0 : signal,
        secure: secure,
        saved: ssid.length > 0 ? root.containsValue(root.savedNetworks, ssid) : false
      }

      if (active) {
        activeName = ssid
        activeSignal = network.signal
      }

      var key = ssid.length > 0 ? ssid : "__hidden_" + (++hiddenCount)
      var previous = bestByKey[key]
      if (!previous || network.active || (!previous.active && network.signal > previous.signal))
        bestByKey[key] = network
    }

    var parsed = []
    for (var key in bestByKey) {
      if (bestByKey.hasOwnProperty(key))
        parsed.push(bestByKey[key])
    }

    root.sortNetworks(parsed)
    root.networks = root.enabled ? parsed : []
    root.connectedSsid = activeName
    root.connectedSignal = activeSignal
    root.scanning = false

    if (activeName.length > 0 && root.pendingSsid === activeName) {
      root.pendingSsid = ""
      root.connectionError = ""
      root.connectionMessage = "Connected to " + activeName
      resultClear.running = false
      resultClear.running = true
    }
  }

  function applyWired(payload) {
    var lines = (payload || "").split(/\r?\n/)
    var parsed = []
    var index

    for (index = 0; index < lines.length; index++) {
      var line = lines[index]
      if (!line || line.trim().length === 0)
        continue

      var fields = root.parseFields(line)
      if (fields.length < 4)
        continue

      if ((fields[1] || "") !== "ethernet")
        continue

      parsed.push({
        device: fields[0] || "",
        type: fields[1] || "",
        state: fields[2] || "unknown",
        connection: fields[3] && fields[3] !== "--" ? fields[3] : ""
      })
    }

    parsed.sort(function(left, right) {
      if ((left.state === "connected") !== (right.state === "connected"))
        return left.state === "connected" ? -1 : 1
      if ((left.device || "") < (right.device || "")) return -1
      if ((left.device || "") > (right.device || "")) return 1
      return 0
    })

    root.ethernetConnections = parsed
  }

  function applyConnectOutput(payload, isError) {
    var text = String(payload || "").replace(/\r?\n+/g, " ").trim()
    if (text.length === 0)
      return

    if (isError)
      root.connectionError = text
    else
      root.connectionMessage = text

    resultClear.running = false
    resultClear.running = true
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
    id: savedProc
    command: ["sh", "-lc", "nmcli -t -f NAME,TYPE connection show 2>/dev/null || true"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.applySavedNetworks(this.text)
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
    id: wiredProc
    command: ["sh", "-lc", "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev status 2>/dev/null || true"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.applyWired(this.text)
    }
  }

  Process {
    id: scanProc
    command: ["sh", "-lc", "nmcli dev wifi rescan >/dev/null 2>&1 || true"]
  }

  Process {
    id: toggleProc
  }

  Process {
    id: connectProc
    stdout: StdioCollector {
      onStreamFinished: root.applyConnectOutput(this.text, false)
    }
    stderr: StdioCollector {
      onStreamFinished: root.applyConnectOutput(this.text, true)
    }
  }

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

  Timer {
    id: pendingClear
    interval: 12000
    repeat: false
    onTriggered: {
      if (root.pendingSsid.length > 0 && root.connectedSsid !== root.pendingSsid && root.connectionError.length === 0)
        root.connectionError = "Connection timed out"
      root.pendingSsid = ""
    }
  }

  Timer {
    id: resultClear
    interval: 5200
    repeat: false
    onTriggered: {
      if (root.pendingSsid.length === 0)
        root.connectionMessage = ""
      if (root.pendingSsid.length === 0)
        root.connectionError = ""
    }
  }
}
