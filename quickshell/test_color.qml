import QtQuick
import Quickshell
import "theme"

ShellRoot {
    Component.onCompleted: {
        var c = Theme.surface_container_high;
        console.log("Color:", c);
        console.log("R:", c.r);
        console.log("RGBA:", Qt.rgba(c.r, c.g, c.b, 0.5));
        Qt.quit();
    }
}
