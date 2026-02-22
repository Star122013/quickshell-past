import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property var workspaces: []
  property int activeWorkspaceId: -1
  property string activeWorkspaceName: ""
  property bool available: true
  property string lastError: ""

  function refresh() {
    fetchWorkspaces.running = true
  }

  function focusWorkspace(id) {
    if (id === undefined || id === null) return
    focusWorkspaceProc.exec(["sh", "-lc", "niri msg action focus-workspace " + id + " 2>/dev/null || niri msg focus-workspace " + id + " 2>/dev/null"])
    delayedRefresh.running = true
  }

  function applyWorkspacePayload(payload) {
    var text = (payload || "").trim()
    if (text.length === 0) {
      available = false
      lastError = "niri msg returned empty output"
      return
    }

    var parsed
    try {
      parsed = JSON.parse(text)
    } catch (e) {
      available = false
      lastError = "cannot parse niri json: " + e
      return
    }

    var list = []
    if (Array.isArray(parsed)) list = parsed
    else if (parsed && Array.isArray(parsed.workspaces)) list = parsed.workspaces

    var mapped = []
    var i
    for (i = 0; i < list.length; i++) {
      var ws = list[i]
      if (!ws) continue

      var id = ws.id
      if (id === undefined || id === null) id = ws.idx
      if (id === undefined || id === null) id = ws.index
      if (id === undefined || id === null) id = i + 1

      var active = !!(ws.active || ws.is_active || ws.focused || ws.is_focused)
      var name = ws.name ? String(ws.name) : String(id)
      var occupied = false
      if (ws.is_empty === false || ws.empty === false) occupied = true
      else if (ws.window_count !== undefined && ws.window_count > 0) occupied = true
      else if (ws.windows !== undefined && ws.windows > 0) occupied = true
      else if (ws.active_window_id !== undefined && ws.active_window_id !== null) occupied = true
      else if (ws.has_windows === true) occupied = true

      mapped.push({
        id: id,
        name: name,
        active: active,
        occupied: occupied
      })
    }

    mapped.sort(function(a, b) {
      if (a.id < b.id) return -1
      if (a.id > b.id) return 1
      return 0
    })

    workspaces = mapped
    available = true
    lastError = ""

    var foundId = -1
    var foundName = ""
    for (i = 0; i < mapped.length; i++) {
      if (mapped[i].active) {
        foundId = mapped[i].id
        foundName = mapped[i].name
        break
      }
    }
    activeWorkspaceId = foundId
    activeWorkspaceName = foundName
  }

  Process {
    id: fetchWorkspaces
    command: ["sh", "-lc", "niri msg -j workspaces 2>/dev/null || niri msg workspaces -j 2>/dev/null || niri msg workspaces --json 2>/dev/null"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: root.applyWorkspacePayload(this.text)
    }
  }

  Process {
    id: focusWorkspaceProc
  }

  Timer {
    interval: 100 // Poll much faster (was 1200)
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  // ... (Timer delayedRefresh same but maybe lower)
  Timer {
    id: delayedRefresh
    interval: 50
    repeat: false
    onTriggered: root.refresh()
  }
}
