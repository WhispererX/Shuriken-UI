/// @feather ignore all
function Slider(min_value, max_value, value, step, styles = {}, x = LAYOUT_AUTO, y = LAYOUT_AUTO) : Component(x, y, styles) constructor {
	#region Properties
	self.value = clamp(value, min_value, max_value);
	self.minValue = min_value;
	self.maxValue = max_value;
	self.step = step;
	self.handleSize = 18;
	self.draw_handle_shadow = false;
	self.isVertical = false;
	#endregion
	
	#region Styles
	self.defaultStyles = struct_merge(self.defaultStyles, {
		width: 200,
		height: 4,
		
		opacity: .7,
		boxShadow: 0.2,
		cursor: cr_handpoint,
		
		fill: c_green,
		
		border: false,
		borderRadius: 4,
		outline: false,
		
		flexDirection: FLEX_DIRECTION.ROW,
	});
	self.styles = struct_merge(self.defaultStyles, styles);
	
	// Set vertical mode based on flexDirection
	self.isVertical = (self.styles.flexDirection == FLEX_DIRECTION.COLUMN);
	if (self.isVertical) {
		var height = self.styles.height;
		self.styles.height = self.styles.width;
		self.styles.width = height;
	}
	#endregion
	
	#region Events
	self.events.onHover = function() {
		self.draw_handle_shadow = true;	
	}
	
	self.events.onLeave = function() {
		self.draw_handle_shadow = false;	
	}
	#endregion
	
	#region Methods
	self.setValue = function(new_value) {
		// Apply step if needed
		if (self.step > 0) {
			new_value = round(new_value / self.step) * self.step;
		}
		
		// Clamp value between min and max
		var old_value = self.value;
		self.value = clamp(new_value, self.minValue, self.maxValue);
		
		// Trigger change event if value changed
		if (old_value != self.value) {
			self.events.onChange(self.value);
		}
		
		return self;
	}
	
	self.setHandleSize = function(handleSize) {
		self.handleSize = handleSize;
		return self;
	}
	
	self.getHandleSize = function() {
		return self.handleSize;	
	}
	
	self.getPercentage = function() {
		return (self.value - self.minValue) / (self.maxValue - self.minValue);
	}
	
	self.getHandlePosition = function() {
		var percentage = self.getPercentage();
		
		if (self.isVertical) {
			// For vertical slider, handle moves from bottom to top
			var y1 = self.getY() + self.styles.translateY;
			var height = self.getHeight();
			// Invert percentage for vertical slider (0% at bottom, 100% at top)
			var invertedPercentage = 1 - percentage;
			return y1 + (height * invertedPercentage);
		} else {
			// For horizontal slider, handle moves from left to right
			var x1 = self.getX() + self.styles.translateX;
			var width = self.getWidth();
			return x1 + (width * percentage);
		}
	}
	
	self.getHandleX = function() {
		if (self.isVertical) {
			return self.getX() + self.styles.translateX + (self.getWidth() / 2);
		} else {
			return self.getHandlePosition();
		}
	}
	
	self.getHandleY = function() {
		if (self.isVertical) {
			return self.getHandlePosition();
		} else {
			return self.getY() + self.styles.translateY + (self.getHeight() / 2);
		}
	}
	
	self.handleHovered = function() {
		var handle_x = self.getHandleX();
		var handle_y = self.getHandleY();
		var handle_radius = self.handleSize / 2;
		
		return point_in_circle(UI_MOUSE_X, UI_MOUSE_Y, handle_x, handle_y, handle_radius) && self.styles.pointerEvents;
	}
	
	// Override the parent's hovered function
	self.parent_hovered = self.hovered();
	self.hovered = function() {
		return self.parent_hovered || self.handleHovered();
	}
	
	// Override the parent's handle_events function
	self.handle_events = function() {
		// Update hover state
		var was_hovered = self.is_hovered;
		self.is_hovered = self.hovered();
		
		// Handle hover enter/exit
		if (self.is_hovered && !was_hovered) {
			window_set_cursor(self.styles.cursor);
			self.events.onHover(self);	
		} else if (!self.is_hovered && was_hovered) {
			window_set_cursor(cr_default);
			self.events.onLeave(self);	
		}
		
		// Handle mouse press
		if (self.pressed()) {
			self.is_pressed = true;
			self.is_focused = true;
			self.events.onFocus(self);
			
			// Update slider value when clicked
			self.updateValueFromMousePosition();
		}
		
		// Handle dragging
		if (self.is_pressed && mouse_check_button(mb_left)) {
			self.updateValueFromMousePosition();
		}
		
		// Handle mouse release
		if (self.released()) {
			self.is_pressed = false;
			if (self.is_hovered) {
				self.events.onReleased(self);
				self.events.onClick(self);
			} else {
				self.is_focused = false;	
			}
		}
	}
	
	self.updateValueFromMousePosition = function() {
		var percentage;
		
		if (self.isVertical) {
			var y1 = self.getY() + self.styles.translateY;
			var height = self.getHeight();
			var mouse_y_clamped = clamp(UI_MOUSE_Y, y1, y1 + height);
			// Invert percentage for vertical slider (bottom is 0%, top is 100%)
			percentage = 1 - ((mouse_y_clamped - y1) / height);
		} else {
			var x1 = self.getX() + self.styles.translateX;
			var width = self.getWidth();
			var mouse_x_clamped = clamp(UI_MOUSE_X, x1, x1 + width);
			percentage = (mouse_x_clamped - x1) / width;
		}
		
		var new_value = self.minValue + percentage * (self.maxValue - self.minValue);
		self.setValue(new_value);
	}
	
	self.draw_body = function() {
		var x1 = self.getX() + self.styles.translateX;
		var y1 = self.getY() + self.styles.translateY;
		var x2 = x1 + self.getWidth();
		var y2 = y1 + self.getHeight();
		
		// Draw background of slider
		draw_set_color(self.styles.backgroundColor);
		draw_set_alpha(self.styles.opacity);
		draw_roundrect_ext(x1, y1, x2, y2, self.styles.borderRadius, self.styles.borderRadius, false);
		
		// Get handle position
		var handle_x = self.getHandleX();
		var handle_y = self.getHandleY();
		
		// Draw filled portion of slider
		draw_set_color(self.styles.fill);
		draw_set_alpha(self.styles.fillOpacity);
		
		if (self.isVertical) {
			// For vertical slider, fill from handle position to bottom
			if (handle_y < y2) {
				draw_roundrect_ext(x1, handle_y, x2, y2, self.styles.borderRadius, self.styles.borderRadius, false);
			}
		} else {
			// For horizontal slider, fill from left to handle position
			if (handle_x > x1) {
				draw_roundrect_ext(x1, y1, handle_x, y2, self.styles.borderRadius, self.styles.borderRadius, false);
			}
		}
		
		// Handle Shadow
		if (self.draw_handle_shadow) {
			draw_set_color(self.styles.fill);
			draw_set_alpha(self.styles.fillOpacity * 0.2);
			draw_circle(handle_x, handle_y, self.handleSize, false);
		}
		
		// Draw handle
		draw_set_color(self.styles.fill);
		draw_set_alpha(self.styles.fillOpacity);
		draw_circle(handle_x, handle_y, self.handleSize / 2, false);
		
		// Draw handle border
		draw_set_color(self.styles.borderColor);
		draw_set_alpha(self.styles.borderOpacity);
		if (self.styles.border) {
			draw_circle(handle_x, handle_y, self.handleSize / 2, true);
		}
		
		// Reset to default
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	}
	#endregion
}