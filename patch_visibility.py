import re

files_to_patch = [
    "/home/boing/Dotfiles/quickshell/panels/ControlCenter.qml",
    "/home/boing/Dotfiles/quickshell/windows/PowerMenu.qml",
    "/home/boing/Dotfiles/quickshell/windows/EmojiPicker.qml",
    "/home/boing/Dotfiles/quickshell/windows/ColorSchemeSwitcher.qml",
    "/home/boing/Dotfiles/quickshell/windows/WallpaperSwitcher.qml",
    "/home/boing/Dotfiles/quickshell/windows/SettingsApp.qml",
    "/home/boing/Dotfiles/quickshell/windows/Launcher.qml"
]

for filepath in files_to_patch:
    try:
        with open(filepath, 'r') as f:
            content = f.read()
            
        # Only replace `visible: opacity > 0` if it's inside `expandedUI` or similar.
        # Actually, let's just replace `visible: opacity > 0` with `visible: root.expanded || opacity > 0` globally, 
        # except for the one on `SettingsApp.qml` root or `WallpaperSwitcher.qml` root.
        
        # In SettingsApp.qml root:
        # opacity: forceHidePill ? 0.0 : 1.0
        # visible: opacity > 0
        # This shouldn't be `root.expanded || opacity > 0` because it controls window visibility!
        
        # Let's target exactly `id: expandedUI` or `id: contentLoader` wrappers.
        # It's safer to use sed or targeted replace.
        pass
    except Exception as e:
        print(f"Error reading {filepath}: {e}")

