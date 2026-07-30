pragma Singleton
import QtQuick
import "variables.js" as Vars

QtObject {
    function withAlpha(hexString, alpha) {
        let col = Qt.color(hexString);
        return Qt.rgba(col.r, col.g, col.b, alpha);
    }
	
		readonly property color background: "#12140e"
	
		readonly property color error: "#ffb4ab"
	
		readonly property color error_container: "#93000a"
	
		readonly property color inverse_on_surface: "#2f312a"
	
		readonly property color inverse_primary: "#4f6629"
	
		readonly property color inverse_surface: "#e3e3d8"
	
		readonly property color on_background: "#e3e3d8"
	
		readonly property color on_error: "#690005"
	
		readonly property color on_error_container: "#ffdad6"
	
		readonly property color on_primary: "#233600"
	
		readonly property color on_primary_container: "#d1eca0"
	
		readonly property color on_primary_fixed: "#121f00"
	
		readonly property color on_primary_fixed_variant: "#384d13"
	
		readonly property color on_secondary: "#2b331d"
	
		readonly property color on_secondary_container: "#dde6c6"
	
		readonly property color on_secondary_fixed: "#171e0a"
	
		readonly property color on_secondary_fixed_variant: "#414a32"
	
		readonly property color on_surface: "#e3e3d8"
	
		readonly property color on_surface_variant: "#c5c8b9"
	
		readonly property color on_tertiary: "#013733"
	
		readonly property color on_tertiary_container: "#bcece5"
	
		readonly property color on_tertiary_fixed: "#00201d"
	
		readonly property color on_tertiary_fixed_variant: "#1f4e4a"
	
		readonly property color outline: "#8f9285"
	
		readonly property color outline_variant: "#45483d"
	
		readonly property color primary: "#b5d087"
	
		readonly property color primary_container: "#384d13"
	
		readonly property color primary_fixed: "#d1eca0"
	
		readonly property color primary_fixed_dim: "#b5d087"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#c1caab"
	
		readonly property color secondary_container: "#414a32"
	
		readonly property color secondary_fixed: "#dde6c6"
	
		readonly property color secondary_fixed_dim: "#c1caab"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#6c9425"
	
		readonly property color surface: "#12140e"
	
		readonly property color surface_bright: "#383a32"
	
		readonly property color surface_container: "#1e2019"
	
		readonly property color surface_container_high: "#292b23"
	
		readonly property color surface_container_highest: "#33362e"
	
		readonly property color surface_container_low: "#1a1c15"
	
		readonly property color surface_container_lowest: "#0d0f09"
	
		readonly property color surface_dim: "#12140e"
	
		readonly property color surface_tint: "#b5d087"
	
		readonly property color surface_variant: "#45483d"
	
		readonly property color tertiary: "#a0d0c9"
	
		readonly property color tertiary_container: "#1f4e4a"
	
		readonly property color tertiary_fixed: "#bcece5"
	
		readonly property color tertiary_fixed_dim: "#a0d0c9"
	
}