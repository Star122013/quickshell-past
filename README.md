# Quickshell Past (Niri)

A customized Quickshell configuration for Niri with a full-width top bar, split popup system, themed control surfaces, and a simplified theme pipeline built around Quickshell QML + JS.

## Highlights

- Full-width top bar with shaped outer corners
- Per-screen `PanelWindow` setup via `Variants`
- Left section with:
  - profile/avatar trigger
  - CPU ring
  - memory ring
  - active workspace/window info
- Center section with a compact workspace strip
- Right section with:
  - media chip
  - notification indicator
  - volume / Wi-Fi / Bluetooth controls
  - volume pill
- Popup system for:
  - profile menu
  - system status
  - media
  - notification center
  - Wi-Fi
  - Bluetooth
  - volume device switching
  - power actions
  - tray application menus
- Notification toast support
- Theme split into user-editable entrypoints + derived style layers
- `matugen` template support for generating `modules/Theme/colors.js`

## Project Layout

- `shell.qml` — entry point
- `modules/Bar/`
  - `Bar.qml` — global bar state + popup orchestration
  - `controllers/` — popup / notification coordination logic
  - `layout/` — screen windows and dismiss layers
  - `popups/` — popup host windows / toast windows
  - `sections/` — left / center / right bar sections
  - `widgets/buttons/` — compact right-side control buttons
  - `widgets/chrome/` — structural chrome such as outer corners
  - `widgets/panels/` — actual popup panel components
  - `widgets/strips/` — workspace / tray / notification strips
- `modules/Services/`
  - `NiriService.qml` — workspace / focused window state from `niri msg`
  - `SystemStatsService.qml` — CPU / memory sampling
  - `AudioService.qml` — volume + sink/source switching via `wpctl`
  - `WifiService.qml` — Wi-Fi / ethernet state via `nmcli`
  - `BrightnessService.qml` — brightness helpers
- `modules/Theme/`
  - `userTheme.js` — main user-editable theme entrypoint
  - `theme.js` — derived global theme helpers
  - `colors.js` — semantic color tokens
  - `profileMenuStyle.js` — derived profile menu sizing
  - `barPopupStyle.js` — derived popup sizing access
  - `profileMenuConfig.js` — profile content / greeting / image config
  - `matugen/` — templates and config for color generation

## Theme Editing

If you only want to tweak the shell, start here:

- `modules/Theme/userTheme.js`

That file now contains the main knobs you are expected to edit:

- `typography` — font family and base font size
- `layout` — `barHeight`, `innerGap`, `uiRadius`, top spacing
- `bar` — outer-corner curve behavior
- `profile` — avatar path and profile menu size
- `profileMenu` — major profile-menu sizing groups
- `popup` — widths / heights for popup panels

Everything else is mostly derived from those values.

### Most useful knobs

- Global roundness: `modules/Theme/userTheme.js`
  - `layout.uiRadius`
- Bar height and spacing: `modules/Theme/userTheme.js`
  - `layout.barHeight`
  - `layout.innerGap`
- Outer-corner curve feel: `modules/Theme/userTheme.js`
  - `bar.outerCornerControlFactor`
- Profile avatar image path: `modules/Theme/userTheme.js`
  - `profile.avatarImagePath`
- Popup sizes: `modules/Theme/userTheme.js`
  - `popup.*`

## Colors and Matugen

Color tokens are kept in:

- `modules/Theme/colors.js`

If you want automated color generation, use the included `matugen` template setup:

- Template: `modules/Theme/matugen/colors.template.js`
- Config: `modules/Theme/matugen/quickshell-colors.toml`
- Notes: `modules/Theme/matugen/README.md`

Example:

```bash
matugen image /path/to/wallpaper -m dark -c modules/Theme/matugen/quickshell-colors.toml
```

That command regenerates `modules/Theme/colors.js` while keeping the rest of the shell structure unchanged.

## Dependencies

Required:

- `quickshell`
- `niri`
- `wpctl` (PipeWire / WirePlumber)
- `nmcli` (NetworkManager)

Recommended:

- a Nerd Font for icon glyphs

## Run

From this repo:

```bash
quickshell -p ~/quickshell-past/shell.qml
```

Or if this repo is installed as your default Quickshell config:

```bash
quickshell
```

## Notes

- Popup placement and dismissal are coordinated centrally through the bar controllers.
- Tray menus depend on what the application exposes through the system tray menu interface.
- Notification behavior depends on whether this shell owns `org.freedesktop.Notifications`.
- Offscreen / sandboxed test runs may still fail due to missing Wayland / DBus access even when QML parsing is valid.

## Troubleshooting

- Notifications not showing:
  - make sure another notification daemon is not already active
- Audio devices not showing:
  - check `wpctl status`
- Wi-Fi results empty:
  - check `nmcli device wifi list`
- Niri workspaces missing:
  - check `niri msg -j workspaces`
