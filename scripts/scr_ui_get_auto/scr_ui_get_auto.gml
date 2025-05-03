/**
 * @description Calculates and returns the Y coordinate directly below the previous UI component.
 * Useful for stacking components vertically in automatic layouts.
 * 
 * @returns {real}
 */
function ui_get_auto_y() {
	static components = ui_get_components();
	var bottom = 0;
	for (var i = 0; i < array_length(components); i++) {
		if (components[i] == self) {
			if (i > 0) {
				var c = components[i - 1];
				bottom = c.getY() + c.getHeight() + c.getMarginBottom();
				
				return bottom;
			}
		}
	}
	
	return bottom;
}

/**
 * @description Calculates and returns the X coordinate aligned with the previous UI component.
 * Typically used for left-aligned vertical stacking.
 * 
 * @returns {real}
 */
function ui_get_auto_x() {
	static components = ui_get_components();
	var left = 0;

	for (var i = 0; i < array_length(components); i++) {
		if (components[i] == self && i > 0) {
			left = components[i - 1].getX();
			return left;
		}
	}
	
	return left;
}


/**
 * @description Calculates and returns the z-index (depth) for stacking the current component above the previous one.
 * Skips stacking if the previous component is marked as `isAboveAll`.
 * 
 * @returns {real}
 */
function ui_get_auto_z() {
	static components = ui_get_components();
	var z = 0;

	for (var i = 0; i < array_length(components); i++) {
		if (components[i] == self && i > 0) {
			if (!components[i - 1].isAboveAll)
			z = components[i - 1].styles.zIndex + 5;
			return z;
		}
	}
	
	return z;
}