pragma Singleton
import QtQuick
import "variables.js" as Vars

QtObject {
    function withAlpha(hexString, alpha) {
        let col = Qt.color(hexString);
        return Qt.rgba(col.r, col.g, col.b, alpha);
    }
	
		readonly property color background: "#12131b"
	
		readonly property color error: "#ffb4ab"
	
		readonly property color error_container: "#93000a"
	
		readonly property color inverse_on_surface: "#2f3039"
	
		readonly property color inverse_primary: "#384cdc"
	
		readonly property color inverse_surface: "#e3e1ed"
	
		readonly property color on_background: "#e3e1ed"
	
		readonly property color on_error: "#690005"
	
		readonly property color on_error_container: "#ffdad6"
	
		readonly property color on_primary: "#001999"
	
		readonly property color on_primary_container: "#d2d5ff"
	
		readonly property color on_primary_fixed: "#000c61"
	
		readonly property color on_primary_fixed_variant: "#172fc4"
	
		readonly property color on_secondary: "#232b64"
	
		readonly property color on_secondary_container: "#dcdeff"
	
		readonly property color on_secondary_fixed: "#0b144e"
	
		readonly property color on_secondary_fixed_variant: "#3a427c"
	
		readonly property color on_surface: "#e3e1ed"
	
		readonly property color on_surface_variant: "#c5c5d7"
	
		readonly property color on_tertiary: "#55006a"
	
		readonly property color on_tertiary_container: "#f9c8ff"
	
		readonly property color on_tertiary_fixed: "#340042"
	
		readonly property color on_tertiary_fixed_variant: "#770c91"
	
		readonly property color outline: "#8f8fa1"
	
		readonly property color outline_variant: "#454655"
	
		readonly property color primary: "#bcc2ff"
	
		readonly property color primary_container: "#0d28c0"
	
		readonly property color primary_fixed: "#dfe0ff"
	
		readonly property color primary_fixed_dim: "#bcc2ff"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#bcc2ff"
	
		readonly property color secondary_container: "#3a427c"
	
		readonly property color secondary_fixed: "#dfe0ff"
	
		readonly property color secondary_fixed_dim: "#bcc2ff"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#0d28c0"
	
		readonly property color surface: "#12131b"
	
		readonly property color surface_bright: "#383842"
	
		readonly property color surface_container: "#1e1f28"
	
		readonly property color surface_container_high: "#292932"
	
		readonly property color surface_container_highest: "#34343d"
	
		readonly property color surface_container_low: "#1a1b23"
	
		readonly property color surface_container_lowest: "#0d0e16"
	
		readonly property color surface_dim: "#12131b"
	
		readonly property color surface_tint: "#bcc2ff"
	
		readonly property color surface_variant: "#454655"
	
		readonly property color tertiary: "#f3aeff"
	
		readonly property color tertiary_container: "#71008c"
	
		readonly property color tertiary_fixed: "#fdd6ff"
	
		readonly property color tertiary_fixed_dim: "#f3aeff"
	
}