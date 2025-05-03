/// @description
components = ui_get_components();

// Sort by z-index
array_sort(components, function(a, b) {
    return b.styles.zIndex - a.styles.zIndex;
});

// Process each component
for (var i = 0; i < array_length(components); i++) {
	// Get styles
	if (UI_ENABLE_GLOBAL_STYLING) {
		var defaultStyles = components[i].defaultStyles;
		var styles = components[i].styles;
		var newStyles = struct_subtract(defaultStyles, styles);
		var newDefault = struct_merge(defaultStyles, ui_get_global_styles())
		components[i].defaultStyles = newDefault;
		components[i].styles = struct_merge(newDefault, newStyles);
	}
    components[i].run();
}