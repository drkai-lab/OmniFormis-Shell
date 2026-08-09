#!/usr/bin/env bash

# Mass-replace inline translucent color patterns with centralized helpers
# Pattern 1: Simple tColor - (Vars._translucent && !Vars.gameMode) ? Qt.rgba(X.r, X.g, X.b, ALPHA) : X

cd /home/boing/Dotfiles/quickshell || exit 1

echo "=== BEFORE ==="
grep -r '(Vars._translucent && !Vars.gameMode)' --include="*.qml" | wc -l

# Replace the full pattern with Vars.tColor
find . -name "*.qml" -type f -exec perl -i -pe 's/\(Vars\._translucent && !Vars\.gameMode\) \? Qt\.rgba\(Theme\.(\w+)\.r, Theme\.\1\.g, Theme\.\1\.b, (.*?)\) : Theme\.\1/Vars.tColor(Theme.$1, $2)/g' {} +

# A secondary pattern might have extra parentheses around the Qt.rgba, though uncommon, let's catch standard ones
echo "=== AFTER ==="
grep -r '(Vars._translucent && !Vars.gameMode)' --include="*.qml" | wc -l

echo "Optimization mass-replace complete."
