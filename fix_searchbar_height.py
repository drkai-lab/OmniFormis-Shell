import os

filepath = "/home/boing/Dotfiles/quickshell/windows/Launcher/SearchBar.qml"
with open(filepath, 'r') as f:
    content = f.read()

old_block = """    Layout.fillWidth: true
    Layout.preferredHeight: 48
    color:"""

new_block = """    Layout.fillWidth: true
    Layout.preferredHeight: 48
    Layout.minimumHeight: 48
    Layout.maximumHeight: 48
    color:"""

if old_block in content:
    content = content.replace(old_block, new_block)
    with open(filepath, 'w') as f:
        f.write(content)
    print("Fixed SearchBar height")
else:
    print("Block not found")
