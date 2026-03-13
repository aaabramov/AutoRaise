# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AutoRaise is a macOS utility that automatically raises and focuses windows on mouse hover. It's a single-file Objective-C++ project (`AutoRaise.mm`, ~2050 lines) with a Makefile build system. The .app bundle includes a menu bar status icon for runtime configuration and a preferences window.

## Build Commands

```bash
make            # Build both CLI binary and .app bundle (default target: all)
make clean      # Remove binaries and .app directory
make install    # Install AutoRaise.app to /Applications
make build      # Clean build with experimental flags (EXPERIMENTAL_FOCUS_FIRST, OLD_ACTIVATION_METHOD)
make run        # Build with experimental flags and execute
make debug      # Build with experimental flags, verbose logging, and execute
make update     # Build and install to /Applications
```

Compiler: `g++` with `-fobjc-arc -O2`. Requires Xcode Command Line Tools.

## Architecture

The entire application lives in `AutoRaise.mm` — a monolithic Objective-C++ file organized into these sections:

1. **Configuration & Constants** (~lines 1-167) — Global vars, feature flags, hard-coded app lists for special handling
2. **Private API Declarations** (~lines 66-87) — SkyLight/CGS private APIs for focus-first and cursor scaling
3. **Core Helper Functions** (~lines 224-607) — Window detection (`get_mousewindow`, `get_raisable_window`, `topwindow`, `fallback`), activation (`activate`, `raiseAndActivate`), mouse warping (`get_mousepoint`), environment checks (`dock_active`, `mc_active`, `findScreen`)
4. **Workspace Watcher** (`MDWorkspaceWatcher`, ~lines 683-775) — NSObject that handles space changes, app activation, cursor scaling (with separate up/down methods), and drives the main polling timer
5. **Configuration Class** (`ConfigClass`, ~lines 800-914) — Parses CLI args and config files (`~/.AutoRaise` or `~/.config/AutoRaise/config`). Config file is always loaded first; CLI args override.
6. **Preferences Window** (`PreferencesWindowController`, ~lines 920-1095) — NSPanel with sliders for delay, scale duration, warp X/Y; popup for disable key; text fields for ignore apps/titles. Changes are applied live and saved to config.
7. **Status Bar Controller** (`StatusBarController`, ~lines 1100-1450) — Menu bar icon (`cursorarrow.rays` SF Symbol). Left-click toggles enable/disable; right-click opens context menu with delay submenu, warp toggle, scale submenu, boolean toggles, preferences, and quit. Persists settings to `~/.config/AutoRaise/config`.
8. **Event Handling & Main Loop** (~lines 1455-1840) — `onTick()` polling loop (mouse tracking, raise/focus logic), `eventTapHandler()` for global keyboard events (cmd-tab detection, disable key)
9. **Main Entry Point** (~lines 1877-2048) — Config loading, accessibility permission check, event tap setup, status bar initialization, NSRunLoop

## Key Compilation Flags

- `EXPERIMENTAL_FOCUS_FIRST` — Enables focus-without-raise via private SkyLight API
- `OLD_ACTIVATION_METHOD` — Uses deprecated ProcessSerialNumber API for problematic apps
- `ALTERNATIVE_TASK_SWITCHER` — Compatibility for third-party task switchers (e.g., AltTab)

## macOS Frameworks

AppKit, ApplicationServices, CoreFoundation, Carbon (legacy), SkyLight (optional private framework auto-detected at build time).

## Key Design Patterns

- **Polling loop**: Timer fires every `pollMillis` ms, checks mouse position against windows
- **Event tap**: Global CGEventTap monitors modifier keys and cmd-tab for disable/task-switch detection
- **Fallback chain**: Multiple window detection methods (`get_mousewindow` → `fallback`) for reliability across apps
- **Hard-coded app quirk lists**: Special handling for apps like Finder desktop, IntelliJ (raises on focus), PWAs (Chrome/Brave), and apps without window titles (System Settings, Calculator)
- **Menu bar status icon**: Left-click toggles raise on/off, right-click shows context menu. App runs as accessory (`NSApplicationActivationPolicyAccessory`)
- **Live config persistence**: Changes made via menu/preferences are saved immediately to `~/.config/AutoRaise/config`
- **Config layering**: Config file is always read first as base; CLI arguments override file values
