import QtQuick
import "./theme"
Item {
    Component.onCompleted: {
        console.log("radiusSmall:", Vars.radiusSmall);
        Qt.quit();
    }
}
