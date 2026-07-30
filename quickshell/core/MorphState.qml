pragma Singleton
import QtQuick

QtObject {
    property real targetWidth: 100
    property real targetHeight: 40
    property int openCount: 0
    property bool anyExpanded: openCount > 0

    function notifyOpened(w, h) {
        targetWidth = w;
        targetHeight = h;
        openCount++;
    }

    function notifyClosed() {
        openCount = Math.max(0, openCount - 1);
    }
}
