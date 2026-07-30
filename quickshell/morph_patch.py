import os
import re

files = [
    "windows/Launcher.qml",
    "windows/SettingsApp.qml",
    "windows/WallpaperSwitcher.qml",
    "windows/ColorSchemeSwitcher.qml",
    "windows/EmojiPicker.qml",
    "windows/PowerMenu.qml",
    "popups/NotificationPopup.qml",
    "popups/NotificationPill.qml",
    "popups/PolkitDialog.qml"
]

base_dir = "/home/boing/Dotfiles/quickshell"

for fname in files:
    path = os.path.join(base_dir, fname)
    if not os.path.exists(path): continue
    
    with open(path, "r") as f:
        content = f.read()
    
    # 1. Update onExpandedChanged
    if "onExpandedChanged: {" in content:
        # Check if already has MorphState
        if "MorphState" not in content:
            # We need to find the targetWidth and targetHeight of the panel
            # Most files have: width: root.expanded ? <W> : 100
            w_match = re.search(r'width: root\.expanded \? ([^:]+) : 100', content)
            h_match = re.search(r'height: root\.expanded \? ([^:]+) : 40', content)
            
            if w_match and h_match:
                tw = w_match.group(1).strip()
                th = h_match.group(1).strip()
                
                # Insert MorphState.notifyOpened / notifyClosed
                content = re.sub(
                    r'(onExpandedChanged: \{\s*)(if \(expanded\) \{\s*)',
                    f'\\1\\2MorphState.notifyOpened({tw}, {th});\n            ',
                    content
                )
                
                content = re.sub(
                    r'(} else \{\s*)',
                    f'\\1MorphState.notifyClosed();\n            ',
                    content
                )
                
                # 2. Update width and height
                content = re.sub(
                    r'width: root\.expanded \? ([^:]+) : 100',
                    r'width: root.expanded ? \1 : (MorphState.anyExpanded ? MorphState.targetWidth : 100)',
                    content
                )
                
                content = re.sub(
                    r'height: root\.expanded \? ([^:]+) : 40',
                    r'height: root.expanded ? \1 : (MorphState.anyExpanded ? MorphState.targetHeight : 40)',
                    content
                )
                
                with open(path, "w") as f:
                    f.write(content)
                print(f"Updated {fname}")
            else:
                print(f"Could not find dimensions in {fname}")
