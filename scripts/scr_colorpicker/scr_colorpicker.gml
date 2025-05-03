/// @feather ignore all
/// @description Creates a color picker component
/// @param {Struct} [styles] - Optional styles to apply to the color picker
/// @param {Real} [x] - X position of the color picker
/// @param {Real} [y] - Y position of the color picker
function ColorPicker(styles = {}, x = LAYOUT_AUTO, y = LAYOUT_AUTO ) : Component(x, y, styles) constructor {
	#region Properties
	self.value = c_white;
	
	self.hue = 0;                // Current hue (0-255)
	self.saturation = 0;         // Current saturation (0-255)
	self.brightness = 0;         // Current brightness/value (0-255)
	
	// Rendering properties
	self.mainSurface = noone;		// Surface for saturation/value block
	self.hueSurface = noone;		// Surface for hue sidebar
	self.needsRefresh = true;		// Whether surfaces need to be redrawn
	self.shader = shd_color_picker; // Shader for drawing saturation/value
	
	// Interaction state
	self.isFocused = false;      // Whether color picker has focus
	self.activeArea = -1;        // Current active area (-1: none, 0: SV block, 1: hue)
	
	// New property to handle the expanded/collapsed state
	self.isExpanded = false;     // Whether color picker is expanded
	
	self.blockWidth = 255;       // Width of the color selection block
	self.sidebarWidth = 32;      // Width of the hue sidebar
	
	self.isAboveAll = true;
	
	// Color picker count
	static count = 0;
	count++;
	
	#endregion
	
	#region Styles
	self.defaultStyles = struct_merge(self.defaultStyles, {
		gap: 10, 
		
		width: 16,
		height: 16,
		
		opacity: .7,
		
		padding: 5,
		
		boxShadow: 0.2,
		borderRadius: 4,
		
		cursor: cr_handpoint,
		zIndex:  -999 + count,
	});
	
	self.styles = struct_merge(self.defaultStyles, styles);
	#endregion
	
	#region Getters / Setters
	
	#region Getters
	
	// Override getWidth and getHeight from parent Component
	self.getWidthInherited = self.getWidth;
	self.getHeightInherited = self.getHeight;
	
	/// @description Gets the current color as an RGB value
	/// @returns {Real} The current color
	self.getColor = function() {
		return make_color_hsv(self.hue, self.saturation, self.brightness);
	};
	
	/// @description Gets the current color as a hex string
	/// @returns {String} The current color as a hex string (e.g., "#FF00FF")
	self.getColorHex = function() {
		return color_to_hex(self.getColor());
	};
	
	/// @description Gets the block width from styles
	self.getBlockWidth = function() {
		return self.blockWidth;
	};
	
	/// @description Gets the sidebar width from styles
	self.getSidebarWidth = function() {
		return self.sidebarWidth;
	};
	
	/// @description Gets the spacing from styles
	self.getSpacing = function() {
		return self.styles.gap;
	};
	
	/// @description Gets the width based on expanded state
	self.getWidth = function() {
		if (self.isExpanded) {
			return self.blockWidth + self.sidebarWidth + (self.getSpacing() * 3);
		} else {
			return self.getWidthInherited();
		}
	};
	
	/// @description Gets the height based on expanded state
	self.getHeight = function() {
		if (self.isExpanded) {
			return self.blockWidth + (self.getSpacing() * 2);
		} else {
			return self.getHeightInherited();
		}
	};
	#endregion
	
	#region Setters
	/// @description Sets the color of the color picker
	/// @param {Real} color - The color to set (can be created with make_color_rgb/make_color_hsv)
	self.setColor = function(color) {
		var oldColor = self.value;
		self.value = color;
		self.hue = color_get_hue(color);
		self.saturation = color_get_saturation(color);
		self.brightness = color_get_value(color);
		self.needsRefresh = true;
		
		if (oldColor != color) {
			self.events.onChange(color);
		}
		
		return self;
	};
	
	/// @description Sets the color using a hex string
	/// @param {String} hexColor - The color as a hex string (e.g., "#FF00FF" or "FF00FF")
	self.setColorHex = function(hexColor) {
		var color = hex_to_color(hexColor);
		self.setColor(color);
		
		return self;
	};
	
	/// @description Sets the block width
	/// @param {Real} width - The new block width
	self.setBlockWidth = function(width) {
		self.blockWidth = width;
		self.needsRefresh = true;
		return self;
	};
	
	/// @description Sets the sidebar width
	/// @param {Real} width - The new sidebar width
	self.setSidebarWidth = function(width) {
		self.sidebarWidth = width;
		self.needsRefresh = true;
		return self;
	};
	
	/// @description Expands the color picker
	self.expand = function() {
		self.isExpanded = true;
		self.active = self;
		return self;
	};
	
	/// @description Collapses the color picker
	self.collapse = function() {
		self.isExpanded = false;
		self.activeArea = -1;
		return self;
	};
	
	/// @description Toggles between expanded and collapsed states
	self.toggle = function() {	
		self.isExpanded = !self.isExpanded;
		global.color_picker_active = self.isExpanded;
		if (!self.isExpanded) {
			self.activeArea = -1;
		}
		return self;
	};
	#endregion
	
	#endregion
	
	#region Private Methods
	
	/// @description Checks if mouse is in a specific area of the color picker
	/// @param {Real} areaIndex - The area to check (0: SV block, 1: hue sidebar)
	/// @returns {Boolean} Whether the mouse is in the specified area
	self._isMouseInArea = function(areaIndex) {
		if (!self.isExpanded) return false;
		
		var mouseX = UI_MOUSE_X;
		var mouseY = UI_MOUSE_Y;
		var startX = self.getX() + self.getSpacing();
		var startY = self.getY() + self.getSpacing();
		var blockWidth = self.getBlockWidth();
		var sidebarWidth = self.getSidebarWidth();
		var spacing = self.getSpacing();
		
		if (mouseY < startY || mouseY > startY + blockWidth) return false;
		
		if (areaIndex == 0) {
			// Check if in the saturation/value block
			return (mouseX >= startX && mouseX <= startX + blockWidth);
		} else if (areaIndex == 1) {
			// Check if in the hue sidebar
			var sidebarX = startX + blockWidth + spacing;
			return (mouseX >= sidebarX && mouseX <= sidebarX + sidebarWidth);
		}
		
		return false;
	};
	
	/// @description Checks if mouse is in the collapsed color block
	/// @returns {Boolean} Whether the mouse is in the collapsed color block
	self._isMouseInCollapsedBlock = function() {
		if (self.isExpanded) return false;
		
		var mouseX = UI_MOUSE_X;
		var mouseY = UI_MOUSE_Y;
		var x1 = self.getX() + self.getPaddingLeft();
		var y1 = self.getY() + self.getPaddingTop();
		var x2 = x1 + self.styles.width;
		var y2 = y1 + self.styles.height;
		
		return point_in_rectangle(mouseX, mouseY, x1, y1, x2, y2);
	};
	
	/// @description Updates color values based on mouse position
	self._updateFromMousePosition = function() {
		if (!self.isFocused || self.activeArea == -1 || !self.isExpanded) return;
		
		var mouseX = UI_MOUSE_X;
		var mouseY = UI_MOUSE_Y;
		var startX = self.getX() + self.getSpacing();
		var startY = self.getY() + self.getSpacing();
		var blockWidth = self.getBlockWidth();
		
		// Scale factor (how many color units per pixel)
		var scaleFactor = 255 / blockWidth;
		
		if (self.activeArea == 0) {
			// Update saturation and brightness based on mouse position in the color block
			var relativeX = clamp(mouseX - startX, 0, blockWidth);
			var relativeY = clamp(mouseY - startY, 0, blockWidth);
			
			var newSaturation = ceil(scaleFactor * relativeX);
			var newBrightness = 255 - ceil(scaleFactor * relativeY);
			
			if (newSaturation != self.saturation || newBrightness != self.brightness) {
				var oldColor = self.getColor();
				self.saturation = newSaturation;
				self.brightness = newBrightness;
				
				// Update color value
				self.value = make_color_hsv(self.hue, self.saturation, self.brightness);
				
				// Trigger color change event
				self.events.onChange(self.value);
			}
		} else if (self.activeArea == 1) {
			// Update hue based on mouse position in the hue sidebar
			var relativeY = clamp(mouseY - startY, 0, blockWidth);
			var newHue = ceil(scaleFactor * relativeY);
			
			if (newHue != self.hue) {
				var oldColor = self.getColor();
				self.hue = newHue;
				self.needsRefresh = true;
				
				// Update color value
				self.value = make_color_hsv(self.hue, self.saturation, self.brightness);
				
				// Trigger color change event
				self.events.onChange(self.value);
			}
		}
	};
	
	/// @description Handles keyboard input for color adjustment
	self._handleKeyboardInput = function() {
		if (!self.isFocused || !self.isExpanded) return;
		
		var saturationChange = keyboard_check(vk_right) - keyboard_check(vk_left);
		if (saturationChange != 0) {
			var oldColor = self.getColor();
			self.saturation = clamp(self.saturation + saturationChange * 2, 0, 255);
			
			// Update color value
			self.value = make_color_hsv(self.hue, self.saturation, self.brightness);
			
			// Trigger color change event
			self.events.onChange(self.value);
		}
		
		var brightnessChange = keyboard_check(vk_up) - keyboard_check(vk_down);
		if (brightnessChange != 0) {
			var oldColor = self.getColor();
			self.brightness = clamp(self.brightness + brightnessChange * 2, 0, 255);
			
			// Update color value
			self.value = make_color_hsv(self.hue, self.saturation, self.brightness);
			
			// Trigger color change event
			self.events.onChange(self.value);
		}
		
		var hueChange = keyboard_check(vk_add) - keyboard_check(vk_subtract);
		if (hueChange != 0) {
			var oldColor = self.getColor();
			self.hue = clamp(self.hue + hueChange * 2, 0, 255);
			self.needsRefresh = true;
			
			// Update color value
			self.value = make_color_hsv(self.hue, self.saturation, self.brightness);
			
			// Trigger color change event
			self.events.onChange(self.value);
		}
	};
	
	/// @description Creates and initializes the main color surface
	self._createMainSurface = function() {
		var blockWidth = self.getBlockWidth();
		var surface = surface_create(blockWidth, blockWidth);
		
		surface_set_target(surface);
		draw_clear_alpha(0, 0);
		
		// Draw the base color (current hue at full saturation/value)
		draw_set_color(make_color_hsv(self.hue, 255, 255));
		draw_rectangle(0, 0, blockWidth, blockWidth, false);
		
		surface_reset_target();
		
		return surface;
	};
	
	/// @description Creates and initializes the hue sidebar surface
	self._createHueSurface = function() {
		var sidebarWidth = self.getSidebarWidth();
		var blockWidth = self.getBlockWidth();
		var surface = surface_create(sidebarWidth, blockWidth);
		
		surface_set_target(surface);
		draw_clear_alpha(0, 0);
		
		// Draw gradient of hues from top to bottom
		for (var i = 0; i < blockWidth; i++) {
			var hueValue = floor((i / blockWidth) * 255);
			var hueColor = make_color_hsv(hueValue, 255, 255);
			draw_set_color(hueColor);
			draw_rectangle(0, i, sidebarWidth, i, false);
		}
		
		// Add a border around the hue sidebar
		draw_set_color(c_black);
		draw_rectangle(0, 0, sidebarWidth - 1, blockWidth - 1, true);
		
		surface_reset_target();
		
		return surface;
	};
	
	#endregion
	
	#region Methods
	
	// Draw body method required to override the Component's default body drawing
	self.draw_body = function() {		
		if (self.isExpanded) {
			self._drawExpandedPicker();
		} else {
			self._drawCollapsedPicker();
		}
		
		// Reset drawing settings
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	};
	
	// Draw the collapsed color picker (just the color block)
	self._drawCollapsedPicker = function() {
		var x1 = self.getX();
		var y1 = self.getY();
		var x2 = x1 + self.getWidth();
		var y2 = y1 + self.getHeight();
		
		// Draw background
		draw_set_color(self.styles.backgroundColor);
		draw_set_alpha(self.styles.opacity);
		draw_roundrect_ext(x1, y1, x2, y2, self.styles.borderRadius, self.styles.borderRadius, false);
		
		// Draw current color
		var colorX1 = x1 + self.getPaddingLeft();
		var colorY1 = y1 + self.getPaddingTop();
		var colorX2 = x1 + self.styles.width + self.getPaddingLeft();
		var colorY2 = y1 + self.styles.height + self.getPaddingTop();
		
		draw_set_color(self.value);
		draw_set_alpha(self.styles.opacity);
		draw_roundrect_ext(colorX1, colorY1, colorX2, colorY2, self.styles.borderRadius / 2, self.styles.borderRadius / 2, false);
		
		// Draw a border around the color
		draw_set_color(self.styles.borderColor);
		draw_set_alpha(self.styles.borderOpacity);
		if (self.styles.border)
		draw_roundrect_ext(colorX1, colorY1, colorX2, colorY2, self.styles.borderRadius / 2, self.styles.borderRadius / 2, true);
		
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	};
	
	// Draw the expanded color picker
	self._drawExpandedPicker = function() {
		var startX = self.getX() + self.getSpacing();
		var startY = self.getY() + self.getSpacing();
		var blockWidth = self.getBlockWidth();
		var sidebarWidth = self.getSidebarWidth();
		var spacing = self.getSpacing();
		var scaleFactor = blockWidth / 255;
		
		// Draw background
		var bgX1 = self.getX();
		var bgY1 = self.getY();
		var bgX2 = bgX1 + self.getWidth();
		var bgY2 = bgY1 + self.getHeight();
		
		draw_set_color(self.styles.backgroundColor);
		draw_set_alpha(self.styles.opacity);
		draw_roundrect_ext(bgX1, bgY1, bgX2, bgY2, self.styles.borderRadius, self.styles.borderRadius, false);
		
		// Create or refresh the main surface (saturation/value)
		if (!surface_exists(self.mainSurface) || self.needsRefresh) {
			if (surface_exists(self.mainSurface)) {
				surface_free(self.mainSurface);
			}
			self.mainSurface = self._createMainSurface();
			self.needsRefresh = false;
		}
		
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
		
		// Draw the main surface with the color picker shader
		shader_set(self.shader);
		draw_surface(self.mainSurface, startX, startY);
		shader_reset();
		
		// Draw a border around the main surface
		draw_set_color(self.styles.borderColor);
		draw_set_alpha(self.styles.borderOpacity);
		draw_rectangle(startX, startY, startX + blockWidth, startY + blockWidth, true);
		
		// Draw the selection circle on the main surface
		var circleX = startX + ceil(scaleFactor * self.saturation);
		var circleY = startY + blockWidth - ceil(scaleFactor * self.brightness);
		
		draw_set_circle_precision(64);
		draw_set_color(c_black);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY)
		draw_circle(circleX, circleY, 4, true);
		draw_set_color(c_white);
		draw_circle(circleX, circleY, 5, true);
		
		// Create or refresh the hue sidebar
		if (!surface_exists(self.hueSurface) || self.needsRefresh) {
			if (surface_exists(self.hueSurface)) {
				surface_free(self.hueSurface);
			}
			self.hueSurface = self._createHueSurface();
		}
		
		// Draw the hue sidebar
		var sidebarX = startX + blockWidth + spacing;
		draw_surface(self.hueSurface, sidebarX, startY);
		
		// Draw the selection marker on the hue sidebar
		var markerY = startY + clamp(ceil(scaleFactor * self.hue), 0, blockWidth - 5);
		draw_set_color(c_black);
		draw_rectangle(sidebarX + 2, markerY, sidebarX + sidebarWidth - 2, markerY + 4, true);
		draw_set_color(c_white);
		draw_rectangle(sidebarX + 1, markerY - 1, sidebarX + sidebarWidth - 1, markerY + 5, true);
		
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	};
	
	// Handle events
	self.handle_events_inherit = self.handle_events;
	self.handle_events = function() {
		// Call the parent method to handle standard events
		self.handle_events_inherit();
		
		if (!self.enabled || !self.visible) return;
		
		// Check if clicked outside the component to collapse
		if (mouse_check_button_pressed(mb_left) && !self.hovered() && self.isExpanded) {
			self.collapse();
			self.isFocused = false;
			return;
		}
		
		// Handle mouse press to determine focus and active area
		if (mouse_check_button_pressed(mb_left)) {
			// Check if collapsed block was clicked
			if (self._isMouseInCollapsedBlock() && !self.isExpanded) {
				self.expand();
				self.isFocused = true;
				return;
			}
			
			var isMouseInComponent = self.hovered();
			
			if (isMouseInComponent) {
				self.isFocused = true;
				
				// Check which area was clicked
				if (self._isMouseInArea(0)) {
					self.activeArea = 0;
				} else if (self._isMouseInArea(1)) {
					self.activeArea = 1;
				} else {
					self.activeArea = -1;
				}
			} else {
				self.isFocused = false;
				self.activeArea = -1;
			}
		}
		
		// If mouse button is held, update color based on mouse position
		if (mouse_check_button(mb_left)) {
			self._updateFromMousePosition();
		}
		
		// Handle keyboard input
		self._handleKeyboardInput();
	};
	
	
	// Clean up surfaces when the component is destroyed
	self.cleanup = function() {
		if (surface_exists(self.mainSurface)) {
			surface_free(self.mainSurface);
		}
		
		if (surface_exists(self.hueSurface)) {
			surface_free(self.hueSurface);
		}
	};
	
	#endregion
}