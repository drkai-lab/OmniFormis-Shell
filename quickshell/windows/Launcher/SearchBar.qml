import QtQuick
import QtQuick.Layouts
import Quickshell
import "../.."
import "../../theme"
import "../.."
import "../../theme/variables.js" as Vars

Rectangle {
    id: root

    property alias text: searchInput.text
    property bool isActiveFocus: searchInput.activeFocus
    property bool expanded: false

    signal downPressed()
    signal returnPressed()
    signal escapePressed()

    Layout.fillWidth: true
    Layout.preferredHeight: 48
    color: searchInput.activeFocus ? Theme.primary_container : Theme.surface_container_highest
    border.color: searchInput.activeFocus ? Theme.primary : "transparent"
    border.width: searchInput.activeFocus ? 2 : 0
    radius: searchInput.activeFocus ? Vars.radiusLarge : Vars.radiusExtraLarge

    Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
    Behavior on radius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

    function forceActiveFocus() {
        searchInput.forceActiveFocus();
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Vars.spacingMedium
        anchors.rightMargin: Vars.spacingMedium

        TextInput {
            id: searchInput
            Layout.fillWidth: true
            font.family: Vars.fontFamily
            font.pixelSize: 16
            color: searchInput.activeFocus ? Theme.on_primary_container : Theme.on_surface
            focus: root.expanded
            selectByMouse: true

            property bool _deliberateFocusLoss: false

            onActiveFocusChanged: {
                if (!activeFocus && root.expanded && !_deliberateFocusLoss) {
                    Qt.callLater(() => {
                        if (root.expanded && !searchInput.activeFocus) {
                            searchInput.forceActiveFocus();
                        }
                    });
                }
                if (activeFocus) _deliberateFocusLoss = false;
            }

            Text {
                text: "Search apps..."
                font.family: Vars.fontFamily
                font.pixelSize: 14
                color: Theme.on_surface_variant
                visible: !searchInput.text && !searchInput.activeFocus
            }

            Keys.onDownPressed: (event) => {
                searchInput._deliberateFocusLoss = true;
                root.downPressed();
                event.accepted = true;
            }
            Keys.onReturnPressed: (event) => {
                searchInput._deliberateFocusLoss = true;
                root.returnPressed();
                event.accepted = true;
            }
            Keys.onEscapePressed: (event) => {
                searchInput._deliberateFocusLoss = true;
                root.escapePressed();
                event.accepted = true;
            }
        }

        Text {
            text: "✕"
            font.pixelSize: 14
            color: Theme.on_surface_variant
            visible: searchInput.text.length > 0
            Layout.alignment: Qt.AlignVCenter
            MouseArea {
                anchors.fill: parent
                onClicked: searchInput.text = ""
            }
        }
    }
}
