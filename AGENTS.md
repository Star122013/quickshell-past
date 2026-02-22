# AGENTS.md

This file provides context and guidelines for AI agents working on this Quickshell codebase.

## Project Overview

This is a Quickshell (QML-based Wayland shell) configuration, specifically integrated with the Niri compositor.
- **Entry Point:** `shell.qml`
- **Modules:** Located in `modules/` (e.g., `Bar`, `Services`, `Theme`).
- **Dependencies:** Managed via `devbox.json` (includes `qt6-declarative`, `ffmpeg`).

## Build and Run Commands

Since this is an interpreted QML environment, there is no compilation step.

### Run
To launch the shell configuration:
```bash
quickshell -p shell.qml
# Or simply
quickshell
```

### Dev Environment
Ensure you are in the `devbox` shell environment if available:
```bash
devbox shell
```

### Linting
This project uses `.qmlls.ini` for QML Language Server configuration.
- To lint, use standard QML tools if available, or rely on `qmllint`.
- Ensure no syntax errors before running.

### Testing
There are no automated tests.
- **Manual Verification:** Run `quickshell -p shell.qml` to visually verify changes.
- **Debugging:** Use `console.log()` for output, which appears in the terminal running `quickshell`.

## Code Style & Conventions

### QML
- **Indentation:** 2 spaces.
- **Naming:**
  - Components/Files: PascalCase (e.g., `NiriService.qml`, `Bar.qml`).
  - IDs: camelCase, descriptive (e.g., `root`, `niri`, `panel`).
  - Properties: camelCase.
- **Imports:**
  - Group imports: System/Library first, then local modules.
  - Example:
    ```qml
    import Quickshell
    import QtQuick

    import "./modules/Services"
    ```
- **Root Elements:** Use `Scope` as the root element for non-visual logic or grouping.
- **Screen Management:** Use `Variants` with `Quickshell.screens` for per-screen components (like bars).

### JavaScript (QML)
- **Standard:** ES5/QML JS.
- **Variables:** Use `var` (as seen in `theme.js` and `NiriService.qml`).
- **Theme:**
  - All styling constants (colors, fonts, sizes) must be in `modules/Theme/theme.js`.
  - Import as: `import "../Theme/theme.js" as Theme`.
  - Usage: `Theme.colors.bg`, `Theme.outerGap`.

### Directory Structure
- `modules/`: Contains all functional components.
  - `Services/`: Logic and backend integration (e.g., `NiriService.qml`).
  - `Bar/`: UI components for the panel.
  - `Theme/`: Shared styling definitions.

## Niri Integration
- **Command Handling:** All `niri msg` interactions are centralized in `modules/Services/NiriService.qml`.
- **Compatibility:** Commands use fallbacks (e.g., `niri msg -j workspaces` vs `niri msg workspaces -j`) to support different Niri versions.
- **Parsing:** Use `JSON.parse` inside `try-catch` blocks to handle potentially malformed output safely.

## Error Handling
- **Defensive Coding:** Check for `undefined` or `null` when parsing external data (like JSON from `niri`).
- **Fallback:** Provide default values if command execution fails or returns empty output.

## Quickshell Specifics

### Process Management
- Use `Quickshell.Io.Process` for executing shell commands.
- Always handle `stdout` and `stderr` appropriately.
- Example:
  ```qml
  Process {
    id: proc
    command: ["sh", "-c", "echo hello"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: console.log(text)
    }
  }
  ```

### Window Management
- Use `PanelWindow` for bars and overlays.
- Set `exclusiveZone` if the window should reserve space (like a top/bottom bar).
- Use `anchors` to position relative to the screen edges.

### System Interaction
- Quickshell provides specific bindings for system interaction; prefer these over generic Qt types where available.
- Consult Quickshell documentation (or existing code) for specific module imports like `Quickshell.Wayland`.

## Common Tasks

### Adding a New Bar Widget
1. Create the component in `modules/Bar/widgets/`.
2. Use `Theme` for styling.
3. Import and add to `LeftSection`, `CenterSection`, or `RightSection` in `modules/Bar/sections/`.

### Updating Theme
1. Modify `modules/Theme/theme.js`.
2. Add new properties if needed, ensuring they follow the existing naming scheme (camelCase).
3. Update all usages to reference the new properties.
