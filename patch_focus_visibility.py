import re
import os

files_to_patch = {
    "/home/boing/Dotfiles/quickshell/panels/ControlCenter.qml": ("expandedUI", "forceActiveFocus()"),
    "/home/boing/Dotfiles/quickshell/windows/PowerMenu.qml": ("innerUI", "root.forceActiveFocus()"),
    "/home/boing/Dotfiles/quickshell/windows/EmojiPicker.qml": ("expandedUI", "searchInput.forceActiveFocus()"),
    "/home/boing/Dotfiles/quickshell/windows/ColorSchemeSwitcher.qml": ("expandedUI", "controlBar.forceSearchFocus()"),
    "/home/boing/Dotfiles/quickshell/windows/WallpaperSwitcher.qml": ("contentLoader", "contentLoader.item.controls.focusSearch()"),
    "/home/boing/Dotfiles/quickshell/windows/SettingsApp.qml": ("expandedUI", "root.forceActiveFocus()")
}

for filepath, (ui_id, focus_cmd) in files_to_patch.items():
    if not os.path.exists(filepath): continue
    with open(filepath, 'r') as f:
        content = f.read()

    # Find the block inside `onExpandedChanged:` -> `if (expanded) { ... }` or `} else { ... }` where `focus_cmd` is called.
    # We want to replace `focus_cmd;` with:
    # ui_id.visible = true;
    # focus_cmd;
    # ui_id.visible = Qt.binding(() => root.expanded || ui_id.opacity > 0);
    
    # We must ensure we don't duplicate it.
    if f"{ui_id}.visible = true;" in content:
        print(f"Skipped {filepath} (already patched)")
        continue
        
    replacement = f"{ui_id}.visible = true;\n            {focus_cmd};\n            {ui_id}.visible = Qt.binding(() => root.expanded || {ui_id}.opacity > 0);"
    
    # Escape focus_cmd for regex
    pattern = re.escape(focus_cmd) + r";"
    
    new_content = re.sub(pattern, replacement, content)
    
    if content != new_content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Patched {filepath}")
    else:
        print(f"Failed to patch {filepath}")

