pragma Singleton
import QtQuick
import "variables.js" as Vars

QtObject {
    function withAlpha(hexString, alpha) {
        let col = Qt.color(hexString);
        return Qt.rgba(col.r, col.g, col.b, alpha);
    }
	
		readonly property color background: "#fcf8ff"
	
		readonly property color error: "#ba1a1a"
	
		readonly property color error_container: "#ffdad6"
	
		readonly property color inverse_on_surface: "#f4eff7"
	
		readonly property color inverse_primary: "#c7bfff"
	
		readonly property color inverse_surface: "#313036"
	
		readonly property color on_background: "#1c1b20"
	
		readonly property color on_error: "#ffffff"
	
		readonly property color on_error_container: "#410002"
	
		readonly property color on_primary: "#ffffff"
	
		readonly property color on_primary_container: "#1a1249"
	
		readonly property color on_primary_fixed: "#1a1249"
	
		readonly property color on_primary_fixed_variant: "#463f77"
	
		readonly property color on_secondary: "#ffffff"
	
		readonly property color on_secondary_container: "#1b192c"
	
		readonly property color on_secondary_fixed: "#1b192c"
	
		readonly property color on_secondary_fixed_variant: "#474459"
	
		readonly property color on_surface: "#1c1b20"
	
		readonly property color on_surface_variant: "#47464f"
	
		readonly property color on_tertiary: "#ffffff"
	
		readonly property color on_tertiary_container: "#301121"
	
		readonly property color on_tertiary_fixed: "#301121"
	
		readonly property color on_tertiary_fixed_variant: "#613b4d"
	
		readonly property color outline: "#78767f"
	
		readonly property color outline_variant: "#c9c5d0"
	
		readonly property color primary: "#5d5791"
	
		readonly property color primary_container: "#e4dfff"
	
		readonly property color primary_fixed: "#e4dfff"
	
		readonly property color primary_fixed_dim: "#c7bfff"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#5f5c71"
	
		readonly property color secondary_container: "#e5dff9"
	
		readonly property color secondary_fixed: "#e5dff9"
	
		readonly property color secondary_fixed_dim: "#c8c3dc"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#817bb0"
	
		readonly property color surface: "#fcf8ff"
	
		readonly property color surface_bright: "#fcf8ff"
	
		readonly property color surface_container: "#f1ecf4"
	
		readonly property color surface_container_high: "#ebe6ef"
	
		readonly property color surface_container_highest: "#e5e1e9"
	
		readonly property color surface_container_low: "#f7f2fa"
	
		readonly property color surface_container_lowest: "#ffffff"
	
		readonly property color surface_dim: "#ddd8e0"
	
		readonly property color surface_tint: "#5d5791"
	
		readonly property color surface_variant: "#e5e1ec"
	
		readonly property color tertiary: "#7b5265"
	
		readonly property color tertiary_container: "#ffd8e8"
	
		readonly property color tertiary_fixed: "#ffd8e8"
	
		readonly property color tertiary_fixed_dim: "#ecb8ce"
	
}