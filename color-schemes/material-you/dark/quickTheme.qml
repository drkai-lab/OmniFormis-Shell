pragma Singleton
import QtQuick
import "variables.js" as Vars

QtObject {
    function withAlpha(hexString, alpha) {
        let col = Qt.color(hexString);
        return Qt.rgba(col.r, col.g, col.b, alpha);
    }
	
		readonly property color background: "#1a1111"
	
		readonly property color error: "#ffb4ab"
	
		readonly property color error_container: "#93000a"
	
		readonly property color inverse_on_surface: "#382e2d"
	
		readonly property color inverse_primary: "#904a49"
	
		readonly property color inverse_surface: "#f0dedd"
	
		readonly property color on_background: "#f0dedd"
	
		readonly property color on_error: "#690005"
	
		readonly property color on_error_container: "#ffdad6"
	
		readonly property color on_primary: "#571d1e"
	
		readonly property color on_primary_container: "#ffdad8"
	
		readonly property color on_primary_fixed: "#3b080b"
	
		readonly property color on_primary_fixed_variant: "#733333"
	
		readonly property color on_secondary: "#442928"
	
		readonly property color on_secondary_container: "#ffdad8"
	
		readonly property color on_secondary_fixed: "#2c1514"
	
		readonly property color on_secondary_fixed_variant: "#5d3f3e"
	
		readonly property color on_surface: "#f0dedd"
	
		readonly property color on_surface_variant: "#d7c1c0"
	
		readonly property color on_tertiary: "#412d05"
	
		readonly property color on_tertiary_container: "#ffdeab"
	
		readonly property color on_tertiary_fixed: "#271900"
	
		readonly property color on_tertiary_fixed_variant: "#5a4319"
	
		readonly property color outline: "#a08c8b"
	
		readonly property color outline_variant: "#524342"
	
		readonly property color primary: "#ffb3b0"
	
		readonly property color primary_container: "#733333"
	
		readonly property color primary_fixed: "#ffdad8"
	
		readonly property color primary_fixed_dim: "#ffb3b0"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#e6bdbb"
	
		readonly property color secondary_container: "#5d3f3e"
	
		readonly property color secondary_fixed: "#ffdad8"
	
		readonly property color secondary_fixed_dim: "#e6bdbb"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#ca5b5b"
	
		readonly property color surface: "#1a1111"
	
		readonly property color surface_bright: "#423736"
	
		readonly property color surface_container: "#271d1d"
	
		readonly property color surface_container_high: "#322827"
	
		readonly property color surface_container_highest: "#3d3232"
	
		readonly property color surface_container_low: "#231919"
	
		readonly property color surface_container_lowest: "#140c0c"
	
		readonly property color surface_dim: "#1a1111"
	
		readonly property color surface_tint: "#ffb3b0"
	
		readonly property color surface_variant: "#524342"
	
		readonly property color tertiary: "#e3c28c"
	
		readonly property color tertiary_container: "#5a4319"
	
		readonly property color tertiary_fixed: "#ffdeab"
	
		readonly property color tertiary_fixed_dim: "#e3c28c"
	
}