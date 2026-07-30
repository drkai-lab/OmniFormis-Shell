pragma Singleton
import QtQuick
import "variables.js" as Vars

QtObject {
    function withAlpha(hexString, alpha) {
        let col = Qt.color(hexString);
        return Qt.rgba(col.r, col.g, col.b, alpha);
    }
	
		readonly property color background: "#fff8f7"
	
		readonly property color error: "#ba1a1a"
	
		readonly property color error_container: "#ffdad6"
	
		readonly property color inverse_on_surface: "#ffedeb"
	
		readonly property color inverse_primary: "#ffb3b0"
	
		readonly property color inverse_surface: "#382e2d"
	
		readonly property color on_background: "#231919"
	
		readonly property color on_error: "#ffffff"
	
		readonly property color on_error_container: "#410002"
	
		readonly property color on_primary: "#ffffff"
	
		readonly property color on_primary_container: "#3b080b"
	
		readonly property color on_primary_fixed: "#3b080b"
	
		readonly property color on_primary_fixed_variant: "#733333"
	
		readonly property color on_secondary: "#ffffff"
	
		readonly property color on_secondary_container: "#2c1514"
	
		readonly property color on_secondary_fixed: "#2c1514"
	
		readonly property color on_secondary_fixed_variant: "#5d3f3e"
	
		readonly property color on_surface: "#231919"
	
		readonly property color on_surface_variant: "#524342"
	
		readonly property color on_tertiary: "#ffffff"
	
		readonly property color on_tertiary_container: "#271900"
	
		readonly property color on_tertiary_fixed: "#271900"
	
		readonly property color on_tertiary_fixed_variant: "#5a4319"
	
		readonly property color outline: "#857372"
	
		readonly property color outline_variant: "#d7c1c0"
	
		readonly property color primary: "#904a49"
	
		readonly property color primary_container: "#ffdad8"
	
		readonly property color primary_fixed: "#ffdad8"
	
		readonly property color primary_fixed_dim: "#ffb3b0"
	
		readonly property color scrim: "#000000"
	
		readonly property color secondary: "#775655"
	
		readonly property color secondary_container: "#ffdad8"
	
		readonly property color secondary_fixed: "#ffdad8"
	
		readonly property color secondary_fixed_dim: "#e6bdbb"
	
		readonly property color shadow: "#000000"
	
		readonly property color source_color: "#ca5b5b"
	
		readonly property color surface: "#fff8f7"
	
		readonly property color surface_bright: "#fff8f7"
	
		readonly property color surface_container: "#fceae8"
	
		readonly property color surface_container_high: "#f6e4e3"
	
		readonly property color surface_container_highest: "#f0dedd"
	
		readonly property color surface_container_low: "#fff0ef"
	
		readonly property color surface_container_lowest: "#ffffff"
	
		readonly property color surface_dim: "#e8d6d5"
	
		readonly property color surface_tint: "#904a49"
	
		readonly property color surface_variant: "#f4dddc"
	
		readonly property color tertiary: "#745a2e"
	
		readonly property color tertiary_container: "#ffdeab"
	
		readonly property color tertiary_fixed: "#ffdeab"
	
		readonly property color tertiary_fixed_dim: "#e3c28c"
	
}