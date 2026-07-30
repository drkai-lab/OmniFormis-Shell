import QtQuick
import "./theme/variables.js" as Vars
Item {
    Component.onCompleted: {
        console.log("radiusSmall:", Vars.radiusSmall);
        Qt.quit();
    }
}
