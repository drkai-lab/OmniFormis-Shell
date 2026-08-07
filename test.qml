import QtQuick
import Quickshell
import "quickshell/theme/variables.js" as Vars

PanelWindow {
    visible: true
    width: 200
    height: 200
    color: "white"
    Text {
        text: "Translucent: " + Vars.translucent + "\nLiquidGlass: " + Vars.liquidGlass
    }
}
