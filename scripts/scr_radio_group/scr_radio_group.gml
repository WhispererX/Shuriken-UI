/// @feather ignore all
function RadioGroup(options = [], styles = {}, x = LAYOUT_AUTO, y = LAYOUT_AUTO) : Component(x, y, styles) constructor {
	#region Properties
	self.options = options;
	self.value = undefined;
	#endregion
	
	#region Styles
	self.defaultStyles = struct_merge(self.defaultStyles, {
		width: 0,
		height: 0,
		
		gap: 16,
		flexDirection: FLEX_DIRECTION.COLUMN,
		
		textAlign: fa_center,
		textValign: fa_middle,
		
		pointerEvents: false,
		border: false,
	});
	self.styles = struct_merge(self.defaultStyles, styles);
	#endregion
	
	
	#region Methods
	self.init = function() {
		var isRow = self.styles.flexDirection == FLEX_DIRECTION.ROW;
		var gap = self.styles.gap;
		
		var radioStyles = {
			color: self.styles.color,
			textAlign: self.styles.textAlign,
			textValign: self.styles.textValign,
		}
		
		for (var i = 0; i < array_length(self.options); i++) {
		    
			var radio = new Radio(self.options[i], radioStyles, self.getX(), self.getY());
			radio.setX(self.getX() + (isRow ? (i * (radio.getWidth() + gap)) : 0));
			radio.setY(self.getY() + (isRow ? 0 : (i * (radio.getHeight() + gap))));
			radio.group = self;
			array_push(self.children, radio);
		}	
	}
	#endregion
	
	self.init();
}