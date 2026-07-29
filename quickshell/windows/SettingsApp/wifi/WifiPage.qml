import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import "../../.."
import "../../../theme/variables.js" as Vars
import "../../../core/primitives" as Primitives
import ".."

Item {
    id: rootWifiPage

    Layout.fillWidth: true
    Layout.fillHeight: true

    property var panelRef
    property var wifiDevice

    property bool authOverlayVisible: false
    property string pendingSsid: ""
    property bool authError: false
    property string selectedNetworkForInfo: ""
    property string selectedNetworkPassword: ""

    Process {
        id: nmcliPwdProcess
        property string targetSsid: ""
        command: ["nmcli", "-s", "-g", "802-11-wireless-security.psk", "connection", "show", targetSsid]
        stdout: StdioCollector {
            onStreamFinished: {
                rootWifiPage.selectedNetworkPassword = this.text.trim();
            }
        }
    }

    Process {
        id: authProcess
        property string pwd: ""
        command: ["bash", "-c", "echo '" + pwd.replace(/'/g, "'\\''") + "' | sudo -S true"]
        onExited: code => {
            if (code === 0) {
                // Success!
                rootWifiPage.selectedNetworkForInfo = rootWifiPage.pendingSsid;
                rootWifiPage.selectedNetworkPassword = "Fetching...";
                nmcliPwdProcess.targetSsid = rootWifiPage.pendingSsid;
                nmcliPwdProcess.running = true;

                rootWifiPage.authOverlayVisible = false;
                authPwdInput.text = "";
                rootWifiPage.authError = false;
            } else {
                rootWifiPage.authError = true;
                authPwdInput.selectAll();
                authPwdInput.forceActiveFocus();
            }
        }
    }

    function showPasswordFor(ssid) {
        rootWifiPage.pendingSsid = ssid;
        rootWifiPage.authOverlayVisible = true;
        rootWifiPage.authError = false;
        authPwdInput.text = "";
        authPwdInput.forceActiveFocus();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Vars.spacingMedium

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                text: "Wi-Fi Networks"
                font.family: Vars.fontFamily
                font.pixelSize: 16
                font.weight: 500
                color: Theme.on_surface
            }
            Text {
                text: "Network connection and internet availability"
                font.family: Vars.fontFamily
                font.pixelSize: 12
                color: Theme.on_surface
                opacity: 0.7
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: wifiContent.implicitHeight
            clip: true
            // boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: Vars.flickDeceleration
            maximumFlickVelocity: Vars.maximumFlickVelocity

            ColumnLayout {
                id: wifiContent
                width: parent.width
                spacing: Vars.spacingSmall

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    // Wi-Fi Header Card
                    Item {
                        id: wifiHeader
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72

                        property color targetColor: wifiHeaderMouse.containsMouse ? Qt.tint((Vars.translucent ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, 0.5) : Theme.surface_container), Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : (Vars.translucent ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, 0.5) : Theme.surface_container)
                        Behavior on targetColor {
                            ColorAnimation {
                                duration: Vars.animationDuration
                            }
                        }

                        Item {
                            anchors.fill: parent
                            layer.enabled: true
                            opacity: parent.targetColor.a
                            Rectangle {
                                anchors.fill: parent
                                radius: 16
                                color: Qt.rgba(parent.parent.targetColor.r, parent.parent.targetColor.g, parent.parent.targetColor.b, 1.0)

                                Rectangle {
                                    width: 16
                                    height: 16
                                    color: parent.color
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    visible: Networking.wifiEnabled
                                }
                                Rectangle {
                                    width: 16
                                    height: 16
                                    color: parent.color
                                    anchors.bottom: parent.bottom
                                    anchors.right: parent.right
                                    visible: Networking.wifiEnabled
                                }
                            }
                        }

                        activeFocusOnTab: true
                        Keys.onSpacePressed: Networking.wifiEnabled = !Networking.wifiEnabled
                        Keys.onReturnPressed: Networking.wifiEnabled = !Networking.wifiEnabled

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            Text {
                                text: "Wi-Fi"
                                font.family: Vars.fontFamily
                                font.pixelSize: 16
                                font.weight: 500
                                color: Theme.on_surface
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                width: 52
                                height: 32
                                radius: 16
                                color: Networking.wifiEnabled ? Theme.primary : Theme.surface_variant
                                border.color: wifiHeader.activeFocus ? Theme.on_surface : "transparent"
                                border.width: wifiHeader.activeFocus ? 2 : 0
                                Rectangle {
                                    width: 24
                                    height: 24
                                    radius: 12
                                    color: Networking.wifiEnabled ? Theme.on_primary : Theme.on_surface_variant
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: Networking.wifiEnabled ? 24 : 4
                                    Behavior on anchors.leftMargin {
                                        NumberAnimation {
                                            duration: Vars.animationDuration
                                            easing.type: Easing.BezierSpline
                                            easing.bezierCurve: Vars.customStandard
                                        }
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        font.family: "Material Symbols Outlined"
                                        font.pixelSize: 16
                                        color: Networking.wifiEnabled ? Theme.primary : Theme.surface_variant
                                        text: Networking.wifiEnabled ? "\ue5ca" : "\ue5cd"
                                    }
                                }
                            }
                        }
                        MouseArea {
                            id: wifiHeaderMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                wifiHeader.forceActiveFocus();
                                Networking.wifiEnabled = !Networking.wifiEnabled;
                            }
                        }
                    }

                    // Empty state (only if enabled and no networks)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        visible: Networking.wifiEnabled && (!rootWifiPage.wifiDevice || rootWifiPage.wifiDevice.networks.values.length === 0)
                        radius: 16
                        color: Vars.translucent ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, 0.5) : Theme.surface_container

                        Rectangle {
                            width: 16
                            height: 16
                            color: parent.color
                            anchors.top: parent.top
                            anchors.left: parent.left
                        }
                        Rectangle {
                            width: 16
                            height: 16
                            color: parent.color
                            anchors.top: parent.top
                            anchors.right: parent.right
                        }
                        Rectangle {
                            width: 16
                            height: 16
                            color: parent.color
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                        }
                        Rectangle {
                            width: 16
                            height: 16
                            color: parent.color
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                text: "\ue63e"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 32
                                color: Theme.on_surface_variant
                                Layout.alignment: Qt.AlignHCenter
                            } // Wifi off icon
                            Text {
                                text: "No networks found"
                                font.family: Vars.fontFamily
                                font.pixelSize: 16
                                color: Theme.on_surface_variant
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // Wi-Fi List
                    Repeater {
                        model: rootWifiPage.wifiDevice && Networking.wifiEnabled ? rootWifiPage.wifiDevice.networks.values : []
                        delegate: WifiNetworkDelegate {
                            rootPage: rootWifiPage
                        }
                    }

                    // Scan for Networks Card
                    Item {
                        id: scanCard
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        visible: Networking.wifiEnabled

                        property color targetColor: scanMouse.containsMouse ? Qt.tint((Vars.translucent ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, 0.5) : Theme.surface_container), Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : (Vars.translucent ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, 0.5) : Theme.surface_container)
                        Behavior on targetColor {
                            ColorAnimation {
                                duration: Vars.animationDuration
                            }
                        }

                        Item {
                            anchors.fill: parent
                            layer.enabled: true
                            opacity: parent.targetColor.a
                            Rectangle {
                                anchors.fill: parent
                                radius: 16
                                color: Qt.rgba(parent.parent.targetColor.r, parent.parent.targetColor.g, parent.parent.targetColor.b, 1.0)

                                Rectangle {
                                    width: 16
                                    height: 16
                                    color: parent.color
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                }
                                Rectangle {
                                    width: 16
                                    height: 16
                                    color: parent.color
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                }
                            }
                        }

                        activeFocusOnTab: true
                        Keys.onSpacePressed: {
                            if (rootWifiPage.wifiDevice)
                                rootWifiPage.wifiDevice.scannerEnabled = !rootWifiPage.wifiDevice.scannerEnabled;
                        }
                        Keys.onReturnPressed: {
                            if (rootWifiPage.wifiDevice)
                                rootWifiPage.wifiDevice.scannerEnabled = !rootWifiPage.wifiDevice.scannerEnabled;
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            spacing: 16

                            Item {
                                width: 40
                                height: 40
                                Layout.alignment: Qt.AlignVCenter

                                Item {
                                    id: scanLoadingIndicator
                                    anchors.fill: parent
                                    property bool running: rootWifiPage.wifiDevice ? rootWifiPage.wifiDevice.scannerEnabled : false

                                    Primitives.LoadingIndicator {
                                        anchors.fill: parent
                                        running: scanLoadingIndicator.running
                                    }
                                }

                                Text {
                                    id: wifiScanIcon
                                    anchors.centerIn: parent
                                    text: "\ue863"
                                    font.family: "Material Symbols Outlined"
                                    font.pixelSize: 24
                                    color: rootWifiPage.wifiDevice && rootWifiPage.wifiDevice.scannerEnabled ? Theme.on_surface_variant : Theme.on_surface
                                    opacity: scanLoadingIndicator.running ? 0.0 : 1.0
                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 300
                                        }
                                    }
                                }
                            }

                            Text {
                                text: (rootWifiPage.wifiDevice && rootWifiPage.wifiDevice.scannerEnabled) ? "Scanning..." : "Scan for Networks"
                                font.family: Vars.fontFamily
                                font.pixelSize: 16
                                font.weight: 500
                                color: Theme.on_surface
                                Layout.fillWidth: true
                            }
                        }
                        MouseArea {
                            id: scanMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                scanCard.forceActiveFocus();
                                if (rootWifiPage.wifiDevice)
                                    rootWifiPage.wifiDevice.scannerEnabled = !rootWifiPage.wifiDevice.scannerEnabled;
                            }
                        }
                    }
                }
            }
        }
    }

    // Password Info Page Overlay
    Rectangle {
        id: infoPageOverlay
        anchors.fill: parent
        color: Vars.translucent ? Qt.rgba(Theme.surface_container_low.r, Theme.surface_container_low.g, Theme.surface_container_low.b, 0.85) : Theme.surface_container_low
        visible: rootWifiPage.selectedNetworkForInfo !== ""
        opacity: visible ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }
        z: 100

        // Intercept mouse events so they don't fall through to the list beneath
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Vars.spacingMedium

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: backInfoHover.pressed ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12) : (backInfoHover.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent")
                    Text {
                        anchors.centerIn: parent
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 20
                        color: Theme.on_surface
                        text: "\ue5c4"
                    }
                    MouseArea {
                        id: backInfoHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: rootWifiPage.selectedNetworkForInfo = ""
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Vars.animationDuration
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Vars.customStandard
                        }
                    }
                }

                Text {
                    text: "Network Password"
                    font.family: Vars.fontFamily
                    font.pixelSize: 20
                    font.weight: 600
                    color: Theme.on_surface
                }
                Item {
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                radius: 16
                color: Vars.translucent ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, 0.5) : Theme.surface_container

                ColumnLayout {
                    anchors.centerIn: parent
                    Text {
                        text: rootWifiPage.selectedNetworkForInfo
                        font.family: Vars.fontFamily
                        font.pixelSize: 18
                        font.weight: 500
                        color: Theme.on_surface
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "Saved Password"
                        font.family: Vars.fontFamily
                        font.pixelSize: 12
                        color: Theme.on_surface_variant
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                radius: 16
                color: Vars.translucent ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, 0.5) : Theme.surface_container_highest

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16

                    Text {
                        text: rootWifiPage.selectedNetworkPassword !== "" ? rootWifiPage.selectedNetworkPassword : "No password found"
                        font.family: Vars.fontFamily
                        font.pixelSize: 16
                        color: Theme.on_surface
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: copyHover.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent"
                        Text {
                            anchors.centerIn: parent
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 20
                            color: Theme.on_surface_variant
                            text: "content_copy"
                        }
                        MouseArea {
                            id: copyHover
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                Quickshell.execDetached({
                                    command: ["wl-copy", rootWifiPage.selectedNetworkPassword]
                                });
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    // Password Auth Page Overlay
    Rectangle {
        id: authPageOverlay
        anchors.fill: parent
        color: Vars.translucent ? Qt.rgba(Theme.surface_container_low.r, Theme.surface_container_low.g, Theme.surface_container_low.b, 0.85) : Theme.surface_container_low
        visible: rootWifiPage.authOverlayVisible
        opacity: visible ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Vars.customExpressiveSpatialSlow
            }
        }
        z: 101 // Above info page overlay

        // Intercept mouse events so they don't fall through
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Vars.spacingMedium

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: backAuthHover.pressed ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.12) : (backAuthHover.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent")
                    Text {
                        anchors.centerIn: parent
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 20
                        color: Theme.on_surface
                        text: "\ue5c4"
                    }
                    MouseArea {
                        id: backAuthHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: rootWifiPage.authOverlayVisible = false
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Vars.animationDuration
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Vars.customStandard
                        }
                    }
                }

                Text {
                    text: "Authentication Required"
                    font.family: Vars.fontFamily
                    font.pixelSize: 20
                    font.weight: 600
                    color: Theme.on_surface
                }
                Item {
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                radius: 16
                color: Vars.translucent ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, 0.5) : Theme.surface_container

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    Rectangle {
                        Layout.preferredWidth: 320
                        Layout.preferredHeight: 56
                        Layout.alignment: Qt.AlignHCenter
                        radius: 8
                        color: "transparent"
                        border.color: rootWifiPage.authError ? Theme.error : (authPwdInput.activeFocus ? Theme.primary : Theme.outline)
                        border.width: authPwdInput.activeFocus ? 3 : 2
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            color: Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, 1.0)
                            height: ssidLabelText.height
                            width: ssidLabelText.width + 8
                            anchors.verticalCenter: parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: 12

                            Text {
                                id: ssidLabelText
                                anchors.centerIn: parent
                                text: rootWifiPage.pendingSsid
                                font.family: "Google Sans Flefx"
                                font.pixelSize: 12
                                font.weight: 800
                                color: rootWifiPage.authError ? Theme.error : (authPwdInput.activeFocus ? Theme.primary : Theme.on_surface_variant)
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }

                        TextInput {
                            id: authPwdInput
                            anchors.fill: parent
                            anchors.margins: 16
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: Vars.fontFamily
                            font.pixelSize: 16
                            color: rootWifiPage.authError ? Theme.error : Theme.on_surface
                            echoMode: TextInput.Password
                            clip: true

                            Keys.onReturnPressed: {
                                authProcess.pwd = authPwdInput.text;
                                authProcess.running = true;
                            }
                        }
                    }

                    Text {
                        text: "Enter system password to view Wi-Fi credentials."
                        font.family: Vars.fontFamily
                        font.pixelSize: 14
                        color: Theme.on_surface_variant
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Incorrect password"
                        font.family: Vars.fontFamily
                        font.pixelSize: 12
                        color: Theme.error
                        visible: rootWifiPage.authError
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
