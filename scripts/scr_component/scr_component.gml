/// @feather ignore all
function Component(x, y, styles = {}) constructor {
	ui_add_component(self);
	
	switch (x) {
		case LAYOUT_AUTO:	self.x = ui_get_auto_x(); break;
		case LAYOUT_INLINE:	self.x = ui_get_inline_x(); break;
		default: self.x = x;
	}
	
	switch (y) {
		case LAYOUT_AUTO:	self.y = ui_get_auto_y(); break;
		case LAYOUT_INLINE:	self.y = ui_get_inline_y(); break;
		default: self.y = y;
	}
	
	#region Properties
	self.children = [];
	
	self.visible = true;
	self.enabled = true;
	self.isAboveAll = false;
	#endregion
	
	#region States
	is_hovered = false;
	is_pressed = false;
	is_focused = false;
	#endregion
	
	#region Events
	self.events = {
		onHover:	UI_DEFAULT_EVENT,
		onLeave:	UI_DEFAULT_EVENT,
		onClick:	UI_DEFAULT_EVENT,
		onReleased:	UI_DEFAULT_EVENT,
		onFocus:	UI_DEFAULT_EVENT,
		onBlur:		UI_DEFAULT_EVENT,
		onChange:	UI_DEFAULT_EVENT,
	}
	#endregion
	
	#region	Styles
	self.defaultStyles = {
		color: UI_DEFAULT_DRAW_COLOR,
		fill: c_green,
		backgroundColor: UI_DEFAULT_BACKGROUND_COLOR,
		opacity: UI_DEFAULT_DRAW_OPACITY,
		fillOpacity: UI_DEFAULT_DRAW_OPACITY,
		
		handleFill: undefined,
		handleOpacity: undefined,
		
		width: 0,
		heihgt: 0,
		minWidth: 0,
		minHeight: 0,
		maxWidth: infinity,
		maxHeight: infinity,
		
		border: true,
		borderRadius: 4,
		borderColor: c_black,
		borderOpacity: UI_DEFAULT_DRAW_OPACITY,
		
		boxShadow: false,
		boxShadowColor: c_black,
		boxShadowOffset: 4,
		
		outline: true,
		outlineColor: c_yellow,
		outlineOpacity: UI_DEFAULT_DRAW_OPACITY,
		
		font: UI_DEFAULT_FONT,
		fontSize: 12,
		textDecoration: TEXT_DECORATION.NONE,
		textDecorationColor: UI_DEFAULT_DRAW_COLOR,
		textAlign: fa_left,
		textValign: fa_top,
		lineHeight: 12,
		
		margin: 0,
		marginBlock: undefined,
		marginInline: undefined,
		marginLeft: undefined,
		marginRight: undefined,
		marginTop: undefined,
		marginBottom: undefined,
		
		padding: 0,
		paddingBlock: undefined,
		paddingInline: undefined,
		paddingLeft: undefined,
		paddingRight: undefined,
		paddingTop: undefined,
		paddingBottom: undefined,
		
		scale: 1,
		rotate: 0,
		translateX: 0,
		translateY: 0,
		
		flexDirection: FLEX_DIRECTION.ROW,
		gap: 5,
		
		zIndex: ui_get_auto_z(),
		cursor: cr_default,
		pointerEvents: true,
	};
	
	self.styles = struct_merge(defaultStyles, styles);
	#endregion
	
	#region Getters / Setters
	
	#region Getters
	self.getX = function() {	
		return (self.x) + self.getMarginLeft();
	};
	self.getY = function() {	
		return (self.y) + self.getMarginTop();
	};
	
	self.getWidth = function() {
		var margin		= self.getMarginRight();
		var padding		= self.getPaddingLeft() + self.getPaddingRight();
		var width		= self.styles.width + padding;
		var min_width	= self.styles.minWidth + padding;
		var max_width	= self.styles.maxWidth - margin;
		return clamp(width, min_width, max_width);	
	}
	
	self.getHeight = function() {
		var margin = self.getMarginBottom();
		var padding = self.getPaddingTop() + self.getPaddingBottom();
		var height = self.styles.height + padding;
		var min_height = self.styles.minHeight + padding;
		var max_height = self.styles.maxHeight - margin;
		return clamp(height,min_height, max_height);
	}
	
	self.getMarginLeft = function() {
		return (self.styles.marginLeft ?? self.styles.marginInline ?? self.styles.margin);
	}
	
	self.getMarginRight = function() {
		return (self.styles.marginRight ?? self.styles.marginInline ?? self.styles.margin);
	}
	
	self.getMarginTop = function() {
		return (self.styles.marginTop ?? self.styles.marginBlock ?? self.styles.margin);	
	}
	
	self.getMarginBottom = function() {
		return (self.styles.marginBottom ?? self.styles.marginBlock ?? self.styles.margin);	
	}
	
	self.getPaddingLeft = function() {
		return (self.styles.paddingLeft ?? self.styles.paddingInline ?? self.styles.padding);	
	}
	
	self.getPaddingRight = function() {
		return (self.styles.paddingRight ?? self.styles.paddingInline ?? self.styles.padding);	
	}
	
	self.getPaddingTop = function() {
		return (self.styles.paddingTop ?? self.styles.paddingBlock ?? self.styles.padding);	
	}
	
	self.getPaddingBottom = function() {
		return (self.styles.paddingBottom ?? self.styles.paddingBlock ?? self.styles.padding);	
	}
	#endregion
	#region Setters
	self.setX = function(x) {	
		self.x = x + self.getMarginLeft();
		self.setChildrenProperty("x", self.x);
		return self
	};
	self.setY = function(y) {	
		self.y = y + self.getMarginTop();
		self.setChildrenProperty("y", self.y);
		return self
	};
	
	self.setVisible = function(visible) {	
		self.visible = visible;
		return self;
	};
	
	self.setEnabled = function(enabled) {
		self.enabled = enabled;
		return self;
	}
	
	self.setOnClick = function(onClick) {
		self.events.onClick = onClick;	
		return self;
	}
	
	self.setOnHover = function(onHover) {
		self.events.onHover = onHover;
		return self;
	}
	
	self.setOnLeave = function(onLeave) {
		self.events.onLeave = onLeave;
		return self;
	}
	
	self.setOnFocus = function(onFocus) {
		self.events.onFocus = onFocus;
		return self;
	}
	
	self.setOnReleased = function(onPressed) {
		self.events.onReleased = onPressed;
		return self;
	}
	
	self.setOnChange = function(onChange) {
		self.events.onChange = onChange;
		return self;
	}
	
	self.setStyle = function(key, value) {
		if (variable_struct_exists(self.styles, key)) {
			variable_struct_set(self.styles, key, value)	
		}
		return self;
	}
	
	self.setStyles = function(styles) {
		self.styles = struct_merge(self.styles, styles);
		return self;
	}
	
	self.setChildrenStyle = function(key, value) {
		for (var i = 0; i < array_length(self.children); i++) {
			var child = self.children[i];
			child.setStyle(key, value);
		}
	}
	
	self.setChildrenStyles = function(childrenStyles) {
		for (var i = 0; i < array_length(self.children); i++) {
			var child = self.children[i];
			child.setStyles(childrenStyles);
		}
	}
	
	self.setChildrenProperty = function(key, value) {
		for (var i = 0; i < array_length(self.children); i++) {
			variable_struct_set(self.children[i], key, value)
		}	
	}
	
	#endregion
	
	#endregion

	#region Methods
	
	self.hovered = function() {
		var x1 = self.getX();
		var y1 = self.getY();
		var x2 = x1 + self.getWidth();
		var y2 = y1 + self.getHeight();
		return point_in_rectangle(UI_MOUSE_X, UI_MOUSE_Y, x1, y1, x2, y2) && self.styles.pointerEvents;	
	}
	
	self.pressed = function() {
		return self.hovered() && mouse_check_button_pressed(mb_left);
	}
	
	self.released = function() {
		return self.is_pressed && mouse_check_button_released(mb_left)
	}
	
	self.handle_events = function() {
		// Update hover state
		var was_hovered = self.is_hovered;
		self.is_hovered = hovered();
		
		// Handle hover enter/exit
		if (self.is_hovered && !was_hovered) {
			window_set_cursor(self.styles.cursor);
			self.events.onHover(self);	
		} else if (!self.is_hovered && was_hovered) {
			window_set_cursor(cr_default);
			self.events.onLeave(self);	
		}
		
		// Handle mouse press
		if (pressed()) {
			self.is_pressed = true;
			self.is_focused = true;
			self.events.onFocus(self);
		}
		
		if (mouse_check_button_released(mb_left)) && (!is_hovered) {
			self.is_focused = false;	
		}
		
		// Handle mouse release
		if (self.released()) {
			self.is_pressed = false;
			if (is_hovered) {
				self.events.onReleased(self);
				self.events.onClick(self);		
			} 
		}	
	}
	
	self.run = function() {
		if (!self.enabled || !self.visible) exit;
		
		self.handle_events();
	}
	
	self.draw = function() {
		if (!self.visible) exit;
		
		self.draw_shadow();
		self.draw_body();
		self.draw_border();
		self.draw_outline();
	}
	
	self.draw_shadow = function() {
		if (self.styles.boxShadow <= 0) exit;
		
		var x1 = self.getX() + self.styles.translateX;
		var y1 = self.getY() + self.styles.translateY;
		var x2 = x1 + self.getWidth();
		var y2 = y1 + self.getHeight();
		
		var shadow_offset = self.styles.boxShadowOffset;

		draw_set_color(self.styles.boxShadowColor);
		draw_set_alpha(self.styles.boxShadow);
		draw_roundrect_ext(
			x1 + shadow_offset, y1 + shadow_offset,
			x2 + shadow_offset, y2 + shadow_offset,
			self.styles.borderRadius, self.styles.borderRadius,
			false
		);
	}
	
	self.draw_body = function() {
		// Overriden by children
	}
	
	self.draw_border = function() {
		if (!self.styles.border) exit;
		
		var x1 = self.getX() + self.styles.translateX;
		var y1 = self.getY() + self.styles.translateY;
		var x2 = x1 + self.getWidth();
		var y2 = y1 + self.getHeight();
		
		draw_set_color(self.styles.borderColor);
		draw_set_alpha(self.styles.borderOpacity);
		
		draw_roundrect_ext(x1, y1, x2, y2, self.styles.borderRadius, self.styles.borderRadius, true);
		
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	}
	
	self.draw_outline = function() {
		if (!self.styles.outline || !self.is_focused) exit;
		
		var x1 = self.getX() + self.styles.translateX;
		var y1 = self.getY() + self.styles.translateY;
		var x2 = x1 + self.getWidth();
		var y2 = y1 + self.getHeight();
		
		draw_set_color(self.styles.outlineColor);
		draw_set_alpha(self.styles.outlineOpacity);
		
		draw_roundrect_ext(x1, y1, x2, y2, self.styles.borderRadius, self.styles.borderRadius, true);
		
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
	}
	
	self.cleanup = function() { 
		// Overriden by children	
	}
	
	#endregion
}