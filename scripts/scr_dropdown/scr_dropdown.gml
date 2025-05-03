/// @feather ignore all
function Dropdown(title = undefined, options = [], styles = {}, selectedIndex = 0, x = LAYOUT_AUTO, y = LAYOUT_AUTO ) : Component(x, y, styles) constructor {
	#region Properties
	self.options = options;
	self.selectedIndex = clamp(selectedIndex, 0, array_length(options) - 1);
	self.expanded = false;
	self.scrollOffset = 0;
	self.optionHeight = 20;
	self.surface = -1;
	self.title = title;
	self.isAboveAll = true;
	
	// Dropdown count
	static count = 0;
	count++;
	#endregion
	
	#region Styles
	self.defaultStyles = struct_merge(self.defaultStyles, {
		minWidth: 100,
		minHeight: 30,
		width: 150,
		height: 30,
		
		paddingInline: 10,
		
		opacity: 1,
		boxShadow: 0.2,
		cursor: cr_handpoint,
		
		textAlign: fa_left,
		textValign: fa_middle,
		
		border: true,
		borderColor: c_white,
		borderOpacity: 0.4,
		outline: false,
		
		maxHeight: 150,
		fontSize: 4,
		optionsOpacity: 1,
		
		zIndex:  -666 + count,
	});
	self.styles = struct_merge(self.defaultStyles, styles);
	#endregion
	
	var textStyle = {
		width: self.getWidth() - self.styles.fontSize * 4,
		height: self.getHeight(),
		
		textAlign: self.styles.textAlign,
		textValign: self.styles.textValign,
		
		paddingLeft: self.getPaddingLeft(),
		paddingTop: self.getPaddingTop(),
		marginBottom: self.getMarginBottom(),
		
		color: self.styles.color,
		
		zIndex: self.styles.zIndex - 1
	};
	
	var firstOption = array_length(options) > 0 ? options[self.selectedIndex] : ""
	
	self.text = new Text(
		self.title ?? firstOption,
		textStyle,
		self.getX(),
		self.getY()
	);
	array_push(self.children, self.text);
	
	#region Getters / Setters
	
	#region Getters
	self.getText = function() {
		return self.text;
	};
	
	self.getTitle = function() {
		return self.title;	
	}
	
	self.getSelectedOption = function() {
		return self.options[self.selectedIndex];
	};
	
	self.getValue = function() {
		return self.getSelectedOption();	
	}
	
	self.getSelectedIndex = function() {
		return self.selectedIndex;
	};
	
	self.getExpandedHeight = function() {
		var totalHeight = min(array_length(self.options) * self.optionHeight, self.styles.maxHeight);
		return totalHeight;
	};
	
	self.getMaxVisibleOptions = function() {
		return floor(self.styles.maxHeight / self.optionHeight);
	};
	
	self.getHeightInherited = self.getHeight;
	self.getHeight = function() {
		return self.expanded ? self.getHeightInherited() + self.getExpandedHeight() : self.getHeightInherited();	
	}
	#endregion
	
	#region Setters
	self.setText = function(text) {
		self.setTitle(text);
		return self;
	};
	
	self.setTitle = function(title) {
		self.title = title;
		self.text.setValue(title);
		return self;
	};
	
	self.setOptions = function(newOptions) {
		self.options = newOptions;
		self.selectedIndex = clamp(self.selectedIndex, 0, array_length(newOptions) - 1);
		self.setText(self.options[self.selectedIndex]);
		return self;
	};
	
	self.setSelectedIndex = function(index) {
		var prevIndex = self.selectedIndex;
		self.selectedIndex = clamp(index, 0, array_length(self.options) - 1);
		self.setText(self.options[self.selectedIndex]);
		
		if (prevIndex != self.selectedIndex) {
			self.events.onChange(self.options[self.selectedIndex]);
		}
		
		return self;
	};
	
	self.setSelectedOption = function(option) {
		for (var i = 0; i < array_length(self.options); i++) {
			if (self.options[i] == option) {
				self.setSelectedIndex(i);
				break;
			}
		}
		return self;
	};
	
	self.setExpanded = function(expanded) {
		self.expanded = expanded;
		return self;
	};
	#endregion
	
	#endregion
	
	#region Methods
	self.handle_events_inherited = self.handle_events;
	self.handle_events = function() {
		// Call parent handle_events method
		self.handle_events_inherited();
		
		// Handle scroll wheel when expanded
		if (self.expanded && self.hovered()) {
			var wheel = mouse_wheel_down() - mouse_wheel_up();
			if (wheel != 0) {
				self.scrollOffset = clamp(
					self.scrollOffset + wheel * self.optionHeight,
					0,
					max(0, array_length(self.options) * self.optionHeight - self.getExpandedHeight())
				);
			}
		}
		
		// Handle option selection
		if (self.expanded && mouse_check_button_pressed(mb_left)) {
			var mouseX = UI_MOUSE_X;
			var mouseY = UI_MOUSE_Y;
			var x1 = self.getX();
			var y1 = self.getY() + self.styles.height;

			var x2 = x1 + self.getWidth();
			var y2 = y1 + self.getExpandedHeight();
			
			
			if (point_in_rectangle(mouseX, mouseY, x1, y1, x2, y2)) {
				var relativeY = mouseY - y1 + self.scrollOffset;
				var clickedIndex = floor(relativeY / self.optionHeight);

				if (clickedIndex >= 0 && clickedIndex < array_length(self.options)) {
					var prevIndex = self.selectedIndex;
					self.selectedIndex = clickedIndex;
					self.setText(self.options[self.selectedIndex]);
					self.expanded = false;
					
					// Trigger onClick event
					self.events.onClick(self.options[self.selectedIndex]);
					
					// Trigger onChange event if the selection changed
					if (prevIndex != self.selectedIndex) {
						self.events.onChange(self.options[self.selectedIndex]);
					}
				}
			} else if (!self.hovered()) {
				// Click outside of dropdown closes it
				self.expanded = false;
			}
		}
		
		// Toggle expanded state when clicked
		if (self.pressed()) {
			self.expanded = !self.expanded;
			
			// When collapsing, ensure click events are not triggered for options
			if (!self.expanded) {
				exit;
			}
		}
		
		
	};
	
	self.create_surface = function() {
		var width = self.getWidth();
		var height = self.getExpandedHeight();
		
		if (!surface_exists(self.surface)) {
			self.surface = surface_create(width, height);
		} else if (surface_get_width(self.surface) != width || surface_get_height(self.surface) != height) {
			surface_free(self.surface);
			self.surface = surface_create(width, height);
		}
		
		return self.surface;
	};
	
	self.draw_options = function() {
		if (!self.expanded) exit;
		
		var surf = self.create_surface();
		if (surf == -1) exit;
		
		surface_set_target(surf);
		draw_clear_alpha(c_black, 0);
		
		var width = self.getWidth();
		var height = self.getHeight();
		var optionsCount = array_length(self.options);
		
		// Set text properties
		draw_set_font(self.styles.font);
		draw_set_valign(fa_middle);
		draw_set_halign(self.styles.textAlign);
		
		// Calculate visible options
		var startIndex = floor(self.scrollOffset / self.optionHeight);
		var endIndex = min(startIndex + ceil(height / self.optionHeight) + 1, optionsCount);
		
		// Draw options
		for (var i = startIndex; i < endIndex; i++) {
			var optionY = i * self.optionHeight - self.scrollOffset;
			var mouseY = UI_MOUSE_Y - (self.getY() + self.getHeight());
			var isHovered = point_in_rectangle(UI_MOUSE_X, UI_MOUSE_Y, 
				self.getX(), self.getY() + self.getHeight() + optionY, 
				self.getX() + width, self.getY() + self.getHeight() + optionY + self.optionHeight);
			
			// Draw highlight for hovered or selected option
			if (isHovered || i == self.selectedIndex) {
				draw_set_color(self.styles.fill);
				draw_set_alpha(self.styles.fillOpacity);
				draw_rectangle(0, optionY, width, optionY + self.optionHeight, false);
			}
			
			// Draw option text
			draw_set_color(self.styles.color);
			draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
			draw_text(
				self.getPaddingLeft(), 
				optionY + self.optionHeight / 2, 
				self.options[i]
			);
			
			// Draw separator
			draw_set_color(self.styles.borderColor);
			draw_set_alpha(0.3);
			draw_line(0, optionY + self.optionHeight, width, optionY + self.optionHeight);
		}
		
		// Draw scrollbar
		if (optionsCount * self.optionHeight > height) {
			var scrollbarWidth = 5;
			var scrollbarHeight = height * (height / (optionsCount * self.optionHeight));
			var scrollbarY = (self.scrollOffset / (optionsCount * self.optionHeight - height)) * (height - scrollbarHeight);
			
			draw_set_color(c_gray);
			draw_set_alpha(0.5);
			draw_rectangle(width - scrollbarWidth, scrollbarY, width, scrollbarY + scrollbarHeight, false);
		}
		
		surface_reset_target();
		
		// Draw the surface to the screen
		draw_surface(
			surf, 
			self.getX(), 
			self.getY() + self.getHeight()
		);
		
		// Reset drawing properties
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
		draw_set_valign(fa_top);
		draw_set_halign(fa_left);
	};
	
	self.draw_toggle_arrow = function() {
		var xx = self.getX() + self.getWidth() - self.styles.fontSize * 2 - self.getPaddingRight();
		var yy = self.getY() + self.styles.height / 2;
		var size = self.styles.fontSize;
		
		draw_set_color(self.styles.color);
		draw_set_alpha(self.styles.opacity);
		
		if (self.expanded) {
			// Up arrow when expanded
			draw_triangle(
				xx, yy + size,
				xx + size, yy - size,
				xx + size * 2, yy + size,
				false
			);
		} else {
			// Down arrow when collapsed
			draw_triangle(
				xx, yy - size,
				xx + size, yy + size,
				xx + size * 2, yy - size,
				false
			);
		}
		
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	};
	
	self.draw_body = function() {
		var x1 = self.getX() + self.styles.translateX;
		var y1 = self.getY() + self.styles.translateY;
		var x2 = x1 + self.getWidth();
		var y2 = y1 + self.getHeight();
		var headerY2 = y1 + self.styles.height; 
		
		// Draw dropdown background
		draw_set_color(self.styles.backgroundColor);
		draw_set_alpha(self.styles.opacity);
		
		draw_roundrect_ext(
			x1, y1, x2, y2, 
			self.styles.borderRadius, self.styles.borderRadius, 
			false
		);
		
		
		// Draw dropdown arrow
		self.draw_toggle_arrow();
		
		// Draw options if expanded
		if (self.expanded) {
			var optionsY1 = headerY2;
			var optionsY2 = optionsY1 + self.getExpandedHeight();
		
			// Draw options
			draw_set_font(self.styles.font);
			draw_set_valign(self.styles.textValign);
			draw_set_halign(self.styles.textAlign);
			
			// Calculate visible options
			var optionsCount = array_length(self.options);
			var startIndex = floor(self.scrollOffset / self.optionHeight);
			var visibleCount = floor(self.getExpandedHeight() / self.optionHeight);
			var endIndex = min(startIndex + visibleCount, optionsCount);
			
			// Draw options
			for (var i = startIndex; i < endIndex; i++) {
				var optionY = optionsY1 + i * self.optionHeight - self.scrollOffset;
				var isHovered = point_in_rectangle(UI_MOUSE_X, UI_MOUSE_Y, 
					x1, optionY, x2, optionY + self.optionHeight);
				
				// Draw highlight for hovered or selected option
				if (isHovered || i == self.selectedIndex) {
					draw_set_color(self.styles.fill);
					draw_set_alpha(self.styles.fillOpacity);
					draw_roundrect_ext(x1, optionY, x2, optionY + self.optionHeight, self.styles.borderRadius, self.styles.borderRadius, false);
				}
				
				// Draw option text
				draw_set_color(self.styles.color);
				draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
				draw_text(
					x1 + self.getPaddingLeft(), 
					optionY + self.optionHeight / 2, 
					self.options[i]
				);
				
				// Draw separator
				draw_set_color(self.styles.borderColor);
				draw_set_alpha(0.3);
				draw_line(x1, optionY + self.optionHeight, x2, optionY + self.optionHeight);
			}
			
			// Draw scrollbar
			if (optionsCount * self.optionHeight > self.getExpandedHeight()) {
				var scrollbarWidth = 5;
				var scrollbarHeight = self.getExpandedHeight() * 
					(self.getExpandedHeight() / (optionsCount * self.optionHeight));
				var scrollbarY = optionsY1 + 
					(self.scrollOffset / (optionsCount * self.optionHeight - self.getExpandedHeight())) * 
					(self.getExpandedHeight() - scrollbarHeight);
				
				draw_set_color(c_gray);
				draw_set_alpha(0.5);
				draw_rectangle(x2 - scrollbarWidth, scrollbarY, x2, scrollbarY + scrollbarHeight, false);
			}
		}
		
		// Reset to default
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
		draw_set_valign(fa_top);
		draw_set_halign(fa_left);
	};
	
	self.cleanup = function() {
		if (surface_exists(self.surface)) {
			surface_free(self.surface);
			self.surface = -1;
		}
	};
	#endregion
}