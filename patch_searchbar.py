import re

filepath = "/home/boing/Dotfiles/quickshell/windows/Launcher/SearchBar.qml"
with open(filepath, 'r') as f:
    content = f.read()

# Replace the onActiveFocusChanged block with a Timer
old_block = """            onActiveFocusChanged: {
                if (!activeFocus && root.expanded && !_deliberateFocusLoss) {
                    Qt.callLater(() => {
                        if (root.expanded && !searchInput.activeFocus) {
                            searchInput.forceActiveFocus();
                        }
                    });
                }
                if (activeFocus) _deliberateFocusLoss = false;
            }"""

new_block = """            onActiveFocusChanged: {
                if (activeFocus) _deliberateFocusLoss = false;
            }

            // QML layout animations can sometimes spuriously drop active focus.
            // This timer aggressively defends focus during such layout transitions.
            Timer {
                interval: 16
                running: root.expanded && !searchInput.activeFocus && !searchInput._deliberateFocusLoss
                repeat: true
                onTriggered: {
                    searchInput.forceActiveFocus();
                }
            }"""

if old_block in content:
    content = content.replace(old_block, new_block)
    with open(filepath, 'w') as f:
        f.write(content)
    print("Patched SearchBar.qml")
else:
    print("Could not find the block to replace")
