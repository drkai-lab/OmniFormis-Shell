import re
import os

files_to_patch = {
    "/home/boing/Dotfiles/quickshell/popups/NotificationPopup.qml": ("420", "440"),
    "/home/boing/Dotfiles/quickshell/popups/PolkitDialog.qml": ("460", "400"),
}

for filepath, (max_w, max_h) in files_to_patch.items():
    if not os.path.exists(filepath): continue
    with open(filepath, 'r') as f:
        content = f.read()

    mask_block_pattern = r'(id: panelMask\s*.*?)(width:[^\n]+)\n(\s*height:[^\n]+)'
    
    def replacer(match):
        pre = match.group(1)
        new_width = f"width: root.expanded ? {max_w} : 140"
        new_height = f"height: root.expanded ? {max_h} : 80"
        return f"{pre}{new_width}\n        {new_height}"

    new_content = re.sub(mask_block_pattern, replacer, content, flags=re.DOTALL)
    
    with open(filepath, 'w') as f:
        f.write(new_content)
    
print("Patched Notification and Polkit")
