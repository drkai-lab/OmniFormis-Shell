pragma Singleton
import QtQuick
import "variables.js" as Vars

QtObject {
    function withAlpha(hexString, alpha) {
        let col = Qt.color(hexString);
        return Qt.rgba(col.r, col.g, col.b, alpha);
    }
	
		readonly property color background: "#fbf8ff"
	
		readonly property color error: "#ba1a1a"
	
		readonly property color error_container: "#ffdad6"
	
		readonly property color inverse_on_surface: "#f1effc"
	
		readonly property color inverse_primary: "#bcc2ff"
	
		readonly property color inverse_surface: "#2f3039"
	
		readonly property color on_background: "#1a1b23"
	
		readonly property color on_error: "#ffffff"
	
		readonly property color on_error_container: "#410002"
	
		readonly property color on_primary: "#ffffff"
	
		readonly property color on_primary_container: "#d2d5ff"
	
		readonly property color on_primary_fixed: "#000c61"
	
		readonly property color on_primary_fixed_variant: "#172fc4"
	
		readonly property color on_secondary: "#ffffff"
	
		readonly property color on_secondary_container: "#252d66"
	
		readonly property color on_secondary_fixed: "#0b144e"
	
		readonly property color on_secondary_fixed_variant: "#3a427c"
	
		readonly property color on_surface: "#1a1b23"
	
		readonly property color on_surface_variant: "#454655"
	
		readonly property color on_tertiary: "#ffffff"
	
		readonly property color on_tertiary_container: "#f9c8ff"
	
		readonly property color on_tertiary_fixed: "#340042"
	
		readonly property color on_tertiary_fixed_variant: "#770c91"
	
		readonly property color outline: "#757686"
	
		readonly property color outline_variant: "#c5c5d7"
	
		readonly property color primary: "#00168d"
	
		readonly property color primary_container: "#0d28c0"
	
		readonly property color primary_fixed: "#dfe0ff"
	
		readonly property color primary_fixed_dim: "#bcc2ff"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#525a95"
	
		readonly property color secondary_container: "#b5bcff"
	
		readonly property color secondary_fixed: "#dfe0ff"
	
		readonly property color secondary_fixed_dim: "#bcc2ff"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#0d28c0"
	
		readonly property color surface: "#fbf8ff"
	
		readonly property color surface_bright: "#fbf8ff"
	
		readonly property color surface_container: "#eeecf9"
	
		readonly property color surface_container_high: "#e9e7f3"
	
		readonly property color surface_container_highest: "#e3e1ed"
	
		readonly property color surface_container_low: "#f4f2fe"
	
		readonly property color surface_container_lowest: "#ffffff"
	
		readonly property color surface_dim: "#dad9e5"
	
		readonly property color surface_tint: "#384cdc"
	
		readonly property color surface_variant: "#e1e1f4"
	
		readonly property color tertiary: "#4e0061"
	
		readonly property color tertiary_container: "#71008c"
	
		readonly property color tertiary_fixed: "#fdd6ff"
	
		readonly property color tertiary_fixed_dim: "#f3aeff"
	
}