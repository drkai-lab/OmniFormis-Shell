import os
import re

files = [
    "windows/Overview.qml",
    "windows/Launcher.qml",
    "windows/SettingsApp.qml",
    "windows/WallpaperSwitcher.qml",
    "windows/ColorSchemeSwitcher.qml",
    "windows/EmojiPicker.qml",
    "windows/PowerMenu.qml",
    "popups/NotificationPopup.qml",
    "popups/PolkitDialog.qml",
    "panels/ControlCenter.qml"
]

base_dir = "/home/boing/Dotfiles/quickshell"

for fname in files:
    path = os.path.join(base_dir, fname)
    if not os.path.exists(path): continue
    
    with open(path, "r") as f:
        content = f.read()

    # Identify panel and innerUI
    panel_match = re.search(r'Rectangle \{\s*id:\s*(panel(?:Background)?)\s*', content)
    
    if not panel_match:
        print(f"Panel not found in {fname}")
        continue
        
    panel_id = panel_match.group(1)
    
    # We want to replace the `opacity:` logic on the panel.
    # Currently it looks like:
    # opacity: root.expanded || (MorphState.openCount === 0 && MorphState.activeItem === panel && panel.width > 105) ? 1.0 : 0.0
    # or overviewContainer.visibleState || ...
    
    # Let's find the inner UI block, which is usually `Item { ... opacity: ... }` inside the panel.
    # Or just `expandedUI`
    
    has_expandedUI = "id: expandedUI" in content
    if has_expandedUI:
        inner_id = "expandedUI"
    else:
        # In SettingsApp and Launcher, there's no `id:` for the inner UI wrapper.
        # Let's add `id: innerUI` to the item with `opacity: root.expanded ? 1.0 : 0.0`
        inner_match = re.search(r'(Item\s*\{[^}]*opacity:\s*(root\.expanded|overviewContainer\.visibleState)\s*\?\s*1\.0\s*:\s*0\.0)', content)
        if inner_match:
            print(f"{fname}: needs innerUI injection")
            # We'll do it manually.
        else:
            print(f"{fname}: innerUI not found easily")

