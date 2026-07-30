pragma Singleton
import QtQuick
import "variables.js" as Vars

QtObject {
    function withAlpha(hexString, alpha) {
        let col = Qt.color(hexString);
        return Qt.rgba(col.r, col.g, col.b, alpha);
    }
	
		readonly property color background: "#f9f9ff"
	
		readonly property color error: "#ba1a1a"
	
		readonly property color error_container: "#ffdad6"
	
		readonly property color inverse_on_surface: "#f0f0f7"
	
		readonly property color inverse_primary: "#a8c8ff"
	
		readonly property color inverse_surface: "#2e3035"
	
		readonly property color on_background: "#191c20"
	
		readonly property color on_error: "#ffffff"
	
		readonly property color on_error_container: "#410002"
	
		readonly property color on_primary: "#ffffff"
	
		readonly property color on_primary_container: "#001b3c"
	
		readonly property color on_primary_fixed: "#001b3c"
	
		readonly property color on_primary_fixed_variant: "#254777"
	
		readonly property color on_secondary: "#ffffff"
	
		readonly property color on_secondary_container: "#121c2b"
	
		readonly property color on_secondary_fixed: "#121c2b"
	
		readonly property color on_secondary_fixed_variant: "#3e4758"
	
		readonly property color on_surface: "#191c20"
	
		readonly property color on_surface_variant: "#43474e"
	
		readonly property color on_tertiary: "#ffffff"
	
		readonly property color on_tertiary_container: "#28132f"
	
		readonly property color on_tertiary_fixed: "#28132f"
	
		readonly property color on_tertiary_fixed_variant: "#563e5d"
	
		readonly property color outline: "#74777f"
	
		readonly property color outline_variant: "#c4c6cf"
	
		readonly property color primary: "#3f5f90"
	
		readonly property color primary_container: "#d6e3ff"
	
		readonly property color primary_fixed: "#d6e3ff"
	
		readonly property color primary_fixed_dim: "#a8c8ff"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#555f71"
	
		readonly property color secondary_container: "#d9e3f8"
	
		readonly property color secondary_fixed: "#d9e3f8"
	
		readonly property color secondary_fixed_dim: "#bdc7dc"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#3065ac"
	
		readonly property color surface: "#f9f9ff"
	
		readonly property color surface_bright: "#f9f9ff"
	
		readonly property color surface_container: "#ededf4"
	
		readonly property color surface_container_high: "#e7e8ee"
	
		readonly property color surface_container_highest: "#e1e2e9"
	
		readonly property color surface_container_low: "#f3f3fa"
	
		readonly property color surface_container_lowest: "#ffffff"
	
		readonly property color surface_dim: "#d9d9e0"
	
		readonly property color surface_tint: "#3f5f90"
	
		readonly property color surface_variant: "#e0e2ec"
	
		readonly property color tertiary: "#6f5675"
	
		readonly property color tertiary_container: "#f8d8fe"
	
		readonly property color tertiary_fixed: "#f8d8fe"
	
		readonly property color tertiary_fixed_dim: "#dbbce1"
	
}