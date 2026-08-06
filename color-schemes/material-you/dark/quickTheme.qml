pragma Singleton
import QtQuick
import "variables.js" as Vars

QtObject {
    function withAlpha(hexString, alpha) {
        let col = Qt.color(hexString);
        return Qt.rgba(col.r, col.g, col.b, alpha);
    }
	
		readonly property color background: "#141318"
	
		readonly property color error: "#ffb4ab"
	
		readonly property color error_container: "#93000a"
	
		readonly property color inverse_on_surface: "#313036"
	
		readonly property color inverse_primary: "#5d5791"
	
		readonly property color inverse_surface: "#e5e1e9"
	
		readonly property color on_background: "#e5e1e9"
	
		readonly property color on_error: "#690005"
	
		readonly property color on_error_container: "#ffdad6"
	
		readonly property color on_primary: "#2f295f"
	
		readonly property color on_primary_container: "#e4dfff"
	
		readonly property color on_primary_fixed: "#1a1249"
	
		readonly property color on_primary_fixed_variant: "#463f77"
	
		readonly property color on_secondary: "#302e41"
	
		readonly property color on_secondary_container: "#e5dff9"
	
		readonly property color on_secondary_fixed: "#1b192c"
	
		readonly property color on_secondary_fixed_variant: "#474459"
	
		readonly property color on_surface: "#e5e1e9"
	
		readonly property color on_surface_variant: "#c9c5d0"
	
		readonly property color on_tertiary: "#482537"
	
		readonly property color on_tertiary_container: "#ffd8e8"
	
		readonly property color on_tertiary_fixed: "#301121"
	
		readonly property color on_tertiary_fixed_variant: "#613b4d"
	
		readonly property color outline: "#928f99"
	
		readonly property color outline_variant: "#47464f"
	
		readonly property color primary: "#c7bfff"
	
		readonly property color primary_container: "#463f77"
	
		readonly property color primary_fixed: "#e4dfff"
	
		readonly property color primary_fixed_dim: "#c7bfff"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#c8c3dc"
	
		readonly property color secondary_container: "#474459"
	
		readonly property color secondary_fixed: "#e5dff9"
	
		readonly property color secondary_fixed_dim: "#c8c3dc"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#817bb0"
	
		readonly property color surface: "#141318"
	
		readonly property color surface_bright: "#3a383e"
	
		readonly property color surface_container: "#201f25"
	
		readonly property color surface_container_high: "#2a292f"
	
		readonly property color surface_container_highest: "#35343a"
	
		readonly property color surface_container_low: "#1c1b20"
	
		readonly property color surface_container_lowest: "#0e0e13"
	
		readonly property color surface_dim: "#141318"
	
		readonly property color surface_tint: "#c7bfff"
	
		readonly property color surface_variant: "#47464f"
	
		readonly property color tertiary: "#ecb8ce"
	
		readonly property color tertiary_container: "#613b4d"
	
		readonly property color tertiary_fixed: "#ffd8e8"
	
		readonly property color tertiary_fixed_dim: "#ecb8ce"
	
}