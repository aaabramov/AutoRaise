**Hoist**

When you hover a window it will be raised to the front (with a delay of your choosing) and gets the focus. There is also an option to warp
the mouse to the center of the activated window when using the cmd-tab or cmd-grave (backtick) key combination.
See also [on stackoverflow](https://stackoverflow.com/questions/98310/focus-follows-mouse-plus-auto-raise-on-mac-os-x)

**Quick start**

Install via Homebrew (recommended):

    brew install aaabramov/hoist/hoist

Or use the install script:

    curl -fsSL https://raw.githubusercontent.com/aaabramov/Hoist/master/install.sh | bash

Or install manually:

1. Download `Hoist.dmg` from the [latest release](https://github.com/aaabramov/Hoist/releases/latest)
2. Open the DMG and drag Hoist.app into the Applications folder.
3. Remove the quarantine attribute (required for accessibility permissions):
   ```
   xattr -cr /Applications/Hoist.app
   ```
4. Open Hoist from Applications.
5. Left click the menu bar icon to give permissions to Hoist in System/Accessibility.
6. Right click the menu bar icon to set preferences.

*Important*: When you enable Accessibility in System Preferences, if you see an older Hoist item in the
Accessibility pane, first remove it **completely** (clicking the minus). Then stop and start Hoist by left clicking the menu bar
icon. The item should re-appear so that you can properly enable Accessibility.

**Compiling Hoist**

To compile Hoist yourself, clone the repository and use the following commands:

    git clone https://github.com/aaabramov/Hoist.git
    cd Hoist && make clean && make && make install

**Advanced compilation options**

  * ALTERNATIVE_TASK_SWITCHER: The warp feature works accurately with the default OSX task switcher. Enable the alternative
  task switcher flag if you use an alternative task switcher and are willing to accept that in some cases you may encounter
  an unexpected mouse warp.

  * OLD_ACTIVATION_METHOD: Enable this flag if one of your applications is not raising properly. This can happen if the
  application uses a non native graphic technology like GTK or SDL. It could also be a [wine](https://www.winehq.org) application.
  Note this will introduce a deprecation warning.

  * EXPERIMENTAL_FOCUS_FIRST: Enabling this flag adds support for first focusing the hovered window before actually raising it.
  Or not raising at all if the -delay setting equals 0. This is an experimental feature. It relies on undocumented private API
  calls. *As such there is absolutely no guarantee it will be supported in future OSX versions*.

Example advanced compilation command:

    make CXXFLAGS="-DOLD_ACTIVATION_METHOD -DEXPERIMENTAL_FOCUS_FIRST" && make install

**Running Hoist**

After making the project, you end up with these two files:

    Hoist (command line version)
    Hoist.app (menu bar app)

The first binary is to be used directly from the command line and accepts parameters. The second binary, Hoist.app, includes
a menu bar status icon for runtime configuration:

  - **Left-click** the menu bar icon to toggle Hoist on/off.
  - **Right-click** the menu bar icon to open a context menu where you can adjust delay, warp, scale, and other settings.
  - Select **Preferences...** from the context menu to open a window with sliders and text fields for fine-tuning all parameters.

Changes made via the menu bar or preferences window are saved automatically to `~/.config/hoist/config.json`.

**Command line usage:**

    ./Hoist -pollMillis 50 -delay 1 -warpX 0.5 -warpY 0.1 -scale 2.5 -scaleDuration 600 -altTaskSwitcher false -requireMouseStop false -ignoreSpaceChanged false -ignoreApps "App1,App2" -ignoreTitles "^window$" -stayFocusedBundleIds "Id1,Id2" -disableKey control -mouseDelta 0.1

*Note*: focusDelay is only supported when compiled with the "EXPERIMENTAL_FOCUS_FIRST" flag.

  - pollMillis: How often to poll the mouse position and consider a raise/focus. Lower values increase responsiveness but also CPU load. Minimum = 20 and default = 50.

  - delay: Raise delay, specified in units of pollMillis. Disabled if 0. A delay > 1 requires the mouse to stop for a moment before raising.

  - focusDelay: Focus delay, specified in units of pollMillis. Disabled if 0. A delay > 1 requires the mouse to stop for a moment before focusing.

  - warpX: A Factor between 0 and 1. Makes the mouse jump horizontally to the activated window. By default disabled.

  - warpY: A Factor between 0 and 1. Makes the mouse jump vertically to the activated window. By default disabled.

  - scale: Enlarge the mouse for a short period of time after warping it. The default is 2.0. To disable set it to 1.0.

  - scaleDuration: How long (in milliseconds) the enlarged cursor is shown after warping. Minimum = 200 and default = 600.

  - altTaskSwitcher: Set to true if you use 3rd party tools to switch between applications (other than standard command-tab).

  - requireMouseStop: Require the mouse to stop moving before raise/focus. The default is true.

  - ignoreSpaceChanged: Do not immediately raise/focus after a space change. The default is false.

  - invertDisableKey: Makes the disable Hoist key behave in the opposite way. The default is false.

  - invertIgnoreApps: Turns the ignoreApps parameter into an includeApps parameter. The default is false.

  - ignoreApps: Comma separated list of apps for which you would like to disable focus/raise.

  - ignoreTitles: Comma separated list of window titles (a title can be an ICU regular expression) for which you would like to disable focus/raise.

  - stayFocusedBundleIds: Comma separated list of app bundle identifiers that shouldn't lose focus even when hovering the mouse over another window.

  - disableKey: Set to control, option or disabled. This will temporarily disable Hoist while holding the specified key. The default is control.

  - mouseDelta: Requires the mouse to move a certain distance. 0.0 = most sensitive whereas higher values decrease sensitivity.

  - verbose: Set to true to make Hoist show a log of events when started in a terminal.

Hoist can read these parameters from a configuration file at **~/.config/hoist/config.json**:

```json
{
    "pollMillis": 50,
    "delay": 1,
    "focusDelay": 0,
    "warpX": 0.5,
    "warpY": 0.1,
    "scale": 2.5,
    "scaleDuration": 600,
    "altTaskSwitcher": false,
    "requireMouseStop": true,
    "ignoreSpaceChanged": false,
    "invertDisableKey": false,
    "invertIgnoreApps": false,
    "ignoreApps": ["IntelliJ IDEA", "WebStorm"],
    "ignoreTitles": ["\\s\\| Microsoft Teams", "^window$"],
    "stayFocusedBundleIds": ["com.apple.SecurityAgent"],
    "disableKey": "control",
    "mouseDelta": 0.1
}
```

**Hoist.app usage:**

    a) optionally setup a configuration file, see above ^
    b) open /Applications/Hoist.app (allow Accessibility if asked for)
    c) left-click the menu bar icon to toggle on/off, right-click for settings
    d) or stop Hoist via "Activity Monitor" or read on:

