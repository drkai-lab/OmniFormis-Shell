import QtQuick
import QtQuick.Effects
import ".."
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Hyprland
import "../theme/variables.js" as Vars

Item {
    id: root

    Layout.preferredWidth: 100
    Layout.preferredHeight: 40

    property alias panel: panel
    property alias panelMask: panelMask
    property bool expanded: flow !== null && !flow.isCompleted
    property var focusWindow: null
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

    HyprlandFocusGrab {
        active: root.expanded && root.focusWindow !== null
        windows: root.focusWindow ? [root.focusWindow] : []
    }

    PolkitAgent {
        id: polkitAgent
    }

    property var flow: polkitAgent.flow

    // ── Error state ─────────────────────────────────────
    property bool authError: false
    property string errorMessage: ""

    // Reset error state after a delay
    Timer {
        id: errorResetTimer
        interval: 2500
        onTriggered: {
            root.authError = false;
            root.errorMessage = "";
        }
    }

    Connections {
        target: root.flow

        function onFailedChanged() {
            if (root.flow && root.flow.failed) {
                root.authError = true;
                root.errorMessage = "Authentication failed";
                shakeAnim.start();
                errorResetTimer.start();
                passwordInput.text = "";
            }
        }

        function onSupplementaryMessageChanged() {
            if (root.flow && root.flow.supplementaryMessage) {
                if (root.flow.supplementaryIsError) {
                    root.authError = true;
                    root.errorMessage = root.flow.supplementaryMessage;
                    shakeAnim.start();
                    errorResetTimer.start();
                } else {
                    root.errorMessage = root.flow.supplementaryMessage;
                }
            }
        }
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: passwordBox; property: "x"; to: passwordBox.restX - 12; duration: Vars.animationDuration }
        NumberAnimation { target: passwordBox; property: "x"; to: passwordBox.restX + 12; duration: Vars.animationDuration }
        NumberAnimation { target: passwordBox; property: "x"; to: passwordBox.restX - 8; duration: Vars.animationDuration }
        NumberAnimation { target: passwordBox; property: "x"; to: passwordBox.restX + 8; duration: Vars.animationDuration }
        NumberAnimation { target: passwordBox; property: "x"; to: passwordBox.restX; duration: Vars.animationDuration }
    }

    onFlowChanged: {
        if (flow) {
            passwordInput.text = "";
            root.authError = false;
            root.errorMessage = "";
            passwordInput.forceActiveFocus();
        }
    }

    Item {
        id: panelMask
        anchors.centerIn: panel
        width: panel.width + 40
        height: panel.height + 40
    }

    Rectangle {
        id: panel
        layer.enabled: true
        layer.effect: MultiEffect { shadowEnabled: !root.gameMode; shadowBlur: 1.0; shadowColor: Qt.rgba(0,0,0,0.25); shadowVerticalOffset: 4; shadowHorizontalOffset: 0 }
        anchors.top: (!Vars.pillPosition || Vars.pillPosition === "Top") ? parent.top : undefined
        anchors.bottom: Vars.pillPosition === "Bottom" ? parent.bottom : undefined
        anchors.left: Vars.pillPosition === "Left" ? parent.left : undefined
        anchors.right: Vars.pillPosition === "Right" ? parent.right : undefined
        anchors.horizontalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? undefined : parent.horizontalCenter
        anchors.verticalCenter: (Vars.pillPosition === "Left" || Vars.pillPosition === "Right") ? parent.verticalCenter : undefined

        width: root.expanded ? 420 : 100
        height: root.expanded ? contentColumn.implicitHeight + 32 : 40

        opacity: root.expanded || panel.width > 105 ? 1.0 : 0.0
        visible: opacity > 0

        color: Vars.translucent ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.85) : Theme.surface
        property real targetRad: root.expanded ? Vars.radiusExtraLarge : height / 2
        topLeftRadius: Vars.getTopLeftRadius(Vars.panelStyle, Vars.pillPosition, root.gameMode, targetRad)
        topRightRadius: Vars.getTopRightRadius(Vars.panelStyle, Vars.pillPosition, root.gameMode, targetRad)
        bottomLeftRadius: Vars.getBottomLeftRadius(Vars.panelStyle, Vars.pillPosition, root.gameMode, targetRad)
        bottomRightRadius: Vars.getBottomRightRadius(Vars.panelStyle, Vars.pillPosition, root.gameMode, targetRad)

        Behavior on topLeftRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on topRightRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on bottomLeftRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on bottomRightRadius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on width { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on height { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

        // EXPANDED UI
        Item {
            anchors.fill: parent

            opacity: root.expanded ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity { SequentialAnimation { PauseAnimation { duration: root.expanded ? Vars.animationDuration : 0 } NumberAnimation { duration: root.expanded ? Vars.animationDuration : Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: root.expanded ? Vars.customEmphasizedDecelerate : Vars.customEmphasizedAccelerate } } }

            ColumnLayout {
                id: contentColumn
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 16
                }
                spacing: 8

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 22
                        color: Theme.primary
                        text: "\ue897"
                    }

                    Text {
                        text: "Authentication Required"
                        font.family: Vars.fontFamily
                        font.pixelSize: 18
                        font.weight: 700
                        color: Theme.on_surface
                    }
                }

                // Message text
                Text {
                    Layout.fillWidth: true
                    text: root.flow ? root.flow.message : ""
                    font.family: Vars.fontFamily
                    font.pixelSize: 13
                    font.weight: 400
                    color: Theme.on_surface
                    wrapMode: Text.WordWrap
                    lineHeight: 1.4
                }

                // Action ID
                Text {
                    Layout.fillWidth: true
                    text: root.flow ? root.flow.actionId : ""
                    font.family: Vars.fontFamily
                    font.pixelSize: 11
                    font.weight: 400
                    color: Theme.on_surface_variant
                    opacity: 0.8
                    visible: root.flow && root.flow.actionId !== ""
                }

                // Password Input
                Rectangle {
                    id: passwordBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: Vars.radiusMedium
                    color: root.authError
                        ? Theme.error_container
                        : (passwordInput.activeFocus ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : Theme.surface_container_highest)
                    border.color: passwordInput.activeFocus
                        ? Theme.primary
                        : (root.authError ? Theme.error : "transparent")
                    border.width: passwordInput.activeFocus ? 2 : 1

                    Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                    Behavior on border.color { ColorAnimation { duration: Vars.animationDuration } }

                    property real restX: x
                    Component.onCompleted: restX = x

                    visible: !root.flow || root.flow.isResponseRequired

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 8

                        TextInput {
                            id: passwordInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: Vars.fontFamily
                            font.pixelSize: 13
                            color: Theme.on_surface
                            echoMode: TextInput.Password
                            clip: true
                            focus: root.expanded

                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: root.flow && root.flow.inputPrompt ? root.flow.inputPrompt : "Password:"
                                color: Theme.on_surface_variant
                                opacity: 0.8
                                font.family: Vars.fontFamily
                                font.pixelSize: 13
                                visible: !passwordInput.text && !passwordInput.activeFocus
                            }

                            onAccepted: {
                                if (text.length > 0 && root.flow) {
                                    root.flow.submit(text);
                                    passwordInput.text = "";
                                }
                            }
                        }
                    }
                }

                // Error / Info message
                Text {
                    Layout.fillWidth: true
                    text: root.errorMessage
                    font.family: Vars.fontFamily
                    font.pixelSize: 11
                    color: root.authError ? Theme.error : Theme.on_surface_variant
                    visible: root.errorMessage !== ""
                    opacity: visible ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: Vars.animationDuration } }
                }

                // Buttons: Cancel | Authenticate
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    layoutDirection: Qt.RightToLeft

                    // Authenticate button
                    Rectangle {
                        Layout.preferredWidth: authenticateLabel.implicitWidth + 40
                        Layout.preferredHeight: 36
                        radius: 18
                        color: authenticateArea.containsMouse
                            ? Qt.lighter(Theme.primary, 1.08)
                            : Theme.primary

                        Behavior on color { ColorAnimation { duration: Vars.animationDuration } }

                        Text {
                            id: authenticateLabel
                            anchors.centerIn: parent
                            text: "Authenticate"
                            font.family: Vars.fontFamily
                            font.pixelSize: 13
                            font.weight: 600
                            color: Theme.on_primary
                        }

                        MouseArea {
                            id: authenticateArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (passwordInput.text.length > 0 && root.flow) {
                                    root.flow.submit(passwordInput.text);
                                    passwordInput.text = "";
                                }
                            }
                        }
                    }

                    // Cancel button
                    Rectangle {
                        Layout.preferredWidth: cancelLabel.implicitWidth + 32
                        Layout.preferredHeight: 36
                        radius: 18
                        color: cancelArea.containsMouse
                            ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)
                            : "transparent"

                        Behavior on color { ColorAnimation { duration: Vars.animationDuration } }

                        Text {
                            id: cancelLabel
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.family: Vars.fontFamily
                            font.pixelSize: 13
                            font.weight: 600
                            color: Theme.on_surface_variant
                        }

                        MouseArea {
                            id: cancelArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.flow) {
                                    root.flow.cancelAuthenticationRequest();
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }
    }
}
