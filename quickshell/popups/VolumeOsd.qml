import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import ".."
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../theme/variables.js" as Vars

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
    
    property real smoothVolume: Pipewire.defaultAudioSink?.audio?.volume ?? 0

    onPreventShowChanged: {
        if (preventShow) {
            isVisible = false;
            hideTimer.stop();
        }
    }

    property string volumeIcon: {
        let isMuted = Pipewire.defaultAudioSink?.audio?.muted ?? false;
        let vol = Pipewire.defaultAudioSink?.audio?.volume ?? 0;

        if (isMuted || vol <= 0.0)
            return "\uE04F";
        if (vol < 0.5)
            return "\uE04D";
        return "\uE050";
    }

    Behavior on smoothVolume {
        enabled: !mainContainer.gameMode
        NumberAnimation {
            duration: Vars.animationDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Vars.customStandard
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property real actualVolume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
    property bool actualMuted: Pipewire.defaultAudioSink?.audio?.muted ?? false

    onActualVolumeChanged: triggerShow()
    onActualMutedChanged: triggerShow()

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
            if (Pipewire.defaultAudioSink?.audio) {
                let delta = wheel.angleDelta.y > 0 ? 0.02 : -0.02;
                let newVol = Math.max(0.0, Math.min(1.0, Pipewire.defaultAudioSink.audio.volume + delta));
                Pipewire.defaultAudioSink.audio.volume = newVol;
            }
        }
    }

    Rectangle {
        id: osdBackground
        anchors.centerIn: parent
        width: mainContainer.isVertical ? 80 : (mainContainer.isVisible ? 352 : 132)
        height: mainContainer.isVertical ? (mainContainer.isVisible ? 352 : 132) : 80
        property real targetRad: 20
        topLeftRadius: Vars.getTopLeftRadius(Vars.panelStyle, Vars.pillPosition, mainContainer.gameMode, targetRad)
        topRightRadius: Vars.getTopRightRadius(Vars.panelStyle, Vars.pillPosition, mainContainer.gameMode, targetRad)
        bottomLeftRadius: Vars.getBottomLeftRadius(Vars.panelStyle, Vars.pillPosition, mainContainer.gameMode, targetRad)
        bottomRightRadius: Vars.getBottomRightRadius(Vars.panelStyle, Vars.pillPosition, mainContainer.gameMode, targetRad)
        color: Theme.surface
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 1.0
            shadowColor: Qt.rgba(0, 0, 0, 0.25)
            shadowVerticalOffset: 4
            shadowHorizontalOffset: 0
        }

        opacity: mainContainer.isVisible ? (Vars.translucent ? 0.85 : 1.0) : 0.0
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

        value: mainContainer.actualVolume
        onMoved: {
            if (Pipewire.defaultAudioSink?.audio) {
                Pipewire.defaultAudioSink.audio.volume = value;
            }
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

                Rectangle {
                    id: osdLeftTrack
                    x: 0
                    y: 0
                    width: Math.max(0, parent.handlePos - mainContainer.gap)
                    height: parent.height
                    color: Theme.primary

                    topLeftRadius: Math.min(parent.leftRadiusLarge, width / 2)
                    bottomLeftRadius: Math.min(parent.leftRadiusLarge, width / 2)
                    topRightRadius: Math.min(parent.leftRadiusSmall, width / 2)
                    bottomRightRadius: Math.min(parent.leftRadiusSmall, width / 2)
                }

                Rectangle {
                    id: osdRightTrack
                    x: parent.handlePos + mainContainer.handleWidth + mainContainer.gap
                    y: 0
                    width: Math.max(0, parent.width - x)
                    height: parent.height
                    color: Vars.translucent ? Qt.rgba(Theme.surface_variant.r, Theme.surface_variant.g, Theme.surface_variant.b, 0.4) : Theme.surface_variant

                    topLeftRadius: Math.min(parent.leftRadiusSmall, width / 2)
                    bottomLeftRadius: Math.min(parent.leftRadiusSmall, width / 2)
                    topRightRadius: Math.min(parent.leftRadiusLarge, width / 2)
                    bottomRightRadius: Math.min(parent.leftRadiusLarge, width / 2)

                    Text {
                        x: parent.width - parent.parent.leftRadiusLarge - width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        text: mainContainer.volumeIcon
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 20
                        color: Theme.on_surface_variant
                        opacity: osdRightTrack.width > parent.parent.leftRadiusLarge * 2.5 ? 0.6 : 0.0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Vars.animationDuration
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Vars.customStandard
                            }
                        }
                    }
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

                Rectangle {
                    id: osdTopTrack
                    x: 0
                    y: 0
                    width: parent.width
                    height: Math.max(0, parent.handlePos - mainContainer.gap)
                    color: Vars.translucent ? Qt.rgba(Theme.surface_variant.r, Theme.surface_variant.g, Theme.surface_variant.b, 0.4) : Theme.surface_variant

                    topLeftRadius: Math.min(parent.leftRadiusLarge, height / 2)
                    topRightRadius: Math.min(parent.leftRadiusLarge, height / 2)
                    bottomLeftRadius: Math.min(parent.leftRadiusSmall, height / 2)
                    bottomRightRadius: Math.min(parent.leftRadiusSmall, height / 2)

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: Math.max(8, parent.parent.leftRadiusLarge - height / 2)
                        text: mainContainer.volumeIcon
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 20
                        color: Theme.on_surface_variant
                        opacity: osdTopTrack.height > parent.parent.leftRadiusLarge * 2.5 ? 0.6 : 0.0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Vars.animationDuration
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Vars.customStandard
                            }
                        }
                    }
                }

                Rectangle {
                    id: osdBottomTrack
                    x: 0
                    y: parent.handlePos + mainContainer.handleWidth + mainContainer.gap
                    width: parent.width
                    height: Math.max(0, parent.height - y)
                    color: Theme.primary

                    topLeftRadius: Math.min(parent.leftRadiusSmall, height / 2)
                    topRightRadius: Math.min(parent.leftRadiusSmall, height / 2)
                    bottomLeftRadius: Math.min(parent.leftRadiusLarge, height / 2)
                    bottomRightRadius: Math.min(parent.leftRadiusLarge, height / 2)
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
