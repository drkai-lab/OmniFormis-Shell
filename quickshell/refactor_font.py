import os
import glob

def refactor():
    directory = "/home/boing/Dotfiles/quickshell"
    for filepath in glob.glob(directory + "/**/*.qml", recursive=True):
        if filepath.endswith("QsText.qml"):
            continue
        
        with open(filepath, "r") as f:
            content = f.read()
        
        new_content = content.replace("font.weight:", "setWeight:")
        
        if new_content != content:
            with open(filepath, "w") as f:
                f.write(new_content)
            print("Updated", filepath)

if __name__ == "__main__":
    refactor()
