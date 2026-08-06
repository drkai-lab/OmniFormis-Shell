import re
import os

files_to_patch = {
    "/home/boing/Dotfiles/quickshell/windows/Launcher.qml": ("540", "490"),
    "/home/boing/Dotfiles/quickshell/panels/ControlCenter.qml": ("640", "640"),
    "/home/boing/Dotfiles/quickshell/windows/WallpaperSwitcher.qml": ("640", "590"),
    "/home/boing/Dotfiles/quickshell/windows/ColorSchemeSwitcher.qml": ("440", "360"),
    "/home/boing/Dotfiles/quickshell/windows/EmojiPicker.qml": ("440", "490"),
    "/home/boing/Dotfiles/quickshell/windows/PowerMenu.qml": ("640", "200"),
    "/home/boing/Dotfiles/quickshell/windows/SettingsApp.qml": ("740", "540"),
}

for filepath, (max_w, max_h) in files_to_patch.items():
    if not os.path.exists(filepath): continue
    with open(filepath, 'r') as f:
        content = f.read()

    # Find the panelMask Item
    # We want to replace its width and height properties.
    # The current properties might look like:
    # width: root.expanded ? 540 : panel.width + 40
    # height: root.expanded ? 490 : panel.height + 40
    # OR
    # width: panel.width + 40
    # height: panel.height + 40
    
    # We'll use regex to target exactly the width and height inside `id: panelMask`
    
    mask_block_pattern = r'(id: panelMask\s*.*?)(width:[^\n]+)\n(\s*height:[^\n]+)'
    
    def replacer(match):
        pre = match.group(1)
        # We replace the width and height with fixed bounds
        new_width = f"width: root.expanded ? {max_w} : 140"
        new_height = f"height: root.expanded ? {max_h} : 80"
        
        # Ensure we keep the exact same indentation for the height
        # Actually, let's just use string replacement carefully
        return f"{pre}{new_width}\n        {new_height}"

    new_content = re.sub(mask_block_pattern, replacer, content, flags=re.DOTALL)
    
    with open(filepath, 'w') as f:
        f.write(new_content)
    
print("Patched panelMasks")
