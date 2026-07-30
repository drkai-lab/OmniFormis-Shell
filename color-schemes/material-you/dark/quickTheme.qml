pragma Singleton
import QtQuick
import "variables.js" as Vars

QtObject {
    function withAlpha(hexString, alpha) {
        let col = Qt.color(hexString);
        return Qt.rgba(col.r, col.g, col.b, alpha);
    }
	
		readonly property color background: "#111318"
	
		readonly property color error: "#ffb4ab"
	
		readonly property color error_container: "#93000a"
	
		readonly property color inverse_on_surface: "#2e3035"
	
		readonly property color inverse_primary: "#3f5f90"
	
		readonly property color inverse_surface: "#e1e2e9"
	
		readonly property color on_background: "#e1e2e9"
	
		readonly property color on_error: "#690005"
	
		readonly property color on_error_container: "#ffdad6"
	
		readonly property color on_primary: "#06305f"
	
		readonly property color on_primary_container: "#d6e3ff"
	
		readonly property color on_primary_fixed: "#001b3c"
	
		readonly property color on_primary_fixed_variant: "#254777"
	
		readonly property color on_secondary: "#273141"
	
		readonly property color on_secondary_container: "#d9e3f8"
	
		readonly property color on_secondary_fixed: "#121c2b"
	
		readonly property color on_secondary_fixed_variant: "#3e4758"
	
		readonly property color on_surface: "#e1e2e9"
	
		readonly property color on_surface_variant: "#c4c6cf"
	
		readonly property color on_tertiary: "#3e2845"
	
		readonly property color on_tertiary_container: "#f8d8fe"
	
		readonly property color on_tertiary_fixed: "#28132f"
	
		readonly property color on_tertiary_fixed_variant: "#563e5d"
	
		readonly property color outline: "#8e9099"
	
		readonly property color outline_variant: "#43474e"
	
		readonly property color primary: "#a8c8ff"
	
		readonly property color primary_container: "#254777"
	
		readonly property color primary_fixed: "#d6e3ff"
	
		readonly property color primary_fixed_dim: "#a8c8ff"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#bdc7dc"
	
		readonly property color secondary_container: "#3e4758"
	
		readonly property color secondary_fixed: "#d9e3f8"
	
		readonly property color secondary_fixed_dim: "#bdc7dc"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#3065ac"
	
		readonly property color surface: "#111318"
	
		readonly property color surface_bright: "#37393e"
	
		readonly property color surface_container: "#1d2024"
	
		readonly property color surface_container_high: "#282a2f"
	
		readonly property color surface_container_highest: "#33353a"
	
		readonly property color surface_container_low: "#191c20"
	
		readonly property color surface_container_lowest: "#0c0e13"
	
		readonly property color surface_dim: "#111318"
	
		readonly property color surface_tint: "#a8c8ff"
	
		readonly property color surface_variant: "#43474e"
	
		readonly property color tertiary: "#dbbce1"
	
		readonly property color tertiary_container: "#563e5d"
	
		readonly property color tertiary_fixed: "#f8d8fe"
	
		readonly property color tertiary_fixed_dim: "#dbbce1"
	
}