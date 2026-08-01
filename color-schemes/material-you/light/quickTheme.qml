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
	
		readonly property color inverse_on_surface: "#f2eff7"
	
		readonly property color inverse_primary: "#bbc3ff"
	
		readonly property color inverse_surface: "#303036"
	
		readonly property color on_background: "#1b1b21"
	
		readonly property color on_error: "#ffffff"
	
		readonly property color on_error_container: "#410002"
	
		readonly property color on_primary: "#ffffff"
	
		readonly property color on_primary_container: "#0c154b"
	
		readonly property color on_primary_fixed: "#0c154b"
	
		readonly property color on_primary_fixed_variant: "#3a4279"
	
		readonly property color on_secondary: "#ffffff"
	
		readonly property color on_secondary_container: "#181a2c"
	
		readonly property color on_secondary_fixed: "#181a2c"
	
		readonly property color on_secondary_fixed_variant: "#434559"
	
		readonly property color on_surface: "#1b1b21"
	
		readonly property color on_surface_variant: "#46464f"
	
		readonly property color on_tertiary: "#ffffff"
	
		readonly property color on_tertiary_container: "#2d1227"
	
		readonly property color on_tertiary_fixed: "#2d1227"
	
		readonly property color on_tertiary_fixed_variant: "#5d3c54"
	
		readonly property color outline: "#767680"
	
		readonly property color outline_variant: "#c7c5d0"
	
		readonly property color primary: "#525a92"
	
		readonly property color primary_container: "#dfe0ff"
	
		readonly property color primary_fixed: "#dfe0ff"
	
		readonly property color primary_fixed_dim: "#bbc3ff"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#5b5d72"
	
		readonly property color secondary_container: "#e0e1f9"
	
		readonly property color secondary_fixed: "#e0e1f9"
	
		readonly property color secondary_fixed_dim: "#c4c5dd"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#858bbb"
	
		readonly property color surface: "#fbf8ff"
	
		readonly property color surface_bright: "#fbf8ff"
	
		readonly property color surface_container: "#efedf4"
	
		readonly property color surface_container_high: "#e9e7ef"
	
		readonly property color surface_container_highest: "#e4e1e9"
	
		readonly property color surface_container_low: "#f5f2fa"
	
		readonly property color surface_container_lowest: "#ffffff"
	
		readonly property color surface_dim: "#dbd9e0"
	
		readonly property color surface_tint: "#525a92"
	
		readonly property color surface_variant: "#e3e1ec"
	
		readonly property color tertiary: "#77536c"
	
		readonly property color tertiary_container: "#ffd7f0"
	
		readonly property color tertiary_fixed: "#ffd7f0"
	
		readonly property color tertiary_fixed_dim: "#e6bad7"
	
}