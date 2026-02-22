# Quickshell Past (Niri)

A customized Quickshell configuration for Niri with a themed top bar, system status widgets, tray integration, and popup controls.

## Features

- Per-screen top bar (`PanelWindow` + `Variants`)
- Workspace strip with active/occupied styling
- Center status block:
  - CPU usage ring
  - Memory usage ring
  - Disk usage ring
  - Click-to-open system status popup
- Media status + media control popup (MPRIS)
- Notification indicator + notification center popup
- Right-side quick controls:
  - Volume button + output selection menu
  - Wi-Fi button + network selection menu
  - Bluetooth button + device selection menu
  - Power button + confirmation menu (shutdown/reboot/suspend)
- System tray icons and context menu support

## Structure

- `shell.qml` - entry point
- `modules/Theme/theme.js` - spacing, radius, typography, and colors
- `modules/Services/`
  - `NiriService.qml` - workspace state from `niri msg`
  - `SystemStatsService.qml` - CPU/memory/disk usage sampling
  - `AudioService.qml` - volume + sink selection via `wpctl`
  - `WifiService.qml` - Wi-Fi state/list/connect via `nmcli`
- `modules/Bar/`
  - `Bar.qml` - bar window + popup windows orchestration
  - `sections/` - left/center/right layout
  - `widgets/` - tray, notifications, media popup, menus, etc.

## Dependencies

- `quickshell`
- `niri`
- `wpctl` (PipeWire/WirePlumber)
- `nmcli` (NetworkManager)

Optional but recommended:

- Nerd Font (for icon glyphs)

## Run

```bash
quickshell -p ~/.config/quickshell/shell.qml
```

If this directory is your default quickshell config:

```bash
quickshell
```

## Behavior Notes

- Tray, media, notifications, system status, and quick-control menus are independent popup windows.
- Clicking outside popups closes open menus.
- Tray context menu behavior depends on app-provided DBus menu capabilities.
- Notification server ownership depends on the active `org.freedesktop.Notifications` provider.

## Customization Tips

- Adjust colors/radii/fonts in `modules/Theme/theme.js`
- Tune bar size and spacing in:
  - `modules/Theme/theme.js`
  - `modules/Bar/sections/*.qml`
- Adjust popup placement in `modules/Bar/Bar.qml`

## Troubleshooting

- If notifications do not appear:
  - Check whether another notification daemon owns `org.freedesktop.Notifications`
- If audio outputs are empty:
  - Verify `wpctl status` works in terminal
- If Wi-Fi list is empty:
  - Verify `nmcli -t -f ACTIVE,SSID,SIGNAL,SECURITY dev wifi list` works
