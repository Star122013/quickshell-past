import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property int cpuPercent: 0
  property int memPercent: 0
  property int diskPercent: 0
  property string statsScript: [
    "read_cpu_sample() {",
    "  awk '/^cpu / { print $2+$3+$4+$5+$6+$7+$8+$9, $5 }' /proc/stat",
    "}",
    "",
    "set -- $(read_cpu_sample)",
    "total1=$1",
    "idle1=$2",
    "",
    "sleep 0.15",
    "",
    "set -- $(read_cpu_sample)",
    "total2=$1",
    "idle2=$2",
    "",
    "total_delta=$((total2-total1))",
    "idle_delta=$((idle2-idle1))",
    "if [ \"$total_delta\" -le 0 ]; then",
    "  cpu=0",
    "else",
    "  cpu=$(( (100 * (total_delta - idle_delta)) / total_delta ))",
    "fi",
    "",
    "mem=$(awk '/MemTotal:/ { total=$2 } /MemAvailable:/ { available=$2 } END {",
    "  if (total > 0) printf(\"%d\", (100 * (total - available)) / total)",
    "  else printf(\"0\")",
    "}' /proc/meminfo)",
    "",
    "disk=$(df -P / | awk 'NR == 2 { sub(/%/, \"\", $5); print $5; exit }')",
    "[ -n \"$disk\" ] || disk=0",
    "",
    "printf '%s %s %s\\n' \"$cpu\" \"$mem\" \"$disk\""
  ].join("\n")

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
    command: ["sh", "-lc", root.statsScript]
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
