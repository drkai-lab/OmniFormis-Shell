import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
    IdleMonitor {
        id: monitor
        Component.onCompleted: {
            for (var prop in monitor) {
                console.log(prop);
            }
            Qt.quit();
        }
    }
}
