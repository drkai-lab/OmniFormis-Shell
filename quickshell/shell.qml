//@ pragma UseQApplication
import QtQuick
import "."
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    id: root

    property bool appInitialized: false

    Component.onCompleted: {
        Qt.application.name = "quickshell";
        Qt.application.organization = "boing";
        Qt.application.domain = "boing.quickshell";
        appInitialized = true;
    }

    property string globalOsIconPath: ""
    property var _forceInitLockScreen: LockScreen

    Process {
        id: osCheckProcess
        command: ["sh", "-c", "cat /etc/os-release | grep '^ID='"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text.trim();
                if (text.includes("nixos")) {
                    root.globalOsIconPath = "file:///home/boing/Dotfiles/quickshell/theme/assets/nixos-logo.png";
                } else if (text.includes("arch")) {
                    root.globalOsIconPath = "file:///home/boing/Dotfiles/quickshell/theme/assets/arch-logo.png";
                }
            }
        }
    }

    property bool launcherVisible: false
    property bool screenshotVisible: false
    property bool powerMenuVisible: false
    property bool overviewVisible: false
    property bool lensVisible: false

    function callOnAllPills(methodName) {
        for (let i = 0; i < topPillsInstantiator.count; i++) {
            let obj = topPillsInstantiator.objectAt(i);
            if (obj && typeof obj[methodName] === "function") {
                obj[methodName]();
            }
        }
    }

    onOverviewVisibleChanged: {
        if (overviewVisible) {
            callOnAllPills("closeAll");
            screenshotVisible = false;
        }
    }

    onScreenshotVisibleChanged: {
        if (screenshotVisible) {
            callOnAllPills("closeAll");
            overviewVisible = false;
            lensVisible = false;
        }
    }

    onLensVisibleChanged: {
        if (lensVisible) {
            callOnAllPills("closeAll");
            overviewVisible = false;
            screenshotVisible = false;
        }
    }

    // Global shortcuts route to TopPills
    GlobalShortcut {
        name: "launcher"
        description: "Toggle Launcher"
        onPressed: callOnAllPills("toggleLauncher")
    }

    GlobalShortcut {
        name: "control_center"
        description: "Toggle Control Center"
        onPressed: callOnAllPills("toggleControlCenter")
    }

    GlobalShortcut {
        name: "screenshot"
        description: "Toggle Screenshot"
        onPressed: root.screenshotVisible = !root.screenshotVisible
    }

    GlobalShortcut {
        name: "lens"
        description: "Circle to Search"
        onPressed: root.lensVisible = !root.lensVisible
    }

    GlobalShortcut {
        name: "power_menu"
        description: "Toggle Power Menu"
        onPressed: callOnAllPills("togglePowerMenu")
    }

    GlobalShortcut {
        name: "wallpaper"
        description: "Toggle Wallpaper Switcher"
        onPressed: callOnAllPills("toggleWallpaper")
    }

    GlobalShortcut {
        name: "color_scheme"
        description: "Toggle Color Scheme Switcher"
        onPressed: callOnAllPills("toggleColorScheme")
    }

    GlobalShortcut {
        name: "overview"
        description: "Toggle Overview"
        onPressed: root.overviewVisible = !root.overviewVisible
    }

    GlobalShortcut {
        name: "emoji_picker"
        description: "Toggle Emoji Picker"
        onPressed: callOnAllPills("toggleEmojiPicker")
    }

    GlobalShortcut {
        name: "clipboard"
        description: "Toggle Clipboard"
        onPressed: callOnAllPills("toggleClipboard")
    }

    Variants {
        model: root.appInitialized ? Quickshell.screens : []
        delegate: Component {
            ScreenShot {
                required property var modelData
                screen: modelData
                visibleState: root.screenshotVisible || root.lensVisible
                isLensMode: root.lensVisible

                onScreenshotClosed: {
                    root.screenshotVisible = false;
                    root.lensVisible = false;
                }
            }
        }
    }

    Variants {
        model: root.appInitialized ? Quickshell.screens : []
        delegate: Component {
            ScreenFrame {
                required property var modelData
                screen: modelData
            }
        }
    }

    Variants {
        model: root.appInitialized ? Quickshell.screens : []
        delegate: Component {
            WallpaperOverlay {
                required property var modelData
                screen: modelData
            }
        }
    }

    Variants {
        model: root.appInitialized ? Quickshell.screens : []
        delegate: Component {
            DesktopClock {
                required property var modelData
                screen: modelData
            }
        }
    }

    Variants {
        model: root.appInitialized ? Quickshell.screens : []
        delegate: Component {
            DesktopCalender {
                required property var modelData
                screen: modelData
            }
        }
    }

    Variants {
        model: root.appInitialized ? Quickshell.screens : []
        delegate: Component {
            DesktopMediaPlayer {
                required property var modelData
                screen: modelData
            }
        }
    }

    // Launcher is now inside TopPills.qml
    NotificationDaemon {
        id: notifDaemon
    }

    Instantiator {
        id: topPillsInstantiator
        model: root.appInitialized ? Quickshell.screens : []
        delegate: TopPills {
            required property var modelData
            screen: modelData
            onToggleFloatingSettings: if (floatingSettingsLoader.item) floatingSettingsLoader.item.toggle()
            onPopupOpened: {
                root.overviewVisible = false;
                root.screenshotVisible = false;
                root.lensVisible = false;
            }
            onOpenOverviewRequested: {
                root.overviewVisible = true;
            }
        }
    }

    Loader {
        id: floatingSettingsLoader
        active: root.appInitialized
        sourceComponent: Component {
            SettingsWindow {
                onRequestWidgetToggle: callOnAllPills("toggleSettings")
            }
        }
    }

    Overview {
        visibleState: root.overviewVisible
        onCloseRequested: {
            root.overviewVisible = false;
        }
    }
}
