import re

with open('/home/boing/Dotfiles/quickshell/desktop/WallpaperOverlay.qml', 'r') as f:
    content = f.read()

# 1. Change Window color to transparent
content = re.sub(
    r'color: root\.currentMaskEnabled \? Theme\.background : "transparent"',
    r'color: "transparent"',
    content
)

# 2. Delete croppedWallpaper
content = re.sub(
    r'        // 3\. Cropped section.*?        }\n',
    r'',
    content,
    flags=re.DOTALL
)

# 3. Modify maskContainer
old_mask_container = r'''        // 4. The 1:1 FBO mask perfectly matching the mask bounds (Same as MediaPlayer!)
        Item {
            id: maskContainer
            anchors.fill: maskBounds
            layer.enabled: true
            layer.smooth: true
            visible: false

            Item {
                anchors.centerIn: parent'''
new_mask_container = r'''        // 4. The 1:1 FBO mask perfectly matching the mask bounds (Same as MediaPlayer!)
        Item {
            id: maskContainer
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true
            visible: false

            Item {
                x: maskBounds.x
                y: maskBounds.y
                width: maskBounds.width
                height: maskBounds.height

                Item {
                    anchors.centerIn: parent'''
content = content.replace(old_mask_container, new_mask_container)

# Add closing brace for the wrapper item in maskContainer
content = re.sub(
    r'                    }\n                }\n            }\n        }\n\n        Rectangle {',
    r'                    }\n                }\n            }\n        }\n    }\n\n        Rectangle {',
    content
)


# 4. Modify Rectangle to bgRect
old_rect = r'''        Rectangle {
            anchors.fill: parent
            antialiasing: true
            opacity: root.currentMaskEnabled ? 1.0 : 0.0
            visible: opacity > 0'''
new_rect = r'''        Rectangle {
            id: bgRect
            anchors.fill: parent
            layer.enabled: true
            visible: false
            antialiasing: true
            opacity: root.currentMaskEnabled ? 1.0 : 0.0'''
content = content.replace(old_rect, new_rect)


# 5. Modify maskedWallpaperEffect to holePunchedBackground
old_multieffect = r'''        // 5. Final MultiEffect mapping 1:1 on the exact bounds
        MultiEffect {
            id: maskedWallpaperEffect
            anchors.fill: maskBounds
            source: croppedWallpaper
            opacity: root.currentMaskEnabled ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
            maskEnabled: true
            maskSource: maskContainer
        }'''
new_multieffect = r'''        // 5. Final MultiEffect mapping 1:1 on the exact bounds
        MultiEffect {
            id: holePunchedBackground
            anchors.fill: parent
            source: bgRect
            maskEnabled: true
            maskInverted: true
            maskSource: maskContainer
            opacity: root.currentMaskEnabled ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }'''
content = content.replace(old_multieffect, new_multieffect)


# 6. Modify shadowStrokeContainer
old_shadow = r'''        // 6. Inner Shadow SVG
        Item {
            id: shadowStrokeContainer
            anchors.fill: maskBounds
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: Vars.blurAmount
                blur: 1.0
                autoPaddingEnabled: false
            }
            visible: false

            Item {
                anchors.centerIn: parent'''
new_shadow = r'''        // 6. Inner Shadow SVG
        Item {
            id: shadowStrokeContainer
            anchors.fill: parent
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: Vars.blurAmount
                blur: 1.0
                autoPaddingEnabled: false
            }
            visible: false

            Item {
                x: maskBounds.x
                y: maskBounds.y
                width: maskBounds.width
                height: maskBounds.height

                Item {
                    anchors.centerIn: parent'''
content = content.replace(old_shadow, new_shadow)

content = re.sub(
    r'                        SequentialAnimation \{\n                            id: shadowAnim\n                            NumberAnimation \{ target: shadowCanvas; property: "scale"; to: 0\.01; duration: 250; easing\.type: Easing\.InBack \}\n                            NumberAnimation \{ target: shadowCanvas; property: "scale"; to: 1\.0; duration: 550; easing\.type: Easing\.OutElastic \}\n                        \}\n                    \}\n                \}\n            \}\n        \}\n\n        // 4\.5 Clone mask',
    r'                        SequentialAnimation {\n                            id: shadowAnim\n                            NumberAnimation { target: shadowCanvas; property: "scale"; to: 0.01; duration: 250; easing.type: Easing.InBack }\n                            NumberAnimation { target: shadowCanvas; property: "scale"; to: 1.0; duration: 550; easing.type: Easing.OutElastic }\n                        }\n                    }\n                }\n            }\n        }\n\n        // 4.5 Clone mask',
    content
)


# 7. Modify maskContainer2
old_mask2 = r'''        // 4.5 Clone mask for shadow to prevent Qt shader sharing bugs
        Item {
            id: maskContainer2
            anchors.fill: maskBounds
            layer.enabled: true
            layer.smooth: true
            visible: false
            Item {
                anchors.centerIn: parent'''
new_mask2 = r'''        // 4.5 Clone mask for shadow to prevent Qt shader sharing bugs
        Item {
            id: maskContainer2
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true
            visible: false

            Item {
                x: maskBounds.x
                y: maskBounds.y
                width: maskBounds.width
                height: maskBounds.height

                Item {
                    anchors.centerIn: parent'''
content = content.replace(old_mask2, new_mask2)

content = re.sub(
    r'                        source: "data:image/svg\+xml;utf8,<svg xmlns=\'http://www\.w3\.org/2000/svg\' viewBox=\'0 0 100 100\'><path d=\'" \+ currentPath \+ "\' fill=\'white\'/></svg>"\n                    \}\n                \}\n            \}\n        \}\n\n        // 7\. Inner Shadow Blended',
    r'                        source: "data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 100 100\'><path d=\'" + currentPath + "\' fill=\'white\'/></svg>"\n                    }\n                }\n            }\n        }\n\n        // 7. Inner Shadow Blended',
    content
)


# 8. Modify Final MultiEffect
old_final = r'''        // 7. Inner Shadow Blended
        MultiEffect {
            anchors.fill: maskBounds'''
new_final = r'''        // 7. Inner Shadow Blended
        MultiEffect {
            anchors.fill: parent'''
content = content.replace(old_final, new_final)


with open('/home/boing/Dotfiles/quickshell/desktop/WallpaperOverlay.qml.new', 'w') as f:
    f.write(content)
