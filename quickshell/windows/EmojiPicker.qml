import QtQuick
import QtQuick.Effects
import ".."
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../theme/variables.js" as Vars

Item {
    id: root
    
    Layout.preferredWidth: 100
    Layout.preferredHeight: 40
    
    property bool expanded: false
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
    property alias panel: panel
    property alias panelMask: panelMask

    signal emojiSelected()

    property var emojiModel: []

    Process {
        id: emojiFetcher
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/scripts/emojis.txt"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.length > 0) {
                    var lines = this.text.split("\n");
                    var arr = [];
                    for (var i = 0; i < lines.length; i++) {
                        var line = lines[i].trim();
                        if (line.length > 0) {
                            var firstSpace = line.indexOf(" ");
                            var charVal = line;
                            var nameVal = line;
                            if (firstSpace !== -1) {
                                charVal = line.substring(0, firstSpace);
                                nameVal = line.substring(firstSpace + 1).trim();
                            }
                            
                            arr.push({
                                char: charVal,
                                name: nameVal
                            });
                        }
                    }
                    root.emojiModel = arr;
                }
            }
        }
    }

    Component.onCompleted: {
        emojiFetcher.running = true;
    }

    property bool vimKeysEnabled: false
    Process {
        id: vimKeysChecker
        command: ["bash", "-c", "grep -qi 'vimkeys[ \t]*=[ \t]*true' /home/boing/Dotfiles/hypr/modules/variables.lua && echo 'true' || echo 'false'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.vimKeysEnabled = (this.text.trim() === 'true');
            }
        }
    }

    property var filteredModel: {
        var filterText = searchInput.text.toLowerCase().trim();
        if (filterText === "") return root.emojiModel;
        
        return root.emojiModel.filter(item => Vars.fuzzyMatch(filterText, item.name));
    }

    HyprlandFocusGrab {
        active: root.expanded && root.focusWindow !== null
        windows: root.focusWindow ? [root.focusWindow] : []
    }
    
    onExpandedChanged: {
        if (!expanded) {
            searchInput.text = "";
        } else {
            searchInput.forceActiveFocus();
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
        
        width: root.expanded ? 500 : 100
        height: root.expanded ? 450 : 40
        
        opacity: root.expanded || panel.width > 105 ? 1.0 : 0.0
        visible: opacity > 0
        
        color: Theme.surface_container_high
        property real targetRad: root.expanded ? Vars.radiusExtraLarge : height / 2
        topLeftRadius: Vars.getTopLeftRadius(Vars.panelStyle, Vars.pillPosition, root.gameMode, targetRad)
        topRightRadius: Vars.getTopRightRadius(Vars.panelStyle, Vars.pillPosition, root.gameMode, targetRad)
        bottomLeftRadius: Vars.getBottomLeftRadius(Vars.panelStyle, Vars.pillPosition, root.gameMode, targetRad)
        bottomRightRadius: Vars.getBottomRightRadius(Vars.panelStyle, Vars.pillPosition, root.gameMode, targetRad)
        // clip removed for shadow

        Behavior on radius { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on width { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }
        Behavior on height { enabled: !root.gameMode; NumberAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customExpressiveSpatialSlow } }

        Item {
            anchors.fill: parent
            anchors.margins: Vars.spacingLarge
            
            opacity: root.expanded ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity { enabled: !root.gameMode; SequentialAnimation { PauseAnimation { duration: root.expanded ? Vars.animationDuration : 0 } NumberAnimation { duration: root.expanded ? Vars.animationDuration : Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: root.expanded ? Vars.customEmphasizedDecelerate : Vars.customEmphasizedAccelerate } } }

            ColumnLayout {
                id: mainLayout
                anchors.fill: parent
                spacing: Vars.spacingMedium

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Vars.spacingMedium
                    
                    Rectangle {
                        width: 40; height: 40; radius: Vars.radiusMedium
                        color: backHover.pressed ? Qt.rgba(Theme.on_primary.r, Theme.on_primary.g, Theme.on_primary.b, 0.12) : (backHover.containsMouse ? Qt.rgba(Theme.on_primary.r, Theme.on_primary.g, Theme.on_primary.b, 0.08) : "transparent")
                        Text { anchors.centerIn: parent; font.family: "Material Symbols Outlined"; font.pixelSize: 20; color: Theme.on_primary; text: "\ue5cd" }
                        MouseArea { id: backHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.expanded = false }
                        Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                    }
                    Text { text: "Emoji Picker"; font.family: Vars.fontFamily; font.pixelSize: 20; font.weight: 600; color: Theme.on_primary }
                }

                Rectangle {
                    id: searchBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: searchInput.activeFocus ? "transparent" : Qt.rgba(Theme.on_primary.r, Theme.on_primary.g, Theme.on_primary.b, 0.08)
                    radius: Vars.radiusMedium

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Vars.spacingMedium
                        anchors.rightMargin: Vars.spacingMedium

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            font.family: Vars.fontFamily
                            font.pixelSize: 14
                            color: Theme.on_primary
                            focus: root.expanded
                            selectByMouse: true

                            Text {
                                text: "Search emojis..."
                                font.family: Vars.fontFamily
                                font.pixelSize: 14
                                color: Theme.on_primary
                                opacity: 0.6
                                visible: !searchInput.text && !searchInput.activeFocus
                            }

                            Keys.onDownPressed: (event) => {
                                if (emojiGridView.count > 0 && emojiGridView.currentIndex === -1) {
                                    emojiGridView.currentIndex = 0;
                                }
                                emojiGridView.forceActiveFocus();
                                event.accepted = true;
                            }
                            Keys.onEscapePressed: (event) => {
                                root.expanded = false;
                                event.accepted = true;
                            }
                        }

                        Text {
                            text: "✕"
                            font.pixelSize: 14
                            color: Theme.on_primary
                            visible: searchInput.text.length > 0
                            Layout.alignment: Qt.AlignVCenter
                            MouseArea {
                                anchors.fill: parent
                                onClicked: searchInput.text = ""
                            }
                        }
                    }
                }

                GridView {
                    id: emojiGridView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    cellWidth: 55
                    cellHeight: 55
                    
                    model: root.filteredModel
                    
                    focus: true
                    keyNavigationEnabled: true
                    highlightFollowsCurrentItem: false
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
                    
                    Keys.onReturnPressed: (event) => { if (currentItem) currentItem.triggerSelection(); event.accepted = true; }
                    Keys.onSpacePressed: (event) => { if (currentItem) currentItem.triggerSelection(); event.accepted = true; }
                    Keys.onEscapePressed: (event) => { root.expanded = false; event.accepted = true; }
                    
                    Keys.onUpPressed: (event) => {
                        if (currentIndex < Math.floor(width / cellWidth)) {
                            searchInput.forceActiveFocus();
                        } else {
                            moveCurrentIndexUp();
                        }
                        event.accepted = true;
                    }
                    
                    Keys.onPressed: (event) => {
                        if (root.vimKeysEnabled) {
                            if (event.key === Qt.Key_H) {
                                moveCurrentIndexLeft();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_L) {
                                moveCurrentIndexRight();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_K) {
                                if (currentIndex < Math.floor(width / cellWidth)) {
                                    searchInput.forceActiveFocus();
                                } else {
                                    moveCurrentIndexUp();
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_J) {
                                moveCurrentIndexDown();
                                event.accepted = true;
                            }
                        }
                    }
                    
                    onModelChanged: {
                        if (count > 0 && currentIndex === -1) {
                            currentIndex = 0;
                        }
                    }

                    delegate: Item {
                        id: delegateItem
                        width: emojiGridView.cellWidth
                        height: emojiGridView.cellHeight

                        function triggerSelection() {
                            Quickshell.execDetached({
                                command: ["wl-copy", modelData.char]
                            });
                            root.emojiSelected();
                            root.expanded = false;
                        }

                        property bool isCurrent: delegateItem.GridView.isCurrentItem && emojiGridView.activeFocus
                        
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            color: itemMouseArea.containsMouse || isCurrent ? Qt.rgba(Theme.on_primary.r, Theme.on_primary.g, Theme.on_primary.b, 0.08) : "transparent"
                            radius: Vars.radiusMedium
                            border.color: isCurrent ? Theme.on_primary : "transparent"
                            border.width: isCurrent ? 2 : 0

                            Behavior on color { ColorAnimation { duration: Vars.animationDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Vars.customStandard } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.char
                                font.pixelSize: 26
                                
                                ToolTip.text: modelData.name
                                ToolTip.visible: itemMouseArea.containsMouse
                                ToolTip.delay: 500
                            }
                        }

                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: {
                                emojiGridView.currentIndex = index;
                            }

                            onClicked: {
                                emojiGridView.currentIndex = index;
                                delegateItem.triggerSelection();
                            }
                        }
                    }
                    
                    ScrollBar.vertical: ScrollBar {}
                }
            }
        }
    }
}
