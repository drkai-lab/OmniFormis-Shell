import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"
import "../../theme/variables.js" as Vars

Rectangle {
    id: root
    color: "transparent"

    property alias text: searchInput.text
    property alias searchInput: searchInput
    property bool isActiveFocus: searchInput.activeFocus
    property bool expanded: false
    property bool keepFocus: expanded
    property string placeholderText: "Search..."
    property string iconText: "search"
    property bool showIcon: false
    property int defaultHeight: 48
    property color defaultColor: Vars.tColor(Theme.surface_container_highest, Vars.componentOpacity)
    property color activeColor: Vars.tColor(Theme.primary_container, Vars.componentOpacity)
    property color defaultTextColor: Theme.on_surface
    property color activeTextColor: Theme.on_primary_container
    property color defaultPlaceholderColor: Theme.on_surface_variant

    signal downPressed(var event)
    signal returnPressed(var event)
    signal escapePressed(var event)
    signal upPressed(var event)

    Layout.fillWidth: true
    Layout.preferredHeight: defaultHeight
    Layout.minimumHeight: defaultHeight
    Layout.maximumHeight: defaultHeight

    Rectangle {
        anchors.fill: parent
        color: searchInput.activeFocus ? activeColor : defaultColor
        border.color: searchInput.activeFocus ? Theme.primary : "transparent"
        border.width: searchInput.activeFocus ? 2 : 0
        radius: searchInput.activeFocus ? Vars.radiusLarge : Vars.radiusExtraLarge
        topLeftRadius: root.topLeftRadius !== 0 ? root.topLeftRadius : radius
        topRightRadius: root.topRightRadius !== 0 ? root.topRightRadius : radius
        bottomLeftRadius: root.bottomLeftRadius !== 0 ? root.bottomLeftRadius : radius
        bottomRightRadius: root.bottomRightRadius !== 0 ? root.bottomRightRadius : radius

        Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
        Behavior on radius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.IBeamCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onPressed: (mouse) => {
                searchInput.forceActiveFocus();
                mouse.accepted = true;
            }
        }
    }

    function forceActiveFocus() {
        searchInput.forceActiveFocus();
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Vars.spacingMedium
        anchors.rightMargin: Vars.spacingMedium
        spacing: Vars.spacingMedium

        QsText {
            text: root.iconText
            font.family: "Material Symbols Outlined"
            font.pixelSize: 24
            color: searchInput.activeFocus ? root.activeTextColor : root.defaultTextColor
            visible: root.showIcon
        }

        TextInput {
            id: searchInput
            Layout.fillWidth: true
            font.family: Vars.fontFamily
            font.pixelSize: 16
            color: searchInput.activeFocus ? root.activeTextColor : root.defaultTextColor
            focus: root.keepFocus
            selectByMouse: true
            verticalAlignment: TextInput.AlignVCenter
            clip: true

            property bool _deliberateFocusLoss: false

            onActiveFocusChanged: {
                console.log("[DEBUG] SearchBar activeFocus changed:", activeFocus);
                if (activeFocus) {
                    _deliberateFocusLoss = false;
                    Qt.inputMethod.reset();
                    Qt.inputMethod.update(Qt.ImEnabled | Qt.ImQueryInput);
                }
            }

            QsText {
                text: root.placeholderText
                font.family: Vars.fontFamily
                font.pixelSize: searchInput.font.pixelSize
                color: root.defaultPlaceholderColor
                opacity: 0.8
                visible: !searchInput.text && !searchInput.activeFocus
                anchors.verticalCenter: parent.verticalCenter
            }

            Keys.onDownPressed: (event) => {
                searchInput._deliberateFocusLoss = true;
                root.downPressed(event);
            }
            Keys.onUpPressed: (event) => {
                searchInput._deliberateFocusLoss = true;
                root.upPressed(event);
            }
            Keys.onReturnPressed: (event) => {
                searchInput._deliberateFocusLoss = true;
                root.returnPressed(event);
            }
            Keys.onEscapePressed: (event) => {
                searchInput._deliberateFocusLoss = true;
                root.escapePressed(event);
            }
        }

        QsText {
            id: clearIcon
            text: "✕"
            font.pixelSize: 14
            color: searchInput.activeFocus ? root.activeTextColor : root.defaultTextColor
            visible: searchInput.text.length > 0
            Layout.alignment: Qt.AlignVCenter
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    searchInput.text = ""
                    searchInput.forceActiveFocus()
                }
            }
        }
    }
}


