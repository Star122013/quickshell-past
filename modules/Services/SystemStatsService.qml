import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property int cpuPercent: 0
  property int memPercent: 0
  property int diskPercent: 0

  function refresh() {
    statsProc.running = true
  }

  function applyStats(payload) {
    var text = (payload || "").trim()
    if (text.length === 0) return

    var parts = text.split(/\s+/)
    if (parts.length < 3) return

    var cpu = parseInt(parts[0], 10)
    var mem = parseInt(parts[1], 10)
    var disk = parseInt(parts[2], 10)

    if (!isNaN(cpu)) root.cpuPercent = Math.max(0, Math.min(100, cpu))
    if (!isNaN(mem)) root.memPercent = Math.max(0, Math.min(100, mem))
    if (!isNaN(disk)) root.diskPercent = Math.max(0, Math.min(100, disk))
  }

  Process {
    id: statsProc
    command: [
      "sh",
      "-lc",
      "read _ u1 n1 s1 i1 w1 irq1 sirq1 st1 g1 gn1 < /proc/stat; t1=$((u1+n1+s1+i1+w1+irq1+sirq1+st1)); sleep 0.15; read _ u2 n2 s2 i2 w2 irq2 sirq2 st2 g2 gn2 < /proc/stat; t2=$((u2+n2+s2+i2+w2+irq2+sirq2+st2)); td=$((t2-t1)); id=$((i2-i1)); if [ $td -le 0 ]; then cpu=0; else cpu=$(( (100*(td-id))/td )); fi; mem=$(awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {if (t>0) printf(\"%d\", (100*(t-a))/t); else printf(\"0\")}' /proc/meminfo); disk=$(df -P / | awk 'NR==2{gsub(/%/,\"\",$5); print $5}'); if [ -z \"$disk\" ]; then disk=0; fi; printf '%s %s %s' \"$cpu\" \"$mem\" \"$disk\""
    ]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.applyStats(this.text)
    }
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }
}
