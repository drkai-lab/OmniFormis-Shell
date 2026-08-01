import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import QtQuick.Effects
import ".."
import QtCore
import "Variables"
import "../theme/variables.js" as Vars

PanelWindow {
    id: root

    WlrLayershell.namespace: "quickshell"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    property string currentMaskShape: Vars.wallpaperMaskShape !== undefined ? Vars.wallpaperMaskShape : "Circle"
    property real currentMaskScale: Vars.wallpaperMaskScale !== undefined ? Vars.wallpaperMaskScale : 0.7
    property string currentMaskColor: Vars.wallpaperMaskColor !== undefined ? Vars.wallpaperMaskColor : "transparent"
    property bool currentMaskEnabled: Vars.wallpaperMaskEnabled !== undefined ? Vars.wallpaperMaskEnabled : true
    property real currentMaskOffsetX: Vars.wallpaperMaskOffsetX !== undefined ? Vars.wallpaperMaskOffsetX : 0
    property real currentMaskOffsetY: Vars.wallpaperMaskOffsetY !== undefined ? Vars.wallpaperMaskOffsetY : 0

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            var shape = Vars.wallpaperMaskShape !== undefined ? Vars.wallpaperMaskShape : "Circle";
            if (root.currentMaskShape !== shape)
                root.currentMaskShape = shape;

            var scale = Vars.wallpaperMaskScale !== undefined ? Vars.wallpaperMaskScale : 0.7;
            if (root.currentMaskScale !== scale)
                root.currentMaskScale = scale;

            var clr = Vars.wallpaperMaskColor !== undefined ? Vars.wallpaperMaskColor : "transparent";
            if (root.currentMaskColor !== clr)
                root.currentMaskColor = clr;

            var enabled = Vars.wallpaperMaskEnabled !== undefined ? Vars.wallpaperMaskEnabled : true;
            if (root.currentMaskEnabled !== enabled)
                root.currentMaskEnabled = enabled;

            var offsetX = Vars.wallpaperMaskOffsetX !== undefined ? Vars.wallpaperMaskOffsetX : 0;
            if (root.currentMaskOffsetX !== offsetX)
                root.currentMaskOffsetX = offsetX;

            var offsetY = Vars.wallpaperMaskOffsetY !== undefined ? Vars.wallpaperMaskOffsetY : 0;
            if (root.currentMaskOffsetY !== offsetY)
                root.currentMaskOffsetY = offsetY;
        }
    }

    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    Behavior on color { ColorAnimation { duration: 500; easing.type: Easing.InOutQuad } }

    Settings {
        id: wpSettings
        category: "WallpaperSwitcher"
        property string currentWallpaper: ""
    }

    // Automatically load the wallpaper path set by the user in the Settings App
    // Handle both raw paths and already-prefixed file:// URLs
    property string currentWallpaper: {
        var stored = wpSettings.currentWallpaper;
        if (!stored || stored === "") return "";
        if (stored.startsWith("file://")) return stored;
        return "file://" + stored;
    }

    Item {
        id: bgContainer
        anchors.fill: parent
        opacity: 0.0
        Component.onCompleted: layerEntranceAnim.start()
        NumberAnimation {
            id: layerEntranceAnim
            target: bgContainer
            property: "opacity"
            to: 1.0
            duration: 800
            easing.type: Easing.OutCubic
        }

        M3Shapes {
            id: m3
        }

        // 1. Original fullscreen wallpaper (hidden)
        Image {
            id: wallpaperImage
            anchors.fill: parent
            source: root.currentWallpaper
            fillMode: Image.PreserveAspectCrop
            smooth: true
            antialiasing: true
            mipmap: true
            visible: false
        }

        // 2. The exact bounds of the mask shape
        Item {
            id: maskBounds
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.currentMaskOffsetX
            anchors.verticalCenterOffset: root.currentMaskOffsetY

            Behavior on anchors.horizontalCenterOffset {
                NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard }
            }
            Behavior on anchors.verticalCenterOffset {
                NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard }
            }

            width: Math.min(root.width, root.height) * root.currentMaskScale
            height: width

            Behavior on width {
                NumberAnimation {
                    duration: Vars.animationDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Vars.customStandard
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: Vars.animationDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Vars.customStandard
                }
            }

            property string previousPathName: root.currentMaskShape
            property string currentPathName: root.currentMaskShape
            property real morphProgress: 1.0
            property real shapeRotation: 0

            ParallelAnimation {
                id: shapeTransitionAnim
                NumberAnimation {
                    id: rotationAnim
                    target: maskBounds
                    property: "shapeRotation"
                    duration: 600
                    easing.type: Easing.InOutCubic
                }
                NumberAnimation {
                    id: morphAnim
                    target: maskBounds
                    property: "morphProgress"
                    from: 0.0
                    to: 1.0
                    duration: 600
                    easing.type: Easing.InOutCubic
                }
            }
            
            Connections {
                target: root
                function onCurrentMaskShapeChanged() {
                    maskBounds.previousPathName = maskBounds.currentPathName
                    maskBounds.currentPathName = root.currentMaskShape
                    rotationAnim.from = 0
                    rotationAnim.to = 180
                    morphAnim.from = 0.0
                    morphAnim.to = 1.0
                    shapeTransitionAnim.restart()
                }
            }

            visible: false
        }

        // 4. The 1:1 FBO mask perfectly matching the mask bounds (Same as MediaPlayer!)
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
                    anchors.centerIn: parent
                    property real scaleFactor: Math.min(4, 4096 / Math.max(parent.width, parent.height, 1))
                    width: parent.width * scaleFactor
                    height: parent.height * scaleFactor
                    scale: 1.0 / scaleFactor

                    Image {
                        anchors.fill: parent
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        antialiasing: true
                        mipmap: true
                        asynchronous: true
                        property string path: m3.getPath(maskBounds.previousPathName)
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + path + "' fill='white'/></svg>"
                        opacity: 1.0 - maskBounds.morphProgress
                        rotation: maskBounds.shapeRotation
                    }
                    Image {
                        anchors.fill: parent
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        antialiasing: true
                        mipmap: true
                        asynchronous: true
                        property string path: m3.getPath(maskBounds.currentPathName)
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + path + "' fill='white'/></svg>"
                        opacity: maskBounds.morphProgress
                    }
                }
            }
        }

        Rectangle {
            id: bgRect
            anchors.fill: parent
            layer.enabled: true
            visible: false
            antialiasing: true
            opacity: root.currentMaskEnabled ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
            color: {
                var c = root.currentMaskColor;
                if (c === "transparent" || c === undefined)
                    return "transparent";
                if (c === "background")
                    return Theme.background;
                if (c === "primary")
                    return Theme.primary;
                if (c === "secondary")
                    return Theme.secondary;
                if (c === "tertiary")
                    return Theme.tertiary;
                if (c === "surface_variant")
                    return Theme.surface_variant;
                if (c === "error")
                    return Theme.error;
                return "transparent";
            }
            Behavior on color {
                ColorAnimation {
                    duration: 300
                }
            }
        }

        // Fallback wallpaper removed to allow awww to render underneath

        // 5. Final MultiEffect mapping 1:1 on the exact bounds
        MultiEffect {
            id: holePunchedBackground
            anchors.fill: parent
            source: bgRect
            maskEnabled: true
            maskInverted: true
            maskSource: maskContainer
        }

        // 6. Inner Shadow SVG
        Item {
            id: shadowStrokeContainer
            anchors.fill: parent
            layer.enabled: true
            visible: false

            Item {
                x: maskBounds.x
                y: maskBounds.y
                width: maskBounds.width
                height: maskBounds.height

                Item {
                    anchors.centerIn: parent
                    property real scaleFactor: Math.min(4, 4096 / Math.max(parent.width, parent.height, 1))
                    width: parent.width * scaleFactor
                    height: parent.height * scaleFactor
                    scale: 1.0 / scaleFactor

                    Image {
                        anchors.fill: parent
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        antialiasing: true
                        mipmap: true
                        asynchronous: true
                        property string path: m3.getPath(maskBounds.previousPathName)
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='M -50 -50 L 150 -50 L 150 150 L -50 150 Z " + path + "' fill='white' fill-rule='evenodd'/></svg>"
                        opacity: 1.0 - maskBounds.morphProgress
                        rotation: maskBounds.shapeRotation
                    }
                    Image {
                        anchors.fill: parent
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        antialiasing: true
                        mipmap: true
                        asynchronous: true
                        property string path: m3.getPath(maskBounds.currentPathName)
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='M -50 -50 L 150 -50 L 150 150 L -50 150 Z " + path + "' fill='white' fill-rule='evenodd'/></svg>"
                        opacity: maskBounds.morphProgress
                    }
                }
            }
        }

        // 4.5 Clone mask for shadow to prevent Qt shader sharing bugs
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
                    anchors.centerIn: parent
                    property real scaleFactor: Math.min(4, 4096 / Math.max(parent.width, parent.height, 1))
                    width: parent.width * scaleFactor
                    height: parent.height * scaleFactor
                    scale: 1.0 / scaleFactor

                    Image {
                        anchors.fill: parent
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        antialiasing: true
                        mipmap: true
                        asynchronous: true
                        property string path: m3.getPath(maskBounds.previousPathName)
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + path + "' fill='white'/></svg>"
                        opacity: 1.0
                        rotation: maskBounds.shapeRotation
                    }
                    Image {
                        anchors.fill: parent
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        antialiasing: true
                        mipmap: true
                        asynchronous: true
                        property string path: m3.getPath(maskBounds.currentPathName)
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + path + "' fill='white'/></svg>"
                        opacity: 1.0
                    }
                }
            }
        }

        // 7. Inner Shadow Blended
        MultiEffect {
            z: 100
            anchors.fill: parent
            source: shadowStrokeContainer
            blurEnabled: true
            blurMax: Vars.blurAmount
            blur: 1.0
            autoPaddingEnabled: false
            colorizationColor: bgRect.color
            colorization: 1.0
            maskEnabled: true
            maskSource: maskContainer2
            opacity: root.currentMaskEnabled ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // 8. Solid Border SVG
        Item {
            id: borderStrokeContainer
            anchors.fill: parent
            layer.enabled: true
            visible: false

            Item {
                x: maskBounds.x
                y: maskBounds.y
                width: maskBounds.width
                height: maskBounds.height

                Item {
                    anchors.centerIn: parent
                    property real scaleFactor: Math.min(4, 4096 / Math.max(parent.width, parent.height, 1))
                    width: parent.width * scaleFactor
                    height: parent.height * scaleFactor
                    scale: 1.0 / scaleFactor

                    Image {
                        anchors.fill: parent
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        antialiasing: true
                        mipmap: true
                        asynchronous: true
                        property string path: m3.getPath(maskBounds.previousPathName)
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + path + "' fill='none' stroke='white' stroke-width='2'/></svg>"
                        opacity: 1.0 - maskBounds.morphProgress
                        rotation: maskBounds.shapeRotation
                    }
                    Image {
                        anchors.fill: parent
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        antialiasing: true
                        mipmap: true
                        asynchronous: true
                        property string path: m3.getPath(maskBounds.currentPathName)
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + path + "' fill='none' stroke='white' stroke-width='2'/></svg>"
                        opacity: maskBounds.morphProgress
                    }
                }
            }
        }

        // 9. Solid Border Blended
        MultiEffect {
            z: 101
            anchors.fill: parent
            source: borderStrokeContainer
            colorizationColor: bgRect.color
            colorization: 1.0
            opacity: root.currentMaskEnabled ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
