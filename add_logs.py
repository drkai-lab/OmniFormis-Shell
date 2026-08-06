import os

def patch_file(filepath, replacements):
    if not os.path.exists(filepath): return
    with open(filepath, 'r') as f:
        content = f.read()
    
    for old, new in replacements:
        if old in content:
            content = content.replace(old, new)
        else:
            print(f"Warning: Could not find '{old}' in {filepath}")
            
    with open(filepath, 'w') as f:
        f.write(content)

# TopPills.qml
patch_file("/home/boing/Dotfiles/quickshell/panels/TopPills.qml", [
    (
"""        onCleared: {
            if (active) {""",
"""        onCleared: {
            console.log("[DEBUG] HyprlandFocusGrab onCleared fired! active:", active);
            if (active) {"""
    ),
    (
"""        active: launcherItem.expanded""",
"""        onActiveChanged: console.log("[DEBUG] HyprlandFocusGrab active changed to:", active)
        active: launcherItem.expanded"""
    )
])

# Launcher.qml
patch_file("/home/boing/Dotfiles/quickshell/windows/Launcher.qml", [
    (
"""        property real targetHeight:""",
"""        onHeightChanged: console.log("[DEBUG] Launcher panel.height:", height, "implicit:", mainLayout.implicitHeight)
        property real targetHeight:"""
    )
])

# SearchBar.qml
patch_file("/home/boing/Dotfiles/quickshell/windows/Launcher/SearchBar.qml", [
    (
"""            onActiveFocusChanged: {
                if (activeFocus) _deliberateFocusLoss = false;
            }""",
"""            onActiveFocusChanged: {
                console.log("[DEBUG] SearchBar TextInput activeFocus changed to:", activeFocus);
                if (activeFocus) _deliberateFocusLoss = false;
            }
            onTextChanged: {
                console.log("[DEBUG] SearchBar TextInput text changed:", text);
            }"""
    )
])

# AppList.qml
patch_file("/home/boing/Dotfiles/quickshell/windows/Launcher/AppList.qml", [
    (
"""    onModelChanged: {""",
"""    onActiveFocusChanged: console.log("[DEBUG] AppList activeFocus changed to:", activeFocus)
    onCurrentIndexChanged: console.log("[DEBUG] AppList currentIndex changed to:", currentIndex)
    onModelChanged: {
        console.log("[DEBUG] AppList onModelChanged. count:", count)"""
    )
])

print("Added debug logs")
