///@feather ignore all

function Text(text, styles = {}, x = LAYOUT_AUTO, y = LAYOUT_AUTO) : Component(x, y, styles) constructor {
	#region Properties
	self.value = text;
	#endregion
	
	#region Styles
	self.defaultStyles = struct_merge(self.defaultStyles, {
		width: string_width(self.value),
		height: string_height(self.value),
		
		opacity: 1,
		
		border: false,
		outline: false,
		
		zIndex: 1,
		pointerEvents: false,
	});
	self.styles = struct_merge(self.defaultStyles, styles)
	#endregion
	
	self.getValue = function() {
		return self.value;	
	}
	
	self.setValue = function(value) {
		self.value = value;
		return self;
	}
	
	#region Methods
	
	self.draw_body = function() {
		var halign = self.styles.textAlign;
		var valign = self.styles.textValign;
		
		var align_horizontally = (halign == fa_middle || halign == fa_center);
		var align_vertically = (valign == fa_middle || valign == fa_center);
		var horizontal_offset = align_horizontally * (self.getWidth() / 2);
		var vertical_offset = align_vertically * (self.getHeight() / 2);
		
		if (halign == fa_left) horizontal_offset = 0;
		if (halign == fa_right) horizontal_offset = self.getWidth();
		
		if (valign == fa_top) vertical_offset = 0;
		if (valign == fa_bottom) vertical_offset = self.getHeight();
		
		var draw_x = self.getX() + self.getPaddingLeft() + self.styles.translateX + horizontal_offset;
		var draw_y = self.getY() + self.getPaddingTop() + self.styles.translateY + vertical_offset;
		
		
		draw_set_halign(halign);
		draw_set_valign(valign);
		
		draw_set_color(self.styles.color);
		draw_set_alpha(self.styles.opacity);
		draw_set_font(self.styles.font);
		
		draw_text_ext_transformed(
		draw_x, draw_y,
		self.value,
		self.styles.lineHeight,
		self.getWidth(),
		self.styles.scale, self.styles.scale,
		self.styles.rotate);
		
		// Decorations
		var text_width = string_width_ext(self.value, self.styles.lineHeight, self.getWidth()) * self.styles.scale;
		var text_height = string_height_ext(self.value, self.styles.lineHeight, self.getWidth()) * self.styles.scale;
	
		draw_set_color(self.styles.textDecorationColor);
		switch (self.styles.textDecoration) {
			case TEXT_DECORATION.UNDERLINE: {
				var yy = draw_y + text_height / 2 + 2 * self.styles.scale;
				var x1 = draw_x - text_width / 2;
				var x2 = draw_x + text_width / 2;
				draw_line(x1, yy, x2, yy);
				break;
			}
			case TEXT_DECORATION.OVERLINE: {
				var yy = draw_y - text_height / 2 - 2 * self.styles.scale;
				var x1 = draw_x - text_width / 2;
				var x2 = draw_x + text_width / 2;
				draw_line(x1, yy, x2, yy);
				break;
			}
			case TEXT_DECORATION.LINE_THROUGH: {
				var yy = draw_y;
				var x1 = draw_x - text_width / 2;
				var x2 = draw_x + text_width / 2;
				draw_line(x1, yy, x2, yy);
				break;
			}
			case TEXT_DECORATION.HIGHLIGHT: {
				draw_set_alpha(self.styles.opacity * 0.5);
				var xx = draw_x - text_width / 2;
				var yy = draw_y - text_height / 2;
				draw_rectangle(xx, yy, xx + text_width, yy + text_height, false);
				
				draw_set_alpha(self.styles.opacity);
				break;
			}
			
			case TEXT_DECORATION.LIST: {
				var bullet_radius = 3 * self.styles.scale;
				var paddingLeft = 10;
				var bullet_x = draw_x - self.getPaddingLeft() - self.getMarginLeft() - paddingLeft;
				var bullet_y = draw_y + self.styles.lineHeight / 2;
				
				self.setStyle("translateX", paddingLeft)

				draw_set_color(c_white);
				draw_circle(bullet_x, bullet_y, bullet_radius, false);
			} break;
		}
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
	}
	
	self.draw_shadow = function() {
		// Dont	
	}
	
	self.draw_border = function() {
		// Dont	
	}
	
	#endregion
}