import QtQuick
import Quickshell
import Quickshell.Wayland
import QtCore
import "../.."
import "../../panels/ControlCenter" as CC
import "../../theme/variables.js" as Vars

PanelWindow {
    id: window
    color: "transparent"
    property bool playerEnabled: Vars.desktopMediaPlayerEnabled !== undefined ? Vars.desktopMediaPlayerEnabled : false
    property bool anchorEnabled: Vars.desktopMediaPlayerAnchorEnabled !== undefined ? Vars.desktopMediaPlayerAnchorEnabled : false
    property string anchorPoint: Vars.desktopMediaPlayerAnchorPoint !== undefined ? Vars.desktopMediaPlayerAnchorPoint : "Center"
    property int anchorCurve: Vars.desktopMediaPlayerAnchorCurve !== undefined ? Vars.desktopMediaPlayerAnchorCurve : 0
    property string maskShape: Vars.wallpaperMaskShape !== undefined ? Vars.wallpaperMaskShape : "9SidedCookie"
    property real maskScale: Vars.wallpaperMaskScale !== undefined ? Vars.wallpaperMaskScale : 1.05
    property int maskOffsetX: Vars.wallpaperMaskOffsetX !== undefined ? Vars.wallpaperMaskOffsetX : 0
    property int maskOffsetY: Vars.wallpaperMaskOffsetY !== undefined ? Vars.wallpaperMaskOffsetY : 0

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            if (Vars.desktopMediaPlayerEnabled !== undefined && window.playerEnabled !== Vars.desktopMediaPlayerEnabled) window.playerEnabled = Vars.desktopMediaPlayerEnabled;
            if (Vars.desktopMediaPlayerAnchorEnabled !== undefined && window.anchorEnabled !== Vars.desktopMediaPlayerAnchorEnabled) window.anchorEnabled = Vars.desktopMediaPlayerAnchorEnabled;
            if (Vars.desktopMediaPlayerAnchorPoint !== undefined && window.anchorPoint !== Vars.desktopMediaPlayerAnchorPoint) window.anchorPoint = Vars.desktopMediaPlayerAnchorPoint;
            if (Vars.desktopMediaPlayerAnchorCurve !== undefined && window.anchorCurve !== Vars.desktopMediaPlayerAnchorCurve) window.anchorCurve = Vars.desktopMediaPlayerAnchorCurve;
            if (Vars.wallpaperMaskShape !== undefined && window.maskShape !== Vars.wallpaperMaskShape) window.maskShape = Vars.wallpaperMaskShape;
            if (Vars.wallpaperMaskScale !== undefined && window.maskScale !== Vars.wallpaperMaskScale) window.maskScale = Vars.wallpaperMaskScale;
            if (Vars.wallpaperMaskOffsetX !== undefined && window.maskOffsetX !== Vars.wallpaperMaskOffsetX) window.maskOffsetX = Vars.wallpaperMaskOffsetX;
            if (Vars.wallpaperMaskOffsetY !== undefined && window.maskOffsetY !== Vars.wallpaperMaskOffsetY) window.maskOffsetY = Vars.wallpaperMaskOffsetY;
        }
    }

    visible: window.playerEnabled

    WlrLayershell.namespace: "quickshell"
    WlrLayershell.layer: WlrLayer.Bottom
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    mask: Region {
        item: playerContainer
    }

    Settings {
        id: playerSettings
        category: "DesktopMediaPlayer_" + (window.screen ? window.screen.name : "")
        property int posX: 100
        property int posY: 500
    }

    M3Shapes { id: m3 }
    property var peaks: m3.getShapePeaks(window.maskShape)

    property int computedX: {
        if (window.anchorEnabled && window.anchorCurve >= 0 && window.anchorCurve < peaks.length) {
            var peak = peaks[window.anchorCurve];
            var maskSize = Math.min(window.width, window.height) * window.maskScale;
            var centerX = window.width / 2 + window.maskOffsetX;
            var targetX = centerX - maskSize / 2 + (peak.x / 100.0) * maskSize;
            
            var widgetX = targetX;
            var pt = window.anchorPoint;
            if (pt === "TopCenter" || pt === "Center" || pt === "BottomCenter") widgetX -= playerContainer.width / 2;
            else if (pt === "TopRight" || pt === "MiddleRight" || pt === "BottomRight") widgetX -= playerContainer.width;
            return widgetX;
        }
        return playerSettings.posX;
    }

    property int computedY: {
        if (window.anchorEnabled && window.anchorCurve >= 0 && window.anchorCurve < peaks.length) {
            var peak = peaks[window.anchorCurve];
            var maskSize = Math.min(window.width, window.height) * window.maskScale;
            var centerY = window.height / 2 + window.maskOffsetY;
            var targetY = centerY - maskSize / 2 + (peak.y / 100.0) * maskSize;
            
            var widgetY = targetY;
            var pt = window.anchorPoint;
            if (pt === "MiddleLeft" || pt === "Center" || pt === "MiddleRight") widgetY -= playerContainer.height / 2;
            else if (pt === "BottomLeft" || pt === "BottomCenter" || pt === "BottomRight") widgetY -= playerContainer.height;
            return widgetY;
        }
        return playerSettings.posY;
    }

    Item {
        id: playerContainer
        width: 548 // 500 + 48 for shadows
        height: 228 // 180 + 48 for shadows
        x: computedX
        y: computedY
        
        Behavior on x { enabled: window.anchorEnabled; NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
        Behavior on y { enabled: window.anchorEnabled; NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

        CC.MediaPlayer {
            id: player
            anchors.fill: parent
            anchors.margins: 24 // Give space for shadow
        }

        DragHandler {
            id: dragHandler
            target: playerContainer
            enabled: !window.anchorEnabled

            xAxis.minimum: 0
            xAxis.maximum: window.width > 0 ? window.width - playerContainer.width : 9999
            yAxis.minimum: 0
            yAxis.maximum: window.height > 0 ? window.height - playerContainer.height : 9999

            onActiveChanged: {
                if (!active) {
                    playerSettings.posX = playerContainer.x;
                    playerSettings.posY = playerContainer.y;
                }
            }
        }
    }
}
