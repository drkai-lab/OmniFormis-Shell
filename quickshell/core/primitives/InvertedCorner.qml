import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
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

    property real power: Vars.cornerPower
    property var _points: []

    function updatePoints() {
        if (radius <= 0) return;
        var pts = [];
        var R = radius;
        var hcx = isRightSolid ? 0 : R;
        var hcy = isBottomSolid ? 0 : R;
        
        pts.push(Qt.point(R - hcx, R - hcy)); // Opposite corner
        
        var steps = 36;
        for (var i = 0; i <= steps; i++) {
            var t = (i / steps) * (Math.PI / 2);
            // Default to 2.0 if power is undefined or too low
            var p = Math.max(2.0, power);
            var cx = Math.pow(Math.cos(t), 2.0 / p);
            var cy = Math.pow(Math.sin(t), 2.0 / p);
            
            var x = (hcx === 0) ? (R * cx) : (R - R * cx);
            var y = (hcy === 0) ? (R * cy) : (R - R * cy);
            pts.push(Qt.point(x, y));
        }
        _points = pts;
    }

    onRadiusChanged: updatePoints()
    onSideChanged: updatePoints()
    onPowerChanged: updatePoints()
    Component.onCompleted: updatePoints()

    Rectangle {
        width: root.radius * 4
        height: root.radius * 4
        radius: root.radius * 2
        color: "transparent"
        border.color: root.color
        border.width: root.radius
        antialiasing: true
        smooth: true
        
        property real holeCenterX: root.isRightSolid ? 0 : root.radius
        property real holeCenterY: root.isBottomSolid ? 0 : root.radius
        
        x: holeCenterX - (width / 2)
        y: holeCenterY - (height / 2)
        
        visible: root.power <= 2.0
    }



    Shape {
        anchors.fill: parent
        visible: root.power > 2.0
        antialiasing: true
        smooth: true

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            strokeWidth: 0
            PathPolyline { path: root._points }
        }
    }


}
