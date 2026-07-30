pragma Singleton
import QtQuick
import "variables.js" as Vars

QtObject {
    function withAlpha(hexString, alpha) {
        let col = Qt.color(hexString);
        return Qt.rgba(col.r, col.g, col.b, alpha);
    }
	
		readonly property color background: "#fafaee"
	
		readonly property color error: "#ba1a1a"
	
		readonly property color error_container: "#ffdad6"
	
		readonly property color inverse_on_surface: "#f1f2e6"
	
		readonly property color inverse_primary: "#b5d087"
	
		readonly property color inverse_surface: "#2f312a"
	
		readonly property color on_background: "#1a1c15"
	
		readonly property color on_error: "#ffffff"
	
		readonly property color on_error_container: "#410002"
	
		readonly property color on_primary: "#ffffff"
	
		readonly property color on_primary_container: "#121f00"
	
		readonly property color on_primary_fixed: "#121f00"
	
		readonly property color on_primary_fixed_variant: "#384d13"
	
		readonly property color on_secondary: "#ffffff"
	
		readonly property color on_secondary_container: "#171e0a"
	
		readonly property color on_secondary_fixed: "#171e0a"
	
		readonly property color on_secondary_fixed_variant: "#414a32"
	
		readonly property color on_surface: "#1a1c15"
	
		readonly property color on_surface_variant: "#45483d"
	
		readonly property color on_tertiary: "#ffffff"
	
		readonly property color on_tertiary_container: "#00201d"
	
		readonly property color on_tertiary_fixed: "#00201d"
	
		readonly property color on_tertiary_fixed_variant: "#1f4e4a"
	
		readonly property color outline: "#75786c"
	
		readonly property color outline_variant: "#c5c8b9"
	
		readonly property color primary: "#4f6629"
	
		readonly property color primary_container: "#d1eca0"
	
		readonly property color primary_fixed: "#d1eca0"
	
		readonly property color primary_fixed_dim: "#b5d087"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#596248"
	
		readonly property color secondary_container: "#dde6c6"
	
		readonly property color secondary_fixed: "#dde6c6"
	
		readonly property color secondary_fixed_dim: "#c1caab"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#6c9425"
	
		readonly property color surface: "#fafaee"
	
		readonly property color surface_bright: "#fafaee"
	
		readonly property color surface_container: "#eeefe3"
	
		readonly property color surface_container_high: "#e8e9dd"
	
		readonly property color surface_container_highest: "#e3e3d8"
	
		readonly property color surface_container_low: "#f4f4e9"
	
		readonly property color surface_container_lowest: "#ffffff"
	
		readonly property color surface_dim: "#dadbcf"
	
		readonly property color surface_tint: "#4f6629"
	
		readonly property color surface_variant: "#e2e4d4"
	
		readonly property color tertiary: "#396661"
	
		readonly property color tertiary_container: "#bcece5"
	
		readonly property color tertiary_fixed: "#bcece5"
	
		readonly property color tertiary_fixed_dim: "#a0d0c9"
	
}