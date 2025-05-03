
/**
 * @description Retrieves the global list of UI components.
 * This array persists across calls using a static variable.
 * @returns {array} The array containing all registered UI components.
 */
function ui_get_components() {
	static components = [];
	return components;
}

/**
 * @description Adds a UI component to the global registry.
 * Useful for tracking and managing draw/update cycles of UI elements.
 * @param {any} component - The UI component instance to register.
 * @returns {undefined}
 */
function ui_add_component(component) {
	static components = ui_get_components();
	array_push(components, component);
}


/**
 * @description Removes a UI component from the global registry.
 * This is typically used when a component is destroyed or should no longer be updated/rendered.
 * @param {any} component - The UI component instance to remove.
 * @returns {undefined}
 */
function ui_remove_component(component) {
	static components = ui_get_components();
	var index = array_get_index(components, component);
	array_delete(components, index, 1);
}

