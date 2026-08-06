import re
import os

files_to_patch = [
    "/home/boing/Dotfiles/quickshell/panels/ControlCenter.qml",
    "/home/boing/Dotfiles/quickshell/windows/PowerMenu.qml",
    "/home/boing/Dotfiles/quickshell/windows/EmojiPicker.qml",
    "/home/boing/Dotfiles/quickshell/windows/ColorSchemeSwitcher.qml",
    "/home/boing/Dotfiles/quickshell/windows/WallpaperSwitcher.qml",
    "/home/boing/Dotfiles/quickshell/windows/SettingsApp.qml",
    "/home/boing/Dotfiles/quickshell/popups/PolkitDialog.qml"
]

# We want to replace `visible: opacity > 0` with `visible: root.expanded || opacity > 0` 
# specifically where it immediately follows `opacity: root.expanded ? 1.0 : 0.0` or similar expanded UI fading logic.

for filepath in files_to_patch:
    if not os.path.exists(filepath): continue
    with open(filepath, 'r') as f:
        content = f.read()

    # The common pattern is:
    # opacity: root.expanded ? 1.0 : 0.0
    # visible: opacity > 0
    
    # We will replace all occurrences of `visible: opacity > 0` 
    # EXCEPT for those directly under `opacity: forceHidePill ? 0.0 : 1.0` or `opacity: root.currentSubMenu` etc.
    # Wait, actually `root.expanded || opacity > 0` is safe for any wrapper that is only supposed to be visible when root is expanded!
    
    # Let's just do a manual replace of `visible: opacity > 0` for the specific `expandedUI` or `contentLoader` block
    
    # In ControlCenter, expandedUI has it.
    content = re.sub(r'(id: expandedUI.*?opacity: root\.expanded \? 1\.0 : 0\.0\s*)visible: opacity > 0', r'\1visible: root.expanded || opacity > 0', content, flags=re.DOTALL)
    
    # In PowerMenu, it's innerUI
    content = re.sub(r'(id: innerUI.*?opacity: root\.expanded \? 1\.0 : 0\.0\s*)visible: opacity > 0', r'\1visible: root.expanded || opacity > 0', content, flags=re.DOTALL)
    
    # In EmojiPicker, it's expandedUI
    content = re.sub(r'(id: expandedUI.*?opacity: root\.expanded \? 1\.0 : 0\.0\s*)visible: opacity > 0', r'\1visible: root.expanded || opacity > 0', content, flags=re.DOTALL)
    
    # In ColorSchemeSwitcher, it's expandedUI
    content = re.sub(r'(id: expandedUI.*?opacity: root\.expanded \? 1\.0 : 0\.0\s*)visible: opacity > 0', r'\1visible: root.expanded || opacity > 0', content, flags=re.DOTALL)
    
    # In WallpaperSwitcher, it's contentLoader
    content = re.sub(r'(id: contentLoader.*?opacity: root\.expanded \? 1\.0 : 0\.0\s*)visible: opacity > 0', r'\1visible: root.expanded || opacity > 0', content, flags=re.DOTALL)
    
    # In SettingsApp, it's expandedUI
    content = re.sub(r'(id: expandedUI.*?opacity: root\.expanded \? 1\.0 : 0\.0\s*)visible: opacity > 0', r'\1visible: root.expanded || opacity > 0', content, flags=re.DOTALL)

    with open(filepath, 'w') as f:
        f.write(content)
        
print("Patched visibility")
