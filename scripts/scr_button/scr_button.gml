/// @feather ignore all
function Button(text, styles = {}, x = LAYOUT_AUTO, y = LAYOUT_AUTO) : Component(x, y, styles) constructor {
	#region Properties
	self.value = text;
	#endregion
	
	#region Styles
	self.defaultStyles = struct_merge(self.defaultStyles, {
		minWidth: string_width(self.value),
		minHeight: string_height(self.value),
		width: string_width(self.value),
		height: string_height(self.value),
		
		paddingInline: 10,
		paddingBlock: 5,
		
		opacity: 1,
		boxShadow: 0.2,
		cursor: cr_handpoint,
		
		textAlign: fa_middle,
		textValign: fa_center,
		
		border: true,
		borderColor: c_white,
		borderOpacity: 0.4,
		outline: false,
	});
	self.styles = struct_merge(self.defaultStyles, styles)
	#endregion
	
	var textStyle = {
		width: self.getWidth(),
		height: self.getHeight(),
		
		textAlign: self.styles.textAlign,
		textValign: self.styles.textValign,
		
		color: self.styles.color,
		
		zIndex: self.styles.zIndex - 1
	}
	self.text = new Text(self.value, textStyle, self.getX(), self.getY());
	array_push(self.children, self.text)
	
	#region Getters / Setters
	
	#region Getters
	self.getText = function() {
		return self.text;	
	}
	#endregion
	
	#region Setters

	
	self.setText = function(text) {
		self.value = text;
		self.text.value = text;
		return self;
	}
	#endregion
	
	#endregion
	
	#region States
	
	self.setOnHover(function() {
		self.setStyle("translateY", -1);
		self.text.setStyle("translateY", -1);
	})
	
	self.setOnLeave(function() {
		self.setStyle("translateY", 1);
		self.text.setStyle("translateY", 1);
	})
	
	self.setOnFocus(function() {
		self.setStyle("translateY", 1);
		self.text.setStyle("translateY", 1);
	})
	
	self.setOnReleased(function() {
		self.events.onHover();
	});
	
	#endregion
	
	#region Methods
	self.draw_body = function() {	
		var x1 = self.getX() + self.styles.translateX;
		var y1 = self.getY() + self.styles.translateY;
		var x2 = x1 + self.getWidth();
		var y2 = y1 + self.getHeight();
		
		draw_set_alpha(self.styles.opacity);
		
		// Button background
		draw_set_color(self.styles.backgroundColor);
		draw_set_alpha(self.styles.opacity);
		draw_roundrect_ext(x1, y1, x2, y2, self.styles.borderRadius, self.styles.borderRadius, false);

		// Reset to default
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	}
	#endregion
}