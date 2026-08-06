import re

filepath = "/home/boing/Dotfiles/quickshell/panels/TopPills.qml"
with open(filepath, 'r') as f:
    content = f.read()

def replacer(match):
    item = match.group(1)
    
    # E.g.
    # controlCenterItem.expanded = !controlCenterItem.expanded;
    # if (controlCenterItem.expanded) {
    #     topWindow.popupOpened();
    #     closeAllExcept(controlCenterItem);
    # }
    
    # Becomes:
    # let wasExpanded = controlCenterItem.expanded;
    # if (wasExpanded) {
    #     controlCenterItem.expanded = false;
    # } else {
    #     topWindow.popupOpened();
    #     closeAllExcept(controlCenterItem);
    #     controlCenterItem.expanded = true;
    # }
    
    return f"""    let wasExpanded = {item}.expanded;
            if (wasExpanded) {{
                {item}.expanded = false;
            }} else {{
                topWindow.popupOpened();
                closeAllExcept({item});
                {item}.expanded = true;
            }}"""

# Replace simple toggles like controlCenterItem
content = re.sub(
    r'\s+([a-zA-Z]+Item)\.expanded = !\1\.expanded;\s+if \(\1\.expanded\) \{\s+topWindow\.popupOpened\(\);\s+closeAllExcept\(\1\);\s+\}',
    replacer,
    content
)

# Now fix the custom ones (Launcher, Emoji, Clipboard)
# Launcher:
launcher_old = """    function toggleLauncher() {
        if (!polkitItem.expanded) {
            if (launcherItem.expanded && !launcherItem.searchText.startsWith("/")) {
                launcherItem.expanded = false;
            } else {
                topWindow.popupOpened();
                launcherItem.expanded = true;
                launcherItem.searchText = "";
                closeAllExcept(launcherItem);
            }
        }
    }"""
launcher_new = """    function toggleLauncher() {
        if (!polkitItem.expanded) {
            if (launcherItem.expanded && !launcherItem.searchText.startsWith("/")) {
                launcherItem.expanded = false;
            } else {
                topWindow.popupOpened();
                closeAllExcept(launcherItem);
                launcherItem.expanded = true;
                launcherItem.searchText = "";
            }
        }
    }"""
content = content.replace(launcher_old, launcher_new)

# Emoji
emoji_old = """    function toggleEmojiPicker() {
        if (!polkitItem.expanded) {
            if (launcherItem.expanded && launcherItem.searchText === "/emoji ") {
                launcherItem.expanded = false;
            } else {
                topWindow.popupOpened();
                launcherItem.expanded = true;
                launcherItem.searchText = "/emoji ";
                closeAllExcept(launcherItem);
            }
        }
    }"""
emoji_new = """    function toggleEmojiPicker() {
        if (!polkitItem.expanded) {
            if (launcherItem.expanded && launcherItem.searchText === "/emoji ") {
                launcherItem.expanded = false;
            } else {
                topWindow.popupOpened();
                closeAllExcept(launcherItem);
                launcherItem.expanded = true;
                launcherItem.searchText = "/emoji ";
            }
        }
    }"""
content = content.replace(emoji_old, emoji_new)

# Clipboard
clipboard_old = """    function toggleClipboard() {
        if (!polkitItem.expanded) {
            if (launcherItem.expanded && launcherItem.searchText === "/clipboard ") {
                launcherItem.expanded = false;
            } else {
                topWindow.popupOpened();
                launcherItem.expanded = true;
                launcherItem.searchText = "/clipboard ";
                closeAllExcept(launcherItem);
            }
        }
    }"""
clipboard_new = """    function toggleClipboard() {
        if (!polkitItem.expanded) {
            if (launcherItem.expanded && launcherItem.searchText === "/clipboard ") {
                launcherItem.expanded = false;
            } else {
                topWindow.popupOpened();
                closeAllExcept(launcherItem);
                launcherItem.expanded = true;
                launcherItem.searchText = "/clipboard ";
            }
        }
    }"""
content = content.replace(clipboard_old, clipboard_new)

with open(filepath, 'w') as f:
    f.write(content)
    
print("Patched TopPills")
