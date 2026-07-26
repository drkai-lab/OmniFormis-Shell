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
    visible: Vars.panelStyle === "Attached" || Vars.panelStyle === "Framed"
    mask: Region {}

    Item {
        anchors.fill: parent
        layer.enabled: Vars.translucent
        opacity: Vars.translucent ? 0.85 : 1.0

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Theme.surface
            border.width: Vars.spacingSmall
            radius: Vars.radiusExtraLarge
        }

        InvertedCorner {
            anchors.top: parent.top
            anchors.left: parent.left
            side: "top-left"
            radius: Vars.radiusExtraLarge
            color: Theme.surface
        }

        InvertedCorner {
            anchors.top: parent.top
            anchors.right: parent.right
            side: "top-right"
            radius: Vars.radiusExtraLarge
            color: Theme.surface
        }

        InvertedCorner {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            side: "bottom-left"
            radius: Vars.radiusExtraLarge
            color: Theme.surface
        }

        InvertedCorner {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            side: "bottom-right"
            radius: Vars.radiusExtraLarge
            color: Theme.surface
        }
    }
}
