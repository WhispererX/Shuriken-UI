/**
 * @description Sets the global list of UI styles.
 * This struct persists across calls using a static variable.
 * @returns {undefined}
 */
function ui_set_global_styles(styles) {
	static globalStyles = ui_get_global_styles()
	
	struct_foreach(styles, method({globalStyles}, function(key, value) {
		globalStyles[$ key] = value;
	}))
}



/**
 * @description Retrieves the global list of UI styles.
 * This struct persists across calls using a static variable.
 * @returns {struct} The struct containing all global styles.
 */
function ui_get_global_styles() {
	static globalStyles = {};
	return globalStyles;
}