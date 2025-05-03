/**
 * @description Calculates and returns the X position immediately after the previous UI component (used for inline layout).
 * This is useful for positioning the current component in a horizontal flow layout.
 * 
 * @returns {real}
 */
function ui_get_inline_x() {
	var components = ui_get_components();
	var right = 0;

	for (var i = 0; i < array_length(components); i++) {
		if (components[i] == self && i > 0) {
			var prev = components[i - 1];
			right = prev.getX() + prev.getWidth() + prev.getMarginRight();
			return right;
		}
	}
	
	return right;
}

/**
 * @description Calculates and returns the Y position of the previous UI component (used for inline layout).
 * This is useful for aligning components in the same row when using inline or flow-based layouts.
 * 
 * @returns {real}
 */
function ui_get_inline_y() {
	var components = ui_get_components();
	var top = 0;

	for (var i = 0; i < array_length(components); i++) {
		if (components[i] == self && i > 0) {
			var prev = components[i - 1];
			top = prev.getY();
			return top;
		}
	}
	
	return top;
}