import os

filepath = "/home/boing/Dotfiles/quickshell/windows/Launcher/SearchBar.qml"
with open(filepath, 'r') as f:
    content = f.read()

old_block = """            onActiveFocusChanged: {
                if (activeFocus) _deliberateFocusLoss = false;
            }"""

new_block = """            onActiveFocusChanged: {
                if (!activeFocus && root.expanded && !_deliberateFocusLoss) {
                    // Safe fallback for QML layout focus drops. Only runs once per focus loss.
                    Qt.callLater(() => {
                        if (root.expanded && !searchInput.activeFocus) {
                            searchInput.forceActiveFocus();
                        }
                    });
                }
                if (activeFocus) _deliberateFocusLoss = false;
            }"""

if old_block in content:
    content = content.replace(old_block, new_block)
    with open(filepath, 'w') as f:
        f.write(content)
    print("CallLater restored")
else:
    print("Block not found")
