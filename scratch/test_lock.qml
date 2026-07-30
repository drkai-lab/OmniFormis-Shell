import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
    WlSessionLock {
        id: sessionLock
        Component.onCompleted: {
            console.log("PROPERTIES:");
            for (var prop in sessionLock) {
                console.log(prop + " : " + typeof(sessionLock[prop]));
            }
            Qt.quit();
        }
    }
}
