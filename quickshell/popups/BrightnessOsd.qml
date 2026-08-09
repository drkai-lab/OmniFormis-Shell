import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import ".."
import QtQuick.Layouts
import Quickshell
import "../theme/variables.js" as Vars
import "../core/primitives" as Primitives
Item {
    id: mainContainer

    property bool isVertical: Vars.pillPosition === "Left" || Vars.pillPosition === "Right"
    width: osdBackground.width
    height: osdBackground.height

    property int trackHeight: 38
    property int gap: 4
    property int handleWidth: 4

    property bool isVisible: false
    property bool preventShow: false
    property bool gameMode: Vars.gameMode !== undefined ? Vars.gameMode : false
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            if (Vars.gameMode !== undefined && parent.gameMode !== Vars.gameMode) {
                parent.gameMode = Vars.gameMode;
            }
        }
    }
    property alias panel: osdBackground
    property alias panelMask: panelMask
    
    Item {
        id: panelMask
        anchors.centerIn: osdBackground
        width: osdBackground.width + 40
        height: osdBackground.height + 40
    }
    
    property real smoothBrightness: Vars.currentBrightness !== undefined ? Vars.currentBrightness : 1.0

    onPreventShowChanged: {
        if (preventShow) {
            isVisible = false;
            hideTimer.stop();
        }
    }

    property string brightnessIcon: {
        let b = Vars.currentBrightness !== undefined ? Vars.currentBrightness : 1.0;
        if (b <= 0.0) return "brightness_1";
        if (b <= 0.16) return "brightness_2";
        if (b <= 0.33) return "brightness_3";
        if (b <= 0.50) return "brightness_4";
        if (b <= 0.66) return "brightness_5";
        if (b <= 0.83) return "brightness_6";
        return "brightness_7";
    }

    Behavior on smoothBrightness {
        enabled: !mainContainer.gameMode
        NumberAnimation {
            duration: Vars.animationDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Vars.customStandard
        }
    }

    property real actualBrightness: Vars.currentBrightness !== undefined ? Vars.currentBrightness : 1.0

    onActualBrightnessChanged: triggerShow()

    function triggerShow() {
        if (!preventShow) {
            mainContainer.isVisible = true;
            if (!hoverArea.containsMouse && !bg.pressed) {
                hideTimer.restart();
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: {
            if (!hoverArea.containsMouse && !bg.pressed) {
                mainContainer.isVisible = false;
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onContainsMouseChanged: {
            if (containsMouse && isVisible) {
                hideTimer.stop();
            } else if (!containsMouse && isVisible && !bg.pressed) {
                hideTimer.restart();
            }
        }

        onWheel: wheel => {
            let delta = wheel.angleDelta.y > 0 ? 0.02 : -0.02;
            let newVol = Math.max(0.0, Math.min(1.0, (Vars.currentBrightness !== undefined ? Vars.currentBrightness : 1.0) + delta));
            Vars.currentBrightness = newVol;
        }
    }

    Primitives.SquircleMask {
        id: osdBackground
        anchors.centerIn: parent
        width: mainContainer.isVertical ? 80 : (mainContainer.isVisible ? 352 : 132)
        height: mainContainer.isVertical ? (mainContainer.isVisible ? 352 : 132) : 80
        property real targetRad: 20
        topLeftRadius: Vars.getTopLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        topRightRadius: Vars.getTopRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomLeftRadius: Vars.getBottomLeftRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        bottomRightRadius: Vars.getBottomRightRadius(Vars.panelStyle, Vars.pillPosition, false, targetRad)
        color: Theme.surface
        
        layer.enabled: false

        opacity: mainContainer.isVisible ? ((Vars._translucent && !Vars.gameMode) ? Vars.panelOpacity : 1.0) : 0.0
        visible: opacity > 0

        Behavior on width {
            enabled: !mainContainer.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }
        Behavior on height {
            enabled: !mainContainer.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }
        Behavior on opacity {
            enabled: !mainContainer.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customStandard
            }
        }
    }

    Slider {
        id: bg
        anchors.centerIn: parent

        orientation: mainContainer.isVertical ? Qt.Vertical : Qt.Horizontal
        width: mainContainer.isVertical ? 44 : (mainContainer.isVisible ? 320 : 100)
        height: mainContainer.isVertical ? (mainContainer.isVisible ? 320 : 100) : 44
        padding: 0

        opacity: mainContainer.isVisible ? 1.0 : 0.0
        visible: opacity > 0

        Behavior on width {
            enabled: !mainContainer.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }
        Behavior on height {
            enabled: !mainContainer.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }
        Behavior on opacity {
            enabled: !mainContainer.gameMode
            NumberAnimation {
                duration: Vars.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customStandard
            }
        }

        value: mainContainer.actualBrightness
        onMoved: {
            Vars.currentBrightness = value;
        }

        background: Item {
            x: bg.leftPadding
            y: bg.topPadding
            width: bg.availableWidth
            height: bg.availableHeight

            // HORIZONTAL TRACKS
            Item {
                anchors.centerIn: parent
                width: parent.width
                height: mainContainer.trackHeight
                visible: !mainContainer.isVertical

                property real leftRadiusLarge: 6
                property real leftRadiusSmall: 2
                property real handlePos: bg.visualPosition * (width - mainContainer.handleWidth)

                QsText {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: mainContainer.brightnessIcon
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 20
                    color: Theme.on_surface_variant
                    opacity: 0.8
                }

                Rectangle {
                    id: osdLeftTrack
                    x: 0
                    y: 0
                    width: Math.max(0, parent.handlePos - mainContainer.gap)
                    height: parent.height
                    color: Theme.primary
                    clip: true

                    topLeftRadius: Math.min(parent.leftRadiusLarge, width / 2)
                    bottomLeftRadius: Math.min(parent.leftRadiusLarge, width / 2)
                    topRightRadius: Math.min(parent.leftRadiusSmall, width / 2)
                    bottomRightRadius: Math.min(parent.leftRadiusSmall, width / 2)

                    QsText {
                        x: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: mainContainer.brightnessIcon
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 20
                        color: Theme.on_primary
                    }
                }

                Rectangle {
                    id: osdRightTrack
                    x: parent.handlePos + mainContainer.handleWidth + mainContainer.gap
                    y: 0
                    width: Math.max(0, parent.width - x)
                    height: parent.height
                    color: Vars.tColor(Theme.surface_variant, Vars.componentOpacity)

                    topLeftRadius: Math.min(parent.leftRadiusSmall, width / 2)
                    bottomLeftRadius: Math.min(parent.leftRadiusSmall, width / 2)
                    topRightRadius: Math.min(parent.leftRadiusLarge, width / 2)
                    bottomRightRadius: Math.min(parent.leftRadiusLarge, width / 2)
                }
            }

            // VERTICAL TRACKS
            Item {
                anchors.centerIn: parent
                width: mainContainer.trackHeight
                height: parent.height
                visible: mainContainer.isVertical

                property real leftRadiusLarge: 6
                property real leftRadiusSmall: 2
                property real handlePos: bg.visualPosition * (height - mainContainer.handleWidth)

                QsText {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: mainContainer.brightnessIcon
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 20
                    color: Theme.on_surface_variant
                    opacity: 0.8
                }

                Rectangle {
                    id: osdTopTrack
                    x: 0
                    y: 0
                    width: parent.width
                    height: Math.max(0, parent.handlePos - mainContainer.gap)
                    color: Vars.tColor(Theme.surface_variant, Vars.componentOpacity)

                    topLeftRadius: Math.min(parent.leftRadiusLarge, height / 2)
                    topRightRadius: Math.min(parent.leftRadiusLarge, height / 2)
                    bottomLeftRadius: Math.min(parent.leftRadiusSmall, height / 2)
                    bottomRightRadius: Math.min(parent.leftRadiusSmall, height / 2)
                }

                Rectangle {
                    id: osdBottomTrack
                    x: 0
                    y: parent.handlePos + mainContainer.handleWidth + mainContainer.gap
                    width: parent.width
                    height: Math.max(0, parent.height - y)
                    color: Theme.primary
                    clip: true

                    topLeftRadius: Math.min(parent.leftRadiusSmall, height / 2)
                    topRightRadius: Math.min(parent.leftRadiusSmall, height / 2)
                    bottomLeftRadius: Math.min(parent.leftRadiusLarge, height / 2)
                    bottomRightRadius: Math.min(parent.leftRadiusLarge, height / 2)

                    QsText {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: mainContainer.brightnessIcon
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 20
                        color: Theme.on_primary
                    }
                }
            }
        }

        handle: Rectangle {
            x: bg.leftPadding + (mainContainer.isVertical ? (bg.availableWidth - width) / 2 : bg.visualPosition * (bg.availableWidth - width))
            y: bg.topPadding + (mainContainer.isVertical ? bg.visualPosition * (bg.availableHeight - height) : (bg.availableHeight - height) / 2)

            width: mainContainer.isVertical ? (mainContainer.trackHeight + 8) : mainContainer.handleWidth
            height: mainContainer.isVertical ? mainContainer.handleWidth : (mainContainer.trackHeight + 8)
            radius: Math.min(width, height) / 2
            color: Theme.primary
        }
    }
}
