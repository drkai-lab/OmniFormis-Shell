import os
import re

directories = [
    "/home/boing/Dotfiles/quickshell/panels",
    "/home/boing/Dotfiles/quickshell/windows",
    "/home/boing/Dotfiles/quickshell/desktop"
]

pattern = re.compile(r'(Qt\.rgba\([^,]+,\s*[^,]+,\s*[^,]+,\s*)(0\.\d+)(\))')

count = 0
for directory in directories:
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.qml'):
                path = os.path.join(root, file)
                with open(path, 'r') as f:
                    content = f.read()
                
                new_content = pattern.sub(r'\1(Vars.blurAmount / 100)\3', content)
                
                if new_content != content:
                    with open(path, 'w') as f:
                        f.write(new_content)
                    print(f"Updated {path}")
                    count += 1

print(f"Updated {count} files.")
