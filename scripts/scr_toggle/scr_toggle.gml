/// @feather ignore all
function Toggle(text, styles = {}, x = LAYOUT_AUTO, y = LAYOUT_AUTO ) : Checkbox(text, styles, x, y) constructor {
	#region Properties
	self.knobSize = 12;
	#endregion
	
	#region Styles
	self.defaultStyles = struct_merge(self.defaultStyles, {
		width: 32, 
		height: 16,
		
		// Override checkbox styles
		borderRadius: 8, 
		fill: c_green, 
	});
	self.styles = struct_merge(self.defaultStyles, styles);
	#endregion
	
	// Reposition the text component to account for wider toggle
	
	self.text.setStyle("paddingLeft", self.getWidth() + 10)
	
	
	#region Methods
	// Override the draw_body method to create toggle appearance
	self.draw_body = function() {
		var x1 = self.getX() + self.styles.translateX;
		var y1 = self.getY() + self.styles.translateY;
		var x2 = x1 + self.getWidth();
		var y2 = y1 + self.getHeight();
		
		// Draw the background track
		draw_set_alpha(self.checked ? self.styles.fillOpacity : self.styles.opacity);
		draw_set_color(self.checked ? self.styles.fill : self.styles.backgroundColor);
		draw_roundrect_ext(x1, y1, x2, y2, self.styles.borderRadius, self.styles.borderRadius, false);
		
		// Calculate knob position (slides from left to right based on checked state)
		var knobPadding = (self.getHeight() - self.knobSize) / 2;
		var knobX = self.checked ? 
			x2 - self.knobSize - knobPadding : 
			x1 + knobPadding;
		var knobY = y1 + knobPadding;
		
		// Draw the knob/handle
		draw_set_color(self.styles.borderColor);
		draw_circle(knobX + self.knobSize/2, knobY + self.knobSize/2, self.knobSize/2, false);
		
		// Reset to default
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	}
	
	self.setKnobSize = function(size) {
		self.knobSize = size;
		return self;
	}
	
	// Toggle active color uses the fill style
	self.setActiveColor = function(color) {
		self.setStyle("fill", color);
		return self;
	}
	
	// Toggle inactive color uses the backgroundColor style
	self.setInactiveColor = function(color) {
		self.setStyle("backgroundColor", color);
		return self;
	}
	
	// Toggle knob color uses the borderColor style
	self.setKnobColor = function(color) {
		self.setStyle("borderColor", color);
		return self;
	}
	#endregion
}