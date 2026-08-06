import os

filepath = "/home/boing/Dotfiles/quickshell/panels/TopPills.qml"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Change to Exclusive
old_focus = "WlrLayershell.keyboardFocus: globalFocusGrab.active ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None"
new_focus = "WlrLayershell.keyboardFocus: globalFocusGrab.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None"
content = content.replace(old_focus, new_focus)

# 2. Add popupScrim
old_scrim_comment = """    // popupScrim removed — clicking outside a popup passes through to underlying windows
    // and HyprlandFocusGrab.onCleared handles closing the popup automatically"""

new_scrim = """    // Restored popupScrim because Hyprland drops OnDemand focus on every commit
    // if the pointer is over another window. Exclusive focus + Scrim is required for animations.
    MouseArea {
        id: popupScrim
        anchors.fill: parent
        enabled: globalFocusGrab.active
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: (wheel) => wheel.accepted = true
        onClicked: closeAll()
        z: -1
    }"""
content = content.replace(old_scrim_comment, new_scrim)

# 3. Add popupScrim to mask
old_mask = """    mask: Region {
        Region {
            item: clockHoverZone
        }"""
new_mask = """    mask: Region {
        Region {
            item: globalFocusGrab.active ? popupScrim : null
        }
        Region {
            item: clockHoverZone
        }"""
content = content.replace(old_mask, new_mask)

with open(filepath, 'w') as f:
    f.write(content)
print("Patched TopPills.qml")