To toggle Hoist on/off with a keyboard shortcut, paste the AppleScript below into an automator service workflow. Then
bind the created service to a keyboard shortcut via System Preferences|Keyboard|Shortcuts. This also works for Hoist.app
in which case "/Applications/Hoist" should be replaced with "/Applications/Hoist.app"

Applescript:

    on run {input, parameters}
        tell application "Finder"
            if exists of application process "Hoist" then
                quit application "/Applications/Hoist"
                display notification "Hoist Stopped"
            else
                launch application "/Applications/Hoist"
                display notification "Hoist Started"
            end if
        end tell
        return input
    end run

**Troubleshooting & Verbose logging**

If you experience any issues, it is suggested to first check these points:

- Are you using the latest version?
- Does it work with the command line version?
- Are you running other mouse tools that might intervene with Hoist?
- Are you running two Hoist instances at the same time? Use "Activity Monitor" to check this.
- Is Accessibility properly enabled? To be absolutely sure, remove any previous Hoist items
that may be present in the System Preferences|Security & Privacy|Privacy|Accessibility pane. Then
start Hoist and enable accessibility again. You can also reset Accessibility permissions from
the command line:

      tccutil reset Accessibility com.iamandrii.hoist

- After downloading or updating Hoist.app, macOS may flag it with a quarantine attribute that
prevents it from working properly. Remove it with:

      xattr -cr /Applications/Hoist.app

If after checking the above you still experience the problem, I encourage you to create an
[issue](https://github.com/aaabramov/Hoist/issues). It will be helpful to provide (a small part of) the verbose log, which can be enabled
like so:

    ./Hoist <parameters you would like to add> -verbose true

The output should look something like this:

    v5.6 by aaabramov(c) 2026, usage:
    
    Hoist
      -pollMillis <20, 30, 40, 50, ...>
      -delay <0=no-raise, 1=no-delay, 2=50ms, 3=100ms, ...>
      -focusDelay <0=no-focus, 1=no-delay, 2=50ms, 3=100ms, ...>
      -warpX <0.5> -warpY <0.5> -scale <2.0>
      -altTaskSwitcher <true|false>
      -requireMouseStop <true|false>
      -ignoreSpaceChanged <true|false>
      -invertDisableKey <true|false>
      -invertIgnoreApps <true|false>
      -ignoreApps "<App1,App2, ...>"
      -ignoreTitles "<Regex1, Regex2, ...>"
      -stayFocusedBundleIds "<Id1,Id2, ...>"
      -disableKey <control|option|disabled>
      -mouseDelta <0.1>
      -verbose <true|false>

    Started with:
      * pollMillis: 50ms
      * delay: 0ms
      * focusDelay: disabled
      * ignoreSpaceChanged: false
      * invertDisableKey: false
      * invertIgnoreApps: false
      * disableKey: control
      * verbose: true

    Compiled with:
      * OLD_ACTIVATION_METHOD
      * EXPERIMENTAL_FOCUS_FIRST

    2026-02-01 14:25:56.192 Hoist[44780:1615626] AXIsProcessTrusted: YES
    2026-02-01 14:25:56.216 Hoist[44780:1615626] System cursor scale: 1.000000
    2026-02-01 14:25:56.234 Hoist[44780:1615626] Got run loop source: YES
    2026-02-01 14:25:56.284 Hoist[44780:1615626] Mouse window: Hoist — Hoist -verbose 1
    2026-02-01 14:25:56.285 Hoist[44780:1615626] Focused window: Hoist — Hoist -verbose 1
    2026-02-01 14:25:56.287 Hoist[44780:1615626] Desktop origin (-1920.000000, -360.000000)
    ...
    ...

**Credits**

This is a fork of [sbmpost/AutoRaise](https://github.com/sbmpost/AutoRaise) — huge thanks to sbmpost for creating and maintaining the original project. The menu bar status icon, preferences window, runtime configuration features, and rename to Hoist were done in this fork.
