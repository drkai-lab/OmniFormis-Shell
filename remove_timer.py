import os

filepath = "/home/boing/Dotfiles/quickshell/windows/Launcher/SearchBar.qml"
with open(filepath, 'r') as f:
    content = f.read()

timer_block = """            // QML layout animations can sometimes spuriously drop active focus.
            // This timer aggressively defends focus during such layout transitions.
            Timer {
                interval: 16
                running: root.expanded && !searchInput.activeFocus && !searchInput._deliberateFocusLoss
                repeat: true
                onTriggered: {
                    searchInput.forceActiveFocus();
                }
            }"""

if timer_block in content:
    content = content.replace(timer_block, "")
    with open(filepath, 'w') as f:
        f.write(content)
    print("Timer removed")
else:
    print("Timer not found")
