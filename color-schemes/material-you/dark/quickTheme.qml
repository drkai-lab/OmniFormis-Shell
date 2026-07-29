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
	
		readonly property color inverse_primary: "#3d5f90"
	
		readonly property color inverse_surface: "#e1e2e9"
	
		readonly property color on_background: "#e1e2e9"
	
		readonly property color on_error: "#690005"
	
		readonly property color on_error_container: "#ffdad6"
	
		readonly property color on_primary: "#01315e"
	
		readonly property color on_primary_container: "#d5e3ff"
	
		readonly property color on_primary_fixed: "#001c3b"
	
		readonly property color on_primary_fixed_variant: "#234776"
	
		readonly property color on_secondary: "#273141"
	
		readonly property color on_secondary_container: "#d9e3f8"
	
		readonly property color on_secondary_fixed: "#121c2b"
	
		readonly property color on_secondary_fixed_variant: "#3d4758"
	
		readonly property color on_surface: "#e1e2e9"
	
		readonly property color on_surface_variant: "#c3c6cf"
	
		readonly property color on_tertiary: "#3d2846"
	
		readonly property color on_tertiary_container: "#f7d8ff"
	
		readonly property color on_tertiary_fixed: "#271430"
	
		readonly property color on_tertiary_fixed_variant: "#553f5d"
	
		readonly property color outline: "#8d9199"
	
		readonly property color outline_variant: "#43474e"
	
		readonly property color primary: "#a6c8ff"
	
		readonly property color primary_container: "#234776"
	
		readonly property color primary_fixed: "#d5e3ff"
	
		readonly property color primary_fixed_dim: "#a6c8ff"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#bdc7dc"
	
		readonly property color secondary_container: "#3d4758"
	
		readonly property color secondary_fixed: "#d9e3f8"
	
		readonly property color secondary_fixed_dim: "#bdc7dc"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#0d4d8d"
	
		readonly property color surface: "#111318"
	
		readonly property color surface_bright: "#37393e"
	
		readonly property color surface_container: "#1d2024"
	
		readonly property color surface_container_high: "#282a2f"
	
		readonly property color surface_container_highest: "#32353a"
	
		readonly property color surface_container_low: "#191c20"
	
		readonly property color surface_container_lowest: "#0c0e13"
	
		readonly property color surface_dim: "#111318"
	
		readonly property color surface_tint: "#a6c8ff"
	
		readonly property color surface_variant: "#43474e"
	
		readonly property color tertiary: "#dabde2"
	
		readonly property color tertiary_container: "#553f5d"
	
		readonly property color tertiary_fixed: "#f7d8ff"
	
		readonly property color tertiary_fixed_dim: "#dabde2"
	
}