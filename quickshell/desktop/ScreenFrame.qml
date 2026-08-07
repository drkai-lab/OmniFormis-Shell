import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme/variables.js" as Vars
import ".."

PanelWindow {
    id: frameWindow
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    WlrLayershell.namespace: "quickshell"
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
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

    visible: Vars.panelStyle === "Attached" && !gameMode
    mask: Region {}

    Item {
        id: rootContainer
        anchors.fill: parent
        opacity: 0.0
        Component.onCompleted: layerEntranceAnim.start()
        NumberAnimation {
            id: layerEntranceAnim
            target: rootContainer
            property: "opacity"
            to: 1.0
            duration: 800
            easing.type: Easing.OutCubic
        }

    Item {
        anchors.fill: parent
        layer.enabled: (Vars._translucent && !Vars.gameMode) || false

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Theme.surface
            border.width: 0
            radius: Vars.radiusExtraLarge
        }

        InvertedCorner {
            anchors.top: parent.top
            anchors.left: parent.left
            side: "top-left"
            radius: Vars.radiusExtraLarge
            color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, Vars.panelOpacity) : Theme.surface
        }

        InvertedCorner {
            anchors.top: parent.top
            anchors.right: parent.right
            side: "top-right"
            radius: Vars.radiusExtraLarge
            color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, Vars.panelOpacity) : Theme.surface
        }

        InvertedCorner {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            side: "bottom-left"
            radius: Vars.radiusExtraLarge
            color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, Vars.panelOpacity) : Theme.surface
        }

        InvertedCorner {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            side: "bottom-right"
            radius: Vars.radiusExtraLarge
            color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, Vars.panelOpacity) : Theme.surface
        }
    }
    }
}
