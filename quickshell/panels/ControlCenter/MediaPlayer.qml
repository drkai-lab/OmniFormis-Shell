import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "../../theme/variables.js" as Vars
import "../.."
import QtQuick.Effects
import QtQuick.Shapes

Rectangle {
    id: mediaPlayerRoot

    FontLoader {
        id: filledIconFont
        source: "../../theme/assets/MaterialSymbolsRounded-Filled.ttf"
    }

    property var preferredMprisPlayer: null
    property var mprisPlayer: {
        let vals = Mpris.players.values;
        if (vals.length === 0)
            return null;
        if (preferredMprisPlayer && vals.indexOf(preferredMprisPlayer) !== -1) {
            return preferredMprisPlayer;
        }
        return vals[0];
    }
    property bool isPlaying: mprisPlayer ? mprisPlayer.isPlaying : false

    property string currentMediaPlayerShape: Vars.mediaPlayerShape !== undefined ? Vars.mediaPlayerShape : "12SidedCookie"
    property real currentMediaPlayerArtScale: Vars.mediaPlayerArtScale !== undefined ? Vars.mediaPlayerArtScale : 1.0

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            var shape = Vars.mediaPlayerShape !== undefined ? Vars.mediaPlayerShape : "12SidedCookie";
            if (mediaPlayerRoot.currentMediaPlayerShape !== shape) {
                mediaPlayerRoot.currentMediaPlayerShape = shape;
            }
            var scale = Vars.mediaPlayerArtScale !== undefined ? Vars.mediaPlayerArtScale : 1.0;
            if (mediaPlayerRoot.currentMediaPlayerArtScale !== scale) {
                mediaPlayerRoot.currentMediaPlayerArtScale = scale;
            }
        }
    }

    Layout.fillWidth: true
    Layout.preferredHeight: 180
    radius: 16
    color: "transparent"

    Rectangle {
        id: rootMask
        anchors.fill: parent
        radius: 16
        color: Theme.surface
        layer.enabled: true
        layer.samples: 4
        visible: false
    }

    // Background Image
    Image {
        id: bgArt
        anchors.fill: parent
        source: mprisPlayer && mprisPlayer.trackArtUrl ? mprisPlayer.trackArtUrl : ""
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    Item {
        id: combinedBackground
        anchors.fill: parent
        layer.enabled: true
        visible: false

        // Stage 1: Blur the background image
        Item {
            id: blurredBgLayer
            anchors.fill: parent
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: Vars.blurAmount
                blur: 1.0
                saturation: 1.2
                autoPaddingEnabled: false
            }
            visible: bgArt.source !== ""

            Image {
                anchors.fill: parent
                source: bgArt.source
                fillMode: Image.PreserveAspectCrop
            }
        }

        // Translucent overlay
        Rectangle {
            anchors.fill: parent
            color: Theme.surface_container_highest
            opacity: bgArt.source !== "" ? (Vars.translucent ? 0.75 : 0.90) : 1.0
        }
    }

    // Stage 2: Mask the combined background to perfectly fit the rounded corners
    Item {
        anchors.fill: parent
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: !Vars.gameMode
            shadowBlur: 1.0
            shadowColor: Qt.rgba(0, 0, 0, 0.25)
            shadowVerticalOffset: 4
            shadowHorizontalOffset: 0
        }

        MultiEffect {
            anchors.fill: parent
            source: combinedBackground
            maskEnabled: true
            maskSource: rootMask
        }
    }

    property int slideDirection: 1

    property real timeScale: mprisPlayer && mprisPlayer.length > 10000000 ? 1000000 : (mprisPlayer && mprisPlayer.length > 10000 ? 1000 : 1)

    function formatTime(val) {
        if (isNaN(val) || val <= 0)
            return "0:00";
        let totalSeconds = Math.floor(val / timeScale);
        let mins = Math.floor(totalSeconds / 60);
        let secs = Math.floor(totalSeconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    Timer {
        interval: 1000
        repeat: true
        running: mprisPlayer && mprisPlayer.isPlaying
        onTriggered: {
            if (mprisPlayer && typeof mprisPlayer.positionChanged === "function") {
                mprisPlayer.positionChanged();
            }
        }
    }

    Item {
        id: contentLayer
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: rootMask
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            // Left: Album Art
            Item {
                id: albumArtContainer
                width: 148
                height: 148
                scale: mediaPlayerRoot.currentMediaPlayerArtScale
                Behavior on scale {
                    NumberAnimation {
                        duration: Vars.animationDuration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Vars.customStandard
                    }
                }

            M3Shapes {
                id: m3
            }

            Item {
                id: maskContainer
                anchors.fill: parent
                visible: false
                layer.enabled: true
                layer.samples: 4

                Item {
                    id: rotationWrapper
                    anchors.centerIn: parent
                    property real scaleFactor: Math.min(4, 4096 / Math.max(parent.width, parent.height, 1))
                    width: parent.width * scaleFactor
                    height: parent.height * scaleFactor
                    scale: 1.0 / scaleFactor

                    RotationAnimation {
                        target: rotationWrapper
                        property: "rotation"
                        from: 0
                        to: 360
                        duration: 10000
                        loops: Animation.Infinite
                        running: mprisPlayer && mprisPlayer.isPlaying
                    }

                    Image {
                        id: maskImage
                        anchors.fill: parent
                        sourceSize.width: width
                        sourceSize.height: height
                        
                        property string currentPathName: mediaPlayerRoot.currentMediaPlayerShape
                        property string currentPath: m3.getPath(currentPathName)

                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><path d='" + currentPath + "' fill='white'/></svg>"
                        smooth: true
                        antialiasing: true
                        mipmap: true

                        onCurrentPathNameChanged: {
                            if (maskImage.status === Image.Ready) {
                                shapeAnim.restart();
                            }
                        }

                        SequentialAnimation {
                            id: shapeAnim
                            NumberAnimation {
                                target: maskImage
                                property: "scale"
                                to: 0.01
                                duration: 250
                                easing.type: Easing.InBack
                            }
                            NumberAnimation {
                                target: maskImage
                                property: "scale"
                                to: 1.0
                                duration: 550
                                easing.type: Easing.OutElastic
                            }
                        }
                    }
                }
            }

            Item {
                id: albumContent
                anchors.fill: parent
                visible: false

                // Fallback icon
                Rectangle {
                    anchors.fill: parent
                    color: Theme.surface_container
                    visible: !mprisPlayer || !mprisPlayer.trackArtUrl

                    Text {
                        anchors.centerIn: parent
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 48
                        antialiasing: true
                        renderType: Text.QtRendering
                        font.hintingPreference: Font.PreferNoHinting
                        color: Theme.on_surface_variant
                        text: "\ue405"
                    }
                }

                Image {
                    id: albumImage
                    anchors.fill: parent
                    source: mprisPlayer && mprisPlayer.trackArtUrl ? mprisPlayer.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: albumImage.source !== ""
                    antialiasing: true
                    smooth: true
                    mipmap: true
                }
            }

            MultiEffect {
                source: albumContent
                anchors.fill: parent
                maskEnabled: true
                maskSource: maskContainer
                antialiasing: true
                smooth: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskThresholdMax: 1.0
            }

        }

        // Right: Metadata and Controls
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Top section: Titles and Play Button
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Metadata Column
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Layout.alignment: Qt.AlignTop

                    Text {
                        text: mprisPlayer ? (mprisPlayer.trackTitle || (mprisPlayer.metadata ? mprisPlayer.metadata["xesam:title"] : null) || mprisPlayer.identity || "Unknown Title") : "No Media Playing"
                        font.family: Vars.fontFamily
                        font.pixelSize: 18
                        font.weight: 700
                        color: Theme.on_surface
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: mprisPlayer && mprisPlayer.trackArtist ? mprisPlayer.trackArtist : "Artist"
                        font.family: Vars.fontFamily
                        font.pixelSize: 14
                        color: Theme.on_surface_variant
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.preferredHeight: 4
                    } // Spacer

                    Text {
                        text: formatTime(mprisPlayer ? mprisPlayer.position : 0) + " / " + formatTime(mprisPlayer ? mprisPlayer.length : 0)
                        font.family: Vars.fontFamily
                        font.pixelSize: 13
                        color: Theme.on_surface_variant
                    }
                }

                // Player Selector and Play/Pause Button
                RowLayout {
                    Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                    spacing: 12 // Reverted spacing

                    // Player Selector Pill
                    Rectangle {
                        id: playerSelectorPill
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: playerSelectorRow.implicitWidth + 16 // Less padding
                        Layout.preferredHeight: 28 // Smaller height
                        Layout.minimumWidth: Layout.preferredWidth
                        radius: 14 // Scaled radius
                        color: Qt.rgba(Theme.on_surface_variant.r, Theme.on_surface_variant.g, Theme.on_surface_variant.b, 0.15)
                        visible: Mpris.players.values.length > 1

                        RowLayout {
                            id: playerSelectorRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text {
                                text: mprisPlayer ? (mprisPlayer.identity || "Unknown") : "Player"
                                font.family: Vars.fontFamily
                                font.pixelSize: 12 // Slightly smaller text
                                color: Theme.on_surface_variant
                                font.weight: 500
                            }
                            Text {
                                font.family: "Material Symbols Rounded"
                                font.pixelSize: 16 // Slightly smaller icon
                                antialiasing: true
                                renderType: Text.QtRendering
                                font.hintingPreference: Font.PreferNoHinting
                                color: Theme.on_surface_variant
                                font.weight: 700
                                text: "\ue5cf" // expand_more
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: playerDropdown.visible = !playerDropdown.visible
                        }
                    }

                    // Play/Pause Button
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 52
                        Layout.preferredHeight: 52
                        Layout.minimumWidth: 52
                        radius: 18
                        color: Theme.primary

                        Text {
                            anchors.centerIn: parent
                            font.family: filledIconFont.name
                            font.pixelSize: 28
                            antialiasing: true
                            renderType: Text.QtRendering
                            font.hintingPreference: Font.PreferNoHinting
                            color: Theme.on_primary
                            text: mprisPlayer && mprisPlayer.isPlaying ? "\ue034" : "\ue037" // pause : play_arrow
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (mprisPlayer) {
                                if (typeof mprisPlayer.togglePlaying === "function")
                                    mprisPlayer.togglePlaying();
                                else if (typeof mprisPlayer.playPause === "function")
                                    mprisPlayer.playPause();
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            } // pushes bottom controls down

            // Bottom Section: Progress and Prev/Next
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Layout.alignment: Qt.AlignBottom

                // Previous
                Text {
                    font.family: filledIconFont.name
                    font.pixelSize: 26
                    antialiasing: true
                    renderType: Text.QtRendering
                    font.hintingPreference: Font.PreferNoHinting
                    color: Theme.on_surface_variant
                    text: "\ue045" // skip_previous
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            mediaPlayerRoot.slideDirection = -1;
                            if (mprisPlayer)
                                mprisPlayer.previous();
                        }
                    }
                }

                // Progress Bar Container
                Item {
                    id: progressContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24

                    property bool isDragging: false
                    property real dragRatio: 0
                    property real playRatio: {
                        if (isDragging)
                            return dragRatio;
                        return mprisPlayer && mprisPlayer.length > 0 && mprisPlayer.position !== undefined ? Math.max(0, Math.min(1, mprisPlayer.position / mprisPlayer.length)) : 0;
                    }

                    // Vertical handle (the `|` in the image)
                    Rectangle {
                        id: handle
                        anchors.verticalCenter: parent.verticalCenter
                        x: progressContainer.playRatio * (parent.width - width)
                        width: 4
                        height: 30
                        radius: 5
                        color: Theme.on_surface
                    }

                    // Squiggly played track
                    Canvas {
                        id: squigglyCanvas
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        width: Math.max(0, handle.x - 6)
                        height: 12

                        property color waveColor: Theme.primary
                        property real phase: 0

                        NumberAnimation on phase {
                            from: 0
                            to: Math.PI * 2
                            duration: 1500
                            loops: Animation.Infinite
                            running: mprisPlayer && mprisPlayer.isPlaying
                        }

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            if (width <= 0)
                                return;
                            ctx.beginPath();
                            var amplitude = 3;
                            var frequency = 0.25;
                            ctx.lineWidth = 4;
                            ctx.lineCap = "round";
                            ctx.lineJoin = "round";
                            ctx.strokeStyle = waveColor;

                            for (var x = 0; x <= width; x++) {
                                var y = height / 2 + Math.sin(x * frequency - phase) * amplitude;
                                if (x === 0)
                                    ctx.moveTo(x, y);
                                else
                                    ctx.lineTo(x, y);
                            }
                            ctx.stroke();
                        }

                        onWidthChanged: requestPaint()
                        onWaveColorChanged: requestPaint()
                        onPhaseChanged: requestPaint()
                    }

                    // Unplayed track
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: handle.right
                        anchors.leftMargin: 6
                        anchors.right: parent.right
                        height: 4
                        radius: 2
                        color: Qt.rgba(Theme.on_surface_variant.r, Theme.on_surface_variant.g, Theme.on_surface_variant.b, 0.3)

                        // Unplayed part dot (from the image)
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            width: 4
                            height: 4
                            radius: 2
                            color: Qt.rgba(Theme.on_surface_variant.r, Theme.on_surface_variant.g, Theme.on_surface_variant.b, 0.6)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onPressed: mouse => {
                            progressContainer.isDragging = true;
                            progressContainer.dragRatio = Math.max(0, Math.min(1, mouse.x / width));
                        }

                        onPositionChanged: mouse => {
                            if (pressed) {
                                progressContainer.dragRatio = Math.max(0, Math.min(1, mouse.x / width));
                            }
                        }

                        onReleased: mouse => {
                            if (progressContainer.isDragging) {
                                progressContainer.dragRatio = Math.max(0, Math.min(1, mouse.x / width));
                                progressContainer.isDragging = false;
                                if (mprisPlayer && mprisPlayer.length > 0 && mprisPlayer.canSeek) {
                                    mprisPlayer.position = progressContainer.dragRatio * mprisPlayer.length;
                                }
                            }
                        }
                    }
                }

                // Next
                Text {
                    font.family: filledIconFont.name
                    font.pixelSize: 26
                    antialiasing: true
                    renderType: Text.QtRendering
                    font.hintingPreference: Font.PreferNoHinting
                    color: Theme.on_surface_variant
                    text: "\ue044" // skip_next
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            mediaPlayerRoot.slideDirection = 1;
                            if (mprisPlayer)
                                mprisPlayer.next();
                        }
                    }
                }
            }
        }
    }
    } // end of contentLayer

    // MPRIS Player Dropdown
    Item {
        id: playerDropdown
        x: {
            if (typeof playerSelectorPill !== 'undefined' && playerSelectorPill !== null) {
                var p = playerSelectorPill.mapToItem(mediaPlayerRoot, 0, 0);
                return p.x - (width - playerSelectorPill.width) - 12; // Aligned just left of the play button's bounds
            }
            return parent.width - width - Vars.spacingMedium - 64;
        }
        y: {
            if (typeof playerSelectorPill !== 'undefined' && playerSelectorPill !== null) {
                var p = playerSelectorPill.mapToItem(mediaPlayerRoot, 0, 0);
                return p.y + playerSelectorPill.height + 8;
            }
            return Vars.spacingMedium + 32;
        }
        width: 180
        height: playerColumn.implicitHeight + 8
        property real radius: Vars.radiusMedium
        visible: false
        z: 10

        Rectangle {
            id: dropdownMask
            anchors.fill: parent
            radius: playerDropdown.radius
            color: "black"
            visible: false
            layer.enabled: true
            layer.samples: 4
        }

        Item {
            id: dropdownShadow
            anchors.fill: parent
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 1.0
                shadowColor: Qt.rgba(0,0,0,0.25)
                shadowVerticalOffset: 4
                shadowHorizontalOffset: 0
            }

            Item {
                id: dropdownFinalMasked
                anchors.fill: parent
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: dropdownMask
                }

                ShaderEffectSource {
                    anchors.fill: parent
                    sourceItem: mediaPlayerRoot
                    sourceRect: Qt.rect(playerDropdown.x, playerDropdown.y, playerDropdown.width, playerDropdown.height)
                    
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blurMax: Vars.blurAmount
                        blur: 1.0
                        autoPaddingEnabled: false
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: playerDropdown.radius
                    color: Vars.translucent ? Qt.rgba(Theme.surface_container_highest.r, Theme.surface_container_highest.g, Theme.surface_container_highest.b, 0.6) : Theme.surface_container_highest
                    border.color: Theme.outline_variant
                    border.width: 1
                }

            } // End of dropdownFinalMasked
        } // End of dropdownShadow

        Column {
            id: playerColumn
            anchors.fill: parent
            anchors.margins: 4

            Repeater {
                model: Mpris.players.values
                delegate: Rectangle {
                    width: playerColumn.width
                    height: 36
                    radius: Vars.radiusSmall
                    color: itemMouse.containsMouse ? Qt.rgba(Theme.on_surface.r, Theme.on_surface.g, Theme.on_surface.b, 0.08) : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        Text {
                            text: modelData.identity || "Unknown"
                            font.family: Vars.fontFamily
                            font.pixelSize: 14
                            color: mprisPlayer === modelData ? Theme.primary : Theme.on_surface
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 18
                            antialiasing: true
                            renderType: Text.QtRendering
                            font.hintingPreference: Font.PreferNoHinting
                            color: Theme.primary
                            text: "\ue876" // check
                            visible: mprisPlayer === modelData
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            mediaPlayerRoot.preferredMprisPlayer = modelData;
                            playerDropdown.visible = false;
                        }
                    }
                }
            }
        }
    }

    // Root masks have been replaced with MultiEffect source masking and Rectangle radius
}
