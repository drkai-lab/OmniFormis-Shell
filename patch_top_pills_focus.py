import re

filepath = "/home/boing/Dotfiles/quickshell/panels/TopPills.qml"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Add property bool _forceDropGrab: false near the top (e.g. before HyprlandFocusGrab)
if "property bool _forceDropGrab" not in content:
    content = content.replace("    HyprlandFocusGrab {", "    property bool _forceDropGrab: false\n\n    HyprlandFocusGrab {")

# 2. Update active binding
old_active = "active: launcherItem.expanded || controlCenterItem.expanded || wallpaperSwitcherItem.expanded || colorSchemeSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded"
new_active = "active: !_forceDropGrab && (launcherItem.expanded || controlCenterItem.expanded || wallpaperSwitcherItem.expanded || colorSchemeSwitcherItem.expanded || powerMenuItem.expanded || polkitItem.expanded || emojiPickerItem.expanded || settingsAppItem.expanded)"
if old_active in content:
    content = content.replace(old_active, new_active)

# 3. Modify toggle functions
# Each toggle function has an `else { \n topWindow.popupOpened();` block.
# We will replace `topWindow.popupOpened();` with `topWindow.popupOpened();\n                _forceDropGrab = true;`
# And then we need to place `_forceDropGrab = false;` at the end of the block.
# This requires a bit of parsing.
# The structure is usually:
# } else {
#     topWindow.popupOpened();
#     closeAllExcept(...);
#     ...
# }

def replace_block(match):
    block = match.group(0)
    # Insert _forceDropGrab = true after popupOpened();
    block = block.replace("topWindow.popupOpened();", "topWindow.popupOpened();\n                _forceDropGrab = true;")
    
    # Insert _forceDropGrab = false; before the closing brace of the else block.
    # The regex captures the `} else { ... }` block where the last character is `}`.
    block = block[:-1] + "    _forceDropGrab = false;\n            }"
    return block

# Find all else blocks containing topWindow.popupOpened();
# The regex looks for `} else {\n                topWindow.popupOpened();\n ... \n            }`
pattern = re.compile(r'\} else \{\s*topWindow\.popupOpened\(\);.*?\}', re.DOTALL)
content = pattern.sub(replace_block, content)

with open(filepath, 'w') as f:
    f.write(content)

print("Patched TopPills.qml")
