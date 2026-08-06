import os
import re

files_to_patch = [
    "/home/boing/Dotfiles/quickshell/panels/ControlCenter.qml",
    "/home/boing/Dotfiles/quickshell/windows/PowerMenu.qml",
    "/home/boing/Dotfiles/quickshell/windows/EmojiPicker.qml",
    "/home/boing/Dotfiles/quickshell/windows/ColorSchemeSwitcher.qml",
    "/home/boing/Dotfiles/quickshell/windows/WallpaperSwitcher.qml",
    "/home/boing/Dotfiles/quickshell/windows/SettingsApp.qml",
    "/home/boing/Dotfiles/quickshell/popups/NotificationPopup.qml",
    "/home/boing/Dotfiles/quickshell/popups/PolkitDialog.qml"
]

replacement = """        anchors.top: (!Vars.pillPosition || Vars.pillPosition === "Top") ? parent.top : undefined
        anchors.bottom: Vars.pillPosition === "Bottom" ? parent.bottom : undefined
        anchors.left: Vars.pillPosition === "Left" ? parent.left : undefined
        anchors.right: Vars.pillPosition === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? parent.verticalCenter : undefined
        
        anchors.topMargin: -20
        anchors.bottomMargin: -20
        anchors.leftMargin: -20
        anchors.rightMargin: -20"""

for filepath in files_to_patch:
    with open(filepath, 'r') as f:
        content = f.read()
    
    if "anchors.centerIn: panel" in content:
        content = content.replace("anchors.centerIn: panel", replacement)
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Patched {filepath}")
    else:
        print(f"Skipped {filepath}")

