import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import "../.."
import "../../theme/variables.js" as Vars

Item {
    id: delegateRoot

    M3Shapes { id: m3ShapesObj }

    property var settingsList: ListView.view
    property var settingsModel: ListView.view.model
    required property int index
    required property var model

    property int delegateIndex: index
    property string itemKey: model ? model.key : ""
    property string itemType: model ? model.type : ""
    property string itemHelp: model ? model.help : ""
    property string itemEnums: model ? model.enums : ""
    property string itemVal: model ? model.val : ""
    property string itemSource: model ? model.source : ""
    property real itemMin: model ? model.min : 0
    property real itemMax: model ? model.max : 0
    property real itemStep: model ? model.step : 0

    width: ListView.view.width
    height: Math.max(80, delegateRow.implicitHeight + 32)
    property bool isSelected: false
    
    property color targetColor: delegateMouse.containsMouse ? Qt.tint(((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, Vars.componentOpacity) : Theme.surface_container), Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08)) : ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container.r, Theme.surface_container.g, Theme.surface_container.b, Vars.componentOpacity) : Theme.surface_container)
    Behavior on targetColor {
        ColorAnimation {
            duration: Vars.animationDuration
        }
    }
    
    scale: delegateMouse.pressed ? 1.08 : 1.0
    Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.OutBack } }
    
    Item {
        anchors.fill: parent
        layer.enabled: true
        opacity: parent.targetColor.a
        
        property bool isEffectivelyFirst: delegateRoot.ListView.previousSection !== delegateRoot.ListView.section
        property bool isEffectivelyLast: delegateRoot.ListView.nextSection !== delegateRoot.ListView.section

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(parent.parent.targetColor.r, parent.parent.targetColor.g, parent.parent.targetColor.b, 1.0)
            
            topLeftRadius: parent.isEffectivelyFirst ? Vars.radiusMedium : 4
            topRightRadius: parent.isEffectivelyFirst ? Vars.radiusMedium : 4
            bottomLeftRadius: parent.isEffectivelyLast ? Vars.radiusMedium : 4
            bottomRightRadius: parent.isEffectivelyLast ? Vars.radiusMedium : 4

            Behavior on topLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
            Behavior on topRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
            Behavior on bottomLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
            Behavior on bottomRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        }
    }

    function triggerAction() {
        if (itemType === "bool") {
            var newVal = itemVal === "true" ? "false" : "true";
            settingsModel.setProperty(delegateIndex, "val", newVal);
            rootPage.updateVariable(itemKey, newVal, itemSource);
        } else if (itemType === "string" || itemType === "number") {
            tInput.forceActiveFocus();
        } else if (itemType === "enum") {
            combo.forceActiveFocus();
            combo.popup.open();
        }
    }

    MouseArea {
        id: delegateMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            settingsList.currentIndex = delegateRoot.delegateIndex;
        }
        onClicked: {
            settingsList.currentIndex = delegateRoot.delegateIndex;
        }
    }

    RowLayout {
        id: delegateRow
        anchors.fill: parent
        anchors.margins: Vars.spacingLarge
        spacing: 24

        ColumnLayout {
            Layout.preferredWidth: 350
            Layout.minimumWidth: 200
            Layout.fillWidth: true
            spacing: 4
            Text {
                text: rootPage ? rootPage.prettyTitle(delegateRoot.itemKey) : delegateRoot.itemKey
                font.family: Vars.fontFamily
                font.pixelSize: 16
                font.weight: 600
                color: Theme.on_surface
            }
            Text {
                text: rootPage ? rootPage.prettyHelp(delegateRoot.itemKey, (delegateRoot.itemType === "enum" || delegateRoot.itemType === "color") ? delegateRoot.itemHelp.replace(/\s*\(.*\)/, "") : delegateRoot.itemHelp) : delegateRoot.itemHelp
                font.family: Vars.fontFamily
                font.pixelSize: 12
                color: Theme.on_surface_variant
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        Item {
            Layout.fillWidth: true
            visible: delegateRoot.itemType !== "enum" && !(delegateRoot.itemType === "number" && parseFloat(delegateRoot.itemVal) >= 50)
        }

        Rectangle {
            visible: delegateRoot.itemType === "bool"
            width: 52
            height: 32
            radius: 16
            color: delegateRoot.itemVal === "true" ? ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.8) : Theme.primary) : ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_variant.r, Theme.surface_variant.g, Theme.surface_variant.b, Vars.componentOpacity) : Theme.surface_variant)
            border.color: delegateRoot.activeFocus ? Theme.on_surface : "transparent"
            border.width: delegateRoot.activeFocus ? 2 : 0
            Behavior on color {
                ColorAnimation {
                    duration: Vars.animationDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Vars.customStandard
                }
            }

            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: delegateRoot.itemVal === "true" ? Theme.on_primary : Theme.on_surface_variant
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: delegateRoot.itemVal === "true" ? 24 : 4
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
                    color: delegateRoot.itemVal === "true" ? ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.8) : Theme.primary) : ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_variant.r, Theme.surface_variant.g, Theme.surface_variant.b, Vars.componentOpacity) : Theme.surface_variant)
                    text: delegateRoot.itemVal === "true" ? "\ue5ca" : "\ue5cd"
                }
            }

            scale: toggleMouse.pressed ? 1.08 : 1.0
            Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.OutBack } }

            MouseArea {
                id: toggleMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var newVal = delegateRoot.itemVal === "true" ? "false" : "true";
                    settingsModel.setProperty(delegateRoot.delegateIndex, "val", newVal);
                    rootPage.updateVariable(delegateRoot.itemKey, newVal, delegateRoot.itemSource);
                }
            }
        }

        Rectangle {
            visible: delegateRoot.itemType === "string" || (delegateRoot.itemType === "number" && parseFloat(delegateRoot.itemVal) >= 50)
            Layout.preferredWidth: Math.max(150, Math.min(450, tInput.implicitWidth + 32))
            height: 32
            radius: Vars.radiusSmall
            color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest
            border.color: tInput.activeFocus ? Theme.primary : "transparent"
            border.width: 1

            TextField {
                id: tInput
                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                text: delegateRoot.itemVal
                font.family: Vars.fontFamily
                font.pixelSize: 14
                color: Theme.on_surface
                selectByMouse: true
                clip: true
                background: Item {}
                padding: 0
                leftPadding: 8
                rightPadding: 8
                
                onAccepted: {
                    tInput.focus = false;
                    settingsList.forceActiveFocus();
                }
                onTextEdited: {
                    if (text !== delegateRoot.itemVal) {
                        settingsModel.setProperty(delegateRoot.delegateIndex, "val", text);
                        rootPage.updateVariable(delegateRoot.itemKey, text, delegateRoot.itemSource);
                    }
                }
                Keys.onEscapePressed: {
                    text = delegateRoot.itemVal;
                    tInput.focus = false;
                    settingsList.forceActiveFocus();
                }
            }
        }

        RowLayout {
            visible: delegateRoot.itemType === "number" && parseFloat(delegateRoot.itemVal) < 50
            spacing: 4
            height: 32

            Rectangle {
                width: 80
                height: 32
                radius: Vars.radiusSmall
                color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest
                border.color: numInput.activeFocus ? Theme.primary : "transparent"
                border.width: 1
                TextField {
                    id: numInput
                    anchors.fill: parent
                    verticalAlignment: TextInput.AlignVCenter
                    text: delegateRoot.itemVal
                    font.family: Vars.fontFamily
                    font.pixelSize: 14
                    color: Theme.on_surface
                    selectByMouse: true
                    clip: true
                    background: Item {}
                    padding: 0
                    leftPadding: 8
                    rightPadding: 8
                    
                    onAccepted: {
                        numInput.focus = false;
                        settingsList.forceActiveFocus();
                    }
                    onTextEdited: {
                        if (text !== delegateRoot.itemVal) {
                            settingsModel.setProperty(delegateRoot.delegateIndex, "val", text);
                            rootPage.updateVariable(delegateRoot.itemKey, text, delegateRoot.itemSource);
                        }
                    }
                    Keys.onEscapePressed: {
                        text = delegateRoot.itemVal;
                        numInput.focus = false;
                        settingsList.forceActiveFocus();
                    }
                }
            }

            Rectangle {
                width: 32
                height: 32
                radius: Vars.radiusSmall
                color: numMinusHover.containsMouse ? ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_high.r, Theme.surface_container_high.g, Theme.surface_container_high.b, Vars.componentOpacity) : Theme.surface_container_high) : ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest)
                Text {
                    anchors.centerIn: parent
                    text: "remove"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 20
                    color: Theme.on_surface
                }
                scale: numMinusHover.pressed ? 1.15 : 1.0
                Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.OutBack } }

                MouseArea {
                    id: numMinusHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var val = parseFloat(delegateRoot.itemVal) - 1;
                        settingsModel.setProperty(delegateRoot.delegateIndex, "val", val.toString());
                        rootPage.updateVariable(delegateRoot.itemKey, val.toString(), delegateRoot.itemSource);
                    }
                }
            }

            Rectangle {
                width: 32
                height: 32
                radius: Vars.radiusSmall
                color: numPlusHover.containsMouse ? ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_high.r, Theme.surface_container_high.g, Theme.surface_container_high.b, Vars.componentOpacity) : Theme.surface_container_high) : ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest)
                Text {
                    anchors.centerIn: parent
                    text: "add"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 20
                    color: Theme.on_surface
                }
                scale: numPlusHover.pressed ? 1.15 : 1.0
                Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.OutBack } }

                MouseArea {
                    id: numPlusHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var val = parseFloat(delegateRoot.itemVal) + 1;
                        settingsModel.setProperty(delegateRoot.delegateIndex, "val", val.toString());
                        rootPage.updateVariable(delegateRoot.itemKey, val.toString(), delegateRoot.itemSource);
                    }
                }
            }
        }

        Slider {
            id: m3Slider
            visible: delegateRoot.itemType === "slider"
            Layout.fillWidth: true
            Layout.preferredWidth: 320
            implicitHeight: 48
            padding: 0

            property real computedMax: {
                if (delegateRoot.itemKey.endsWith("AnchorCurve")) {
                    var peaks = m3ShapesObj.getShapePeaks(Vars.wallpaperMaskShape);
                    return peaks.length > 0 ? peaks.length - 1 : -1;
                }
                return delegateRoot.itemMax;
            }

            from: delegateRoot.itemMin
            to: computedMax
            stepSize: delegateRoot.itemStep
            value: parseFloat(delegateRoot.itemVal)
            snapMode: showTicks ? Slider.SnapAlways : Slider.NoSnap

            property real trackHeight: 36
            property real handleWidth: 4
            property real handleHeight: trackHeight + 8
            property real handleMargin: 6
            property real leftRadiusLarge: 6
            property real leftRadiusSmall: 2
            property real dotSize: 6
            property real gap: 4
            property bool showTicks: ((delegateRoot.itemMax - delegateRoot.itemMin) / delegateRoot.itemStep) <= 25

            property bool isCentered: delegateRoot.itemMin < 0

            onMoved: {
                var rounded = Number((value).toFixed(3));
                settingsModel.setProperty(delegateRoot.delegateIndex, "val", rounded.toString());
                if (delegateRoot.itemSource === "Quickshell" || delegateRoot.itemSource === "quickshell") {
                    try {
                        Vars[delegateRoot.itemKey] = rounded;
                    } catch (e) {
                        console.warn("SettingsApp: Failed to update live slider variable: " + delegateRoot.itemKey + " = " + rounded + ". Error: " + e);
                    }
                }
            }

            onPressedChanged: {
                if (!pressed) {
                    var rounded = Number((value).toFixed(3));
                    rootPage.updateVariable(delegateRoot.itemKey, rounded.toString(), delegateRoot.itemSource);
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                cursorShape: Qt.ArrowCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        sliderContextMenu.popup();
                    }
                }

                Menu {
                    id: sliderContextMenu
                    width: 220
                    topPadding: 8
                    bottomPadding: 8

                    background: Rectangle {
                        implicitWidth: 220
                        color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest
                        radius: 12
                        border.color: Theme.outline_variant
                        border.width: 1
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowBlur: 1.0
                            shadowColor: Qt.rgba(0, 0, 0, 0.25)
                            shadowVerticalOffset: 4
                            shadowHorizontalOffset: 0
                        }
                    }

                    MenuItem {
                        enabled: false
                        implicitWidth: 220
                        implicitHeight: 36
                        contentItem: Item {
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Value"
                                color: Theme.on_surface_variant
                                font.family: Vars.fontFamily
                                font.pixelSize: 13
                            }
                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                text: Number(m3Slider.value).toFixed(3)
                                color: Theme.on_surface
                                font.family: Vars.fontFamily
                                font.pixelSize: 14
                                font.weight: 600
                            }
                        }
                        background: Rectangle { color: "transparent" }
                    }

                    MenuSeparator {
                        implicitWidth: 220
                        implicitHeight: 12
                        contentItem: Rectangle {
                            implicitWidth: 188
                            implicitHeight: 1
                            color: Qt.rgba(Theme.outline_variant.r, Theme.outline_variant.g, Theme.outline_variant.b, Vars.componentOpacity)
                            anchors.centerIn: parent
                        }
                    }

                    MenuItem {
                        implicitWidth: 220
                        implicitHeight: 40
                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 12
                            Text {
                                text: "\ue14d"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 18
                                color: parent.parent.highlighted ? Theme.primary : Theme.on_surface_variant
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Copy Value"
                                color: parent.parent.highlighted ? Theme.primary : Theme.on_surface
                                font.family: Vars.fontFamily
                                font.pixelSize: 14
                                font.weight: 500
                            }
                        }
                        background: Rectangle {
                            color: parent.highlighted ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                            radius: 8
                            anchors.fill: parent
                            anchors.margins: 4
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        onTriggered: rootPage.copiedSliderValue = delegateRoot.itemVal
                    }

                    MenuItem {
                        implicitWidth: 220
                        implicitHeight: 40
                        enabled: rootPage ? (rootPage.copiedSliderValue !== undefined && rootPage.copiedSliderValue !== "") : false
                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 12
                            Text {
                                text: "\ue14f"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 18
                                color: parent.enabled ? (parent.parent.highlighted ? Theme.primary : Theme.on_surface_variant) : Theme.outline
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Paste Value"
                                color: parent.enabled ? (parent.parent.highlighted ? Theme.primary : Theme.on_surface) : Theme.outline
                                font.family: Vars.fontFamily
                                font.pixelSize: 14
                                font.weight: 500
                            }
                            Text {
                                text: (rootPage && rootPage.copiedSliderValue) ? Number(rootPage.copiedSliderValue).toFixed(3) : ""
                                color: Theme.on_surface_variant
                                font.family: Vars.fontFamily
                                font.pixelSize: 12
                            }
                        }
                        background: Rectangle {
                            color: parent.highlighted ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"
                            radius: 8
                            anchors.fill: parent
                            anchors.margins: 4
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        onTriggered: {
                            if (rootPage.copiedSliderValue !== "") {
                                var rounded = Number((parseFloat(rootPage.copiedSliderValue)).toFixed(3));
                                m3Slider.value = rounded;
                                settingsModel.setProperty(delegateRoot.delegateIndex, "val", rounded.toString());
                                rootPage.updateVariable(delegateRoot.itemKey, rounded.toString(), delegateRoot.itemSource);
                            }
                        }
                    }
                    
                    MenuItem {
                        implicitWidth: 220
                        implicitHeight: 40
                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 12
                            Text {
                                text: "\ue166"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 18
                                color: parent.parent.highlighted ? Theme.error : Theme.on_surface_variant
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Reset Value"
                                color: parent.parent.highlighted ? Theme.error : Theme.on_surface
                                font.family: Vars.fontFamily
                                font.pixelSize: 14
                                font.weight: 500
                            }
                        }
                        background: Rectangle {
                            color: parent.highlighted ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.12) : "transparent"
                            radius: 8
                            anchors.fill: parent
                            anchors.margins: 4
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        onTriggered: {
                            var safeDefault = Math.max(m3Slider.from, Math.min(0, m3Slider.to));
                            if (m3Slider.value !== safeDefault) {
                                m3Slider.value = safeDefault;
                                settingsModel.setProperty(delegateRoot.delegateIndex, "val", safeDefault.toString());
                                rootPage.updateVariable(delegateRoot.itemKey, safeDefault.toString(), delegateRoot.itemSource);
                            }
                        }
                    }
                }
            }

            background: Item {
                visible: m3Slider.isCentered
                x: m3Slider.leftPadding
                y: m3Slider.topPadding + (m3Slider.availableHeight - m3Slider.trackHeight) / 2
                width: m3Slider.availableWidth
                height: m3Slider.trackHeight

                property real handlePos: m3Slider.visualPosition * (width - m3Slider.handleWidth)
                property real centerX: width / 2

                property bool isLeftOfCenter: handlePos + m3Slider.handleWidth / 2 < centerX

                Rectangle {
                    id: leftTrackCentered
                    x: 0
                    y: 0
                    width: {
                        var endAt = parent.isLeftOfCenter ? parent.handlePos - m3Slider.gap : parent.centerX - m3Slider.gap;
                        return Math.max(m3Slider.leftRadiusLarge * 2, endAt);
                    }
                    height: parent.height
                    color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest

                    topLeftRadius: m3Slider.leftRadiusLarge
                    bottomLeftRadius: m3Slider.leftRadiusLarge
                    topRightRadius: m3Slider.leftRadiusSmall
                    bottomRightRadius: m3Slider.leftRadiusSmall

                    Rectangle {
                        width: m3Slider.dotSize
                        height: m3Slider.dotSize
                        radius: m3Slider.dotSize / 2
                        color: Theme.on_surface_variant
                        anchors.verticalCenter: parent.verticalCenter
                        x: m3Slider.leftRadiusLarge - m3Slider.dotSize / 2
                        opacity: !m3Slider.showTicks && leftTrackCentered.width > m3Slider.leftRadiusLarge * 2.5 ? 0.6 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                }

                Rectangle {
                    id: coloredIndicatorCentered
                    property real handleRight: parent.handlePos + m3Slider.handleWidth + m3Slider.gap
                    property real handleLeft: parent.handlePos - m3Slider.gap

                    x: parent.isLeftOfCenter ? handleRight : parent.centerX + m3Slider.gap
                    y: 0
                    width: parent.isLeftOfCenter ? Math.max(0, parent.centerX - m3Slider.gap - handleRight) : Math.max(0, handleLeft - parent.centerX - m3Slider.gap)
                    height: parent.height
                    color: Theme.primary
                    radius: m3Slider.leftRadiusSmall
                    visible: width > 2
                }

                Rectangle {
                    id: rightTrackCentered
                    x: {
                        var startAt = parent.isLeftOfCenter ? parent.centerX + m3Slider.gap : parent.handlePos + m3Slider.handleWidth + m3Slider.gap;
                        return startAt;
                    }
                    y: 0
                    width: Math.max(0, parent.width - x)
                    height: parent.height
                    color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest

                    topLeftRadius: Math.min(m3Slider.leftRadiusSmall, width / 2)
                    bottomLeftRadius: Math.min(m3Slider.leftRadiusSmall, width / 2)
                    topRightRadius: Math.min(m3Slider.leftRadiusLarge, width / 2)
                    bottomRightRadius: Math.min(m3Slider.leftRadiusLarge, width / 2)

                    Rectangle {
                        width: m3Slider.dotSize
                        height: m3Slider.dotSize
                        radius: m3Slider.dotSize / 2
                        color: Theme.on_surface_variant
                        anchors.verticalCenter: parent.verticalCenter
                        x: parent.width - m3Slider.leftRadiusLarge - m3Slider.dotSize / 2
                        opacity: !m3Slider.showTicks && rightTrackCentered.width > m3Slider.leftRadiusLarge * 2.5 ? 0.6 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                }

                Repeater {
                    model: m3Slider.showTicks ? Math.max(0, Math.floor((m3Slider.to - m3Slider.from) / m3Slider.stepSize) + 1) : 0
                    Rectangle {
                        property real tickPos: (m3Slider.handleWidth / 2) + (m3Slider.availableWidth - m3Slider.handleWidth) * (index / Math.max(1, (m3Slider.to - m3Slider.from) / m3Slider.stepSize))
                        x: tickPos - width / 2
                        y: (parent.height - height) / 2
                        width: 4
                        height: 4
                        radius: 2

                        property bool inColoredArea: parent.isLeftOfCenter ? (tickPos >= parent.handlePos + m3Slider.handleWidth / 2 && tickPos <= parent.centerX) : (tickPos >= parent.centerX && tickPos <= parent.handlePos + m3Slider.handleWidth / 2)
                        color: inColoredArea ? ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest) : ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, Vars.componentOpacity) : Theme.primary)
                    }
                }
            }

            Loader {
                active: !m3Slider.isCentered
                sourceComponent: Item {
                    x: m3Slider.leftPadding
                    y: m3Slider.topPadding + (m3Slider.availableHeight - m3Slider.trackHeight) / 2
                    width: m3Slider.availableWidth
                    height: m3Slider.trackHeight

                    property real handlePos: m3Slider.visualPosition * (width - m3Slider.handleWidth)

                    Rectangle {
                        id: leftTrackUni
                        x: 0
                        y: 0
                        width: Math.max(0, parent.handlePos - m3Slider.gap)
                        height: parent.height
                        color: Theme.primary

                        topLeftRadius: Math.min(m3Slider.leftRadiusLarge, width / 2)
                        bottomLeftRadius: Math.min(m3Slider.leftRadiusLarge, width / 2)
                        topRightRadius: Math.min(m3Slider.leftRadiusSmall, width / 2)
                        bottomRightRadius: Math.min(m3Slider.leftRadiusSmall, width / 2)
                    }

                    Rectangle {
                        id: rightTrackUni
                        x: parent.handlePos + m3Slider.handleWidth + m3Slider.gap
                        y: 0
                        width: Math.max(0, parent.width - x)
                        height: parent.height
                        color: (Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest

                        topLeftRadius: Math.min(m3Slider.leftRadiusSmall, width / 2)
                        bottomLeftRadius: Math.min(m3Slider.leftRadiusSmall, width / 2)
                        topRightRadius: Math.min(m3Slider.leftRadiusLarge, width / 2)
                        bottomRightRadius: Math.min(m3Slider.leftRadiusLarge, width / 2)

                        Rectangle {
                            width: m3Slider.dotSize
                            height: m3Slider.dotSize
                            radius: m3Slider.dotSize / 2
                            color: Theme.on_surface_variant
                            anchors.verticalCenter: parent.verticalCenter
                            x: parent.width - m3Slider.leftRadiusLarge - m3Slider.dotSize / 2
                            opacity: !m3Slider.showTicks && rightTrackUni.width > m3Slider.leftRadiusLarge * 2.5 ? 0.6 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                    }

                    Repeater {
                        model: m3Slider.showTicks ? Math.max(0, Math.floor((m3Slider.to - m3Slider.from) / m3Slider.stepSize) + 1) : 0
                        Rectangle {
                            property real tickPos: (m3Slider.handleWidth / 2) + (m3Slider.availableWidth - m3Slider.handleWidth) * (index / Math.max(1, (m3Slider.to - m3Slider.from) / m3Slider.stepSize))
                            x: tickPos - width / 2
                            y: (parent.height - height) / 2
                            width: 4
                            height: 4
                            radius: 2

                            property bool inColoredArea: tickPos <= parent.handlePos + m3Slider.handleWidth / 2
                            color: inColoredArea ? ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest) : ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, Vars.componentOpacity) : Theme.primary)
                        }
                    }
                }
            }

            handle: Rectangle {
                x: m3Slider.leftPadding + m3Slider.visualPosition * (m3Slider.availableWidth - width)
                y: m3Slider.topPadding + (m3Slider.availableHeight - height) / 2
                width: m3Slider.handleWidth
                height: m3Slider.handleHeight
                color: Theme.primary
                radius: width / 2
            }
        }

        Item {
            visible: delegateRoot.itemType === "enum"
            Layout.fillWidth: true
            Layout.minimumWidth: 400
            implicitHeight: enumFlow.implicitHeight

            Flow {
                id: enumFlow
                width: parent.width
                anchors.right: parent.right
                layoutDirection: Qt.RightToLeft
                spacing: 2
                Repeater {
                    id: enumRepeater
                    model: {
                        if (!parent.visible) return [];
                        return delegateRoot.itemEnums.split("|||").reverse();
                    }
                    delegate: Rectangle {
                        property bool isSelected: delegateRoot.itemVal === modelData
                        property var prevItem: index > 0 ? enumRepeater.itemAt(index - 1) : null
                        property var nextItem: index < (enumRepeater.count - 1) ? enumRepeater.itemAt(index + 1) : null
                        property bool isRTL: enumFlow.layoutDirection === Qt.RightToLeft
                        property var visualLeftItem: isRTL ? nextItem : prevItem
                        property var visualRightItem: isRTL ? prevItem : nextItem
                        
                        property bool hasLeft: visualLeftItem && visualLeftItem.y === y
                        property bool hasRight: visualRightItem && visualRightItem.y === y

                        height: 32
                        width: chipText.implicitWidth + 24

                        topLeftRadius: isSelected ? height / 2 : (hasLeft ? 4 : height / 2)
                        bottomLeftRadius: isSelected ? height / 2 : (hasLeft ? 4 : height / 2)
                        topRightRadius: isSelected ? height / 2 : (hasRight ? 4 : height / 2)
                        bottomRightRadius: isSelected ? height / 2 : (hasRight ? 4 : height / 2)

                        Behavior on topLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        Behavior on bottomLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        Behavior on topRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        Behavior on bottomRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

                        scale: chipMouse.pressed ? 1.08 : 1.0
                        Behavior on scale { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.OutBack } }

                        color: isSelected ? ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.8) : Theme.primary) : ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest)

                        Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

                        Text {
                            id: chipText
                            anchors.centerIn: parent
                            text: modelData
                            font.family: Vars.fontFamily
                            font.pixelSize: 13
                            color: isSelected ? Theme.on_primary : Theme.on_surface
                            Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                        }
                        MouseArea {
                            id: chipMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                settingsModel.setProperty(delegateRoot.delegateIndex, "val", modelData);
                                rootPage.updateVariable(delegateRoot.itemKey, modelData, delegateRoot.itemSource);
                            }
                        }
                    }
                }
            }
        }

        Grid {
            visible: delegateRoot.itemType === "shape"
            columns: 6
            spacing: 2
            Repeater {
                id: shapeRepeater
                model: parent.visible ? delegateRoot.itemEnums.split("|||") : []
                delegate: Rectangle {
                    property bool isSelected: delegateRoot.itemVal === modelData

                    property bool hasLeft: index % 6 !== 0
                    property bool hasRight: index % 6 !== 5 && index !== shapeRepeater.count - 1

                    height: 36
                    width: 48

                    topLeftRadius: isSelected ? height / 2 : (hasLeft ? 4 : height / 2)
                    bottomLeftRadius: isSelected ? height / 2 : (hasLeft ? 4 : height / 2)
                    topRightRadius: isSelected ? height / 2 : (hasRight ? 4 : height / 2)
                    bottomRightRadius: isSelected ? height / 2 : (hasRight ? 4 : height / 2)

                    Behavior on topLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                    Behavior on bottomLeftRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                    Behavior on topRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
                    Behavior on bottomRightRadius { NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

                    color: isSelected ? ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, Vars.componentOpacity + 0.3) : Theme.primary) : ((Vars._translucent && !Vars.gameMode) ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, Vars.componentOpacity) : Theme.surface_container_highest)
                    Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

                    Shape {
                        width: 100
                        height: 100
                        anchors.centerIn: parent
                        scale: 0.24
                        layer.enabled: true
                        layer.samples: 8
                        layer.mipmap: true
                        layer.smooth: true
                        antialiasing: true

                        ShapePath {
                            fillColor: isSelected ? Theme.on_primary : Theme.on_surface
                            strokeColor: "transparent"
                            strokeWidth: 0
                            PathSvg {
                                path: m3ShapesObj.getPath(modelData)
                            }
                        }
                    }

                    MouseArea {
                        id: shapeHoverArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            settingsModel.setProperty(delegateRoot.delegateIndex, "val", modelData);
                            rootPage.updateVariable(delegateRoot.itemKey, modelData, delegateRoot.itemSource);
                        }
                    }
                }
            }
        }

        Item {
            visible: delegateRoot.itemType === "color"
            Layout.fillWidth: true
            Layout.minimumWidth: 300
            implicitHeight: colorFlow.implicitHeight

            Flow {
                id: colorFlow
                width: parent.width
                anchors.right: parent.right
                layoutDirection: (delegateRoot.itemEnums.split("|||").length < 5) ? Qt.RightToLeft : Qt.LeftToRight
                spacing: 2
                Repeater {
                    id: colorRepeater
                    model: {
                        if (!parent.visible) return [];
                        let arr = delegateRoot.itemEnums.split("|||");
                        return arr.length < 5 ? arr.reverse() : arr;
                    }
                    delegate: Rectangle {
                        property bool isSelected: delegateRoot.itemVal === modelData
                        height: 32
                        width: 32
                        radius: height / 2
                        border.width: isSelected ? 2 : (modelData === "transparent" ? 1 : 0)
                        border.color: isSelected ? Theme.on_surface : Theme.outline

                        color: {
                            if (modelData === "transparent") return "transparent";
                            if (modelData === "background") return Theme.background;
                            if (modelData === "primary") return Theme.primary;
                            if (modelData === "secondary") return Theme.secondary;
                            if (modelData === "tertiary") return Theme.tertiary;
                            if (modelData === "surface_variant") return Theme.surface_variant;
                            if (modelData === "error") return Theme.error;
                            return "transparent";
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                settingsModel.setProperty(delegateRoot.delegateIndex, "val", modelData);
                                rootPage.updateVariable(delegateRoot.itemKey, modelData, delegateRoot.itemSource);
                            }
                        }
                    }
                }
            }
        }
    }
}
