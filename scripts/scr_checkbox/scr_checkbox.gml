/// @feather ignore all
function Checkbox(text, styles = {}, x = LAYOUT_AUTO, y = LAYOUT_AUTO) : Component(x, y, styles) constructor {
	#region Properties
	self.value = text;
	self.checked = false;
	#endregion
	
	#region Styles
	self.defaultStyles = struct_merge(self.defaultStyles, {
		width: 16,
		height: 16,
		padding: 2,
		
		opacity: 1,
		boxShadow: 0.2,
		cursor: cr_handpoint,
		
		textAlign: fa_left,
		textValign: fa_center,
		
		border: true,
		borderColor: c_white,
		borderOpacity: 0.4,
		outline: false,
		fill: c_green,
	});
	self.styles = struct_merge(self.defaultStyles, styles)
	#endregion
	
	var textStyle = {
		height: self.getHeight(),
		paddingLeft: self.getWidth() + 10,
		
		textAlign: self.styles.textAlign,
		textValign: self.styles.textValign,
		
		marginBottom: self.getMarginBottom(),
		marginRight: self.getMarginRight(),

		color: self.styles.color,
		
		zIndex: self.styles.zIndex - 1
	}
	self.text = new Text(self.value, textStyle, self.getX(), self.getY());
	array_push(self.children, self.text);
	
	#region Getters / Setters
	
	#region Getters
	self.getChecked = function() {
		return self.checked;	
	}
	
	self.getText = function() {
		return self.text;	
	}
	#endregion
	
	#region Setters
	self.setChecked = function(checked) {
		self.checked = checked;
		return self;
	}
	
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
		self.toggle();
	});
	
	
	#endregion
	
	#region Methods
	self.toggle = function() {
		self.checked = !self.checked;
	}
	
	self.draw_body = function() {	
		var x1 = self.getX() + self.styles.translateX;
		var y1 = self.getY() + self.styles.translateY;
		var x2 = x1 + self.getWidth();
		var y2 = y1 + self.getHeight();
		
		
		// Checkbox background
		draw_set_color(self.checked? self.styles.fill : self.styles.backgroundColor);
		draw_set_alpha(self.checked ? self.styles.fillOpacity : self.styles.opacity);
		draw_roundrect_ext(x1, y1, x2, y2, self.styles.borderRadius, self.styles.borderRadius, false);

		// Reset to default
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	}
	#endregion
}