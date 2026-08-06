import re

file_path = "/home/boing/Dotfiles/quickshell/windows/Launcher.qml"
with open(file_path, "r") as f:
    content = f.read()

old_mask = """    Item {
        id: panelMask
        anchors.centerIn: panel
        width: root.expanded ? 540 : panel.width + 40
        height: root.expanded ? 490 : panel.height + 40
    }"""

new_mask = """    Item {
        id: panelMask
        anchors.top: (!Vars.pillPosition || Vars.pillPosition === "Top") ? parent.top : undefined
        anchors.bottom: Vars.pillPosition === "Bottom" ? parent.bottom : undefined
        anchors.left: Vars.pillPosition === "Left" ? parent.left : undefined
        anchors.right: Vars.pillPosition === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? parent.verticalCenter : undefined
        
        anchors.topMargin: -20
        anchors.bottomMargin: -20
        anchors.leftMargin: -20
        anchors.rightMargin: -20

        width: root.expanded ? 540 : panel.width + 40
        height: root.expanded ? 490 : panel.height + 40
    }"""

if old_mask in content:
    content = content.replace(old_mask, new_mask)
    with open(file_path, "w") as f:
        f.write(content)
    print("Mask updated successfully.")
else:
    print("Could not find the old mask block.")
