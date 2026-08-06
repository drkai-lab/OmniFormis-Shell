import re

files_and_patterns = [
    ("/home/boing/Dotfiles/quickshell/panels/ControlCenter.qml", r"Qt\.callLater\(\(\) => forceActiveFocus\(\)\);", "forceActiveFocus();"),
    ("/home/boing/Dotfiles/quickshell/windows/PowerMenu.qml", r"Qt\.callLater\(\(\) => root\.forceActiveFocus\(\)\);", "root.forceActiveFocus();"),
    ("/home/boing/Dotfiles/quickshell/windows/EmojiPicker.qml", r"Qt\.callLater\(\(\) => searchInput\.forceActiveFocus\(\)\);", "searchInput.forceActiveFocus();"),
    ("/home/boing/Dotfiles/quickshell/windows/ColorSchemeSwitcher.qml", r"Qt\.callLater\(\(\) => controlBar\.forceSearchFocus\(\)\);", "controlBar.forceSearchFocus();"),
    ("/home/boing/Dotfiles/quickshell/windows/WallpaperSwitcher.qml", r"Qt\.callLater\(\(\) => contentLoader\.item\.controls\.focusSearch\(\)\);", "contentLoader.item.controls.focusSearch();"),
    ("/home/boing/Dotfiles/quickshell/windows/SettingsApp.qml", r"Qt\.callLater\(\(\) => root\.forceActiveFocus\(\)\);", "root.forceActiveFocus();"),
    ("/home/boing/Dotfiles/quickshell/windows/Launcher.qml", r"Qt\.callLater\(\(\) => \{ searchBar\.forceActiveFocus\(\); \}\);", "searchBar.forceActiveFocus();")
]

for filepath, pattern, replacement in files_and_patterns:
    try:
        with open(filepath, 'r') as f:
            content = f.read()
            
        new_content = re.sub(pattern, replacement, content)
        
        if content != new_content:
            with open(filepath, 'w') as f:
                f.write(new_content)
            print(f"Patched {filepath}")
        else:
            print(f"No changes in {filepath}")
    except Exception as e:
        print(f"Error patching {filepath}: {e}")

