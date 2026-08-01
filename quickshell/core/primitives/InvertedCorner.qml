import QtQuick
import "../../theme/variables.js" as Vars
import "../.."

Item {
    id: root
    property string side: "left" // "left", "right", "top-left", "top-right", "bottom-left", "bottom-right"
    property real radius: Vars.radiusExtraLarge
    property color color: Theme.surface

    width: radius
    height: radius
    clip: true

    property bool isRightSolid: (side === "left" || side === "top-right" || side === "bottom-right" || side === "bottom-left-attach" || side === "right-top" || side === "right-bottom")
    property bool isBottomSolid: (side === "bottom-left" || side === "bottom-right" || side === "bottom-left-attach" || side === "bottom-right-attach" || side === "right-top" || side === "left-top" || side === "left-bottom" || side === "right-bottom")

    Rectangle {
        width: root.radius * 4
        height: root.radius * 4
        radius: root.radius * 2
        color: "transparent"
        border.color: root.color
        border.width: root.radius
        
        property real holeCenterX: root.isRightSolid ? 0 : root.radius
        property real holeCenterY: root.isBottomSolid ? 0 : root.radius
        
        x: holeCenterX - (width / 2)
        y: holeCenterY - (height / 2)
    }
}
