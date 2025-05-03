/// @feather ignore all
function Input(placeholder = "", styles = {}, type = INPUT_TYPE.TEXT, x = LAYOUT_AUTO, y = LAYOUT_AUTO) : Component(x, y, styles) constructor {
	#region Properties
	self.placeholder = placeholder;
	self.type = type;
	self.value = "";
	self.dot = "x";
	
	self.drawCursor = false;
	self.cursorSpeed = 30;
	self.cursorPos = 0;
	self.cursorBlinkTimer = 0;
	
	self.selectionStart = -1;
	self.selectionEnd = -1;
	
	self.surface = -1;
	self.surfaceWidth = 0;
	self.surfaceHeight = 0;
	self.textOffset = 0;
	
	self.isMouseDragging = false;
	self.mouseDragStart = -1;
	
	// Key repeat handling
	self.keyRepeatTimer = 0;
	self.keyRepeatDelay = UI_INPUT_DELAY;
	self.keyRepeatSpeed = UI_INPUT_REPEAT;
	self.lastKeyPressed = -1;
	#endregion
	
	#region Styles
	self.defaultStyles = struct_merge(self.defaultStyles, {
		minWidth: 100,
		minHeight: 16,
		width: 150,    
		height: 20, 
		
		paddingInline: 10,
		paddingBlock: 5,
		
		opacity: .7,
		boxShadow: 0,
		cursor: cr_beam,
		
		border: true,
		borderColor: c_white,
		borderOpacity: 0.4,
		outline: true,
		
		color: c_white,
		fill: c_aqua,
		fillOpacity: 0.6,
	});
	self.styles = struct_merge(self.defaultStyles, styles)
	#endregion
	
	#region Getters / Setters
	
	#region Getters
	self.getText = function() {
		return self.value;	
	}
	
	self.getCursorPositionFromX = function(mouseX) {
		var textX = self.getX() + self.getPaddingLeft() - self.textOffset;
		var textWidth = 0;
		var chars = string_length(self.value);
		
		// Check if click is at the very beginning
		if (mouseX <= textX) {
			return 0;
		}
		
		// Find the character position based on width
		for (var i = 1; i <= chars; i++) {
			textWidth = string_width(string_copy(self.value, 1, i));
			if (mouseX <= textX + textWidth) {
				// Check if we should select this char or the previous one
				var prevWidth = (i > 1) ? string_width(string_copy(self.value, 1, i-1)) : 0;
				if (mouseX - (textX + prevWidth) < (textX + textWidth) - mouseX) {
					return i-1;
				} else {
					return i;
				}
			}
		}
		
		// Click is after the text
		return chars;
	}
	
	self.getVisibleTextRange = function() {
		var visibleWidth = self.getWidth() - (self.getPaddingLeft() + self.getPaddingRight());
		var start = 1;
		var finish = string_length(self.value);
	
		// If text is shorter than visible area, just return the full range
		if (string_width(self.value) <= visibleWidth) {
			self.textOffset = 0;
			return {start: start, finish: finish};
		}
	
		// Adjust offset to ensure cursor is visible
		var cursorX = string_width(string_copy(self.value, 1, self.cursorPos));
		var padding = visibleWidth * 0.15;
	
		// If cursor is to the left of the visible area
		if (cursorX < self.textOffset + padding) {
			self.textOffset = max(0, cursorX - padding);
		}
		// If cursor is to the right of the visible area
		else if (cursorX > self.textOffset + visibleWidth - padding) {
			self.textOffset = cursorX - visibleWidth + padding;
		}
	
		// Find first visible character
		var widthSoFar = 0;
		for (var i = 1; i <= finish; i++) {
			widthSoFar = string_width(string_copy(self.value, 1, i));
			if (widthSoFar >= self.textOffset) {
				start = i;
				break;
			}
		}
	
		// Find last visible character
		for (var i = start; i <= finish; i++) {
			widthSoFar = string_width(string_copy(self.value, 1, i)) - self.textOffset;
			if (widthSoFar > visibleWidth) {
				finish = i - 1;
				break;
			}
		}
	
		return {start: start, finish: finish};
	}
	#endregion
	
	#region Setters

	self.setText = function(text) {
		// Filter input based on type
		if (self.type == INPUT_TYPE.DIGITS) {
			var filtered = "";
			for (var i = 1; i <= string_length(text); i++) {
				var char = string_char_at(text, i);
				if (string_digits(char) == char) {
					filtered += char;
				}
			}
			text = filtered;
		}
		
		self.value = text;
		self.cursorPos = min(self.cursorPos, string_length(self.value));
		self.events.onChange(text);
		self.getVisibleTextRange(); 
		return self;
	}
	
	self.setCursorPos = function(pos) {
		self.cursorPos = clamp(pos, 0, string_length(self.value));
		self.cursorBlinkTimer = 0;
		self.drawCursor = true;
		self.getVisibleTextRange();
		return self;
	}
	
	self.setSelection = function(start, finish) {
		self.selectionStart = max(0, start);
		self.selectionEnd = min(string_length(self.value), finish);
		return self;
	}
	
	self.clearSelection = function() {
		self.selectionStart = -1;
		self.selectionEnd = -1;
		return self;
	}
	#endregion
	
	#endregion
	
	#region Methods
	self.handle_events = function() {
		// Call parent event handler
		self.handle_events_super();
		
		if (!self.enabled || !self.visible) exit;
		
		// Handle focus/cursor management
		if (self.is_focused) {
			// Cursor blink effect
			self.cursorBlinkTimer += 1;
			if (self.cursorBlinkTimer >= self.cursorSpeed) {
				self.drawCursor = !self.drawCursor;
				self.cursorBlinkTimer = 0;
			}
			
			// Mouse press for cursor positioning
			if (mouse_check_button_pressed(mb_left) && self.is_hovered) {
				self.setCursorPos(self.getCursorPositionFromX(UI_MOUSE_X));
				self.clearSelection();
				self.isMouseDragging = true;
				self.mouseDragStart = self.cursorPos;
			}
			
			// Mouse drag for text selection
			if (mouse_check_button(mb_left) && self.isMouseDragging) {
				var currentDragPos = self.getCursorPositionFromX(UI_MOUSE_X);
				if (currentDragPos != self.cursorPos) {
					self.setCursorPos(currentDragPos);
					
					// Set selection range
					if (self.mouseDragStart <= self.cursorPos) {
						self.setSelection(self.mouseDragStart, self.cursorPos);
					} else {
						self.setSelection(self.cursorPos, self.mouseDragStart);
					}
				}
			}
			
			// End mouse drag
			if (mouse_check_button_released(mb_left)) {
				self.isMouseDragging = false;
			}
			
			// Handle keyboard input
			self.handle_keyboard_input();
		} else {
			self.drawCursor = false;
		}
	}
	
	// Override parent method to avoid conflicts
	self.handle_events_super = function() {
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
		}
		
		if (mouse_check_button_released(mb_left) && (!self.is_hovered)) {
			self.is_focused = false;
			self.clearSelection();
		}
		
		// Handle mouse release
		if (self.released()) {
			self.is_pressed = false;
			if (self.is_hovered) {
				self.events.onReleased(self);
				self.events.onClick(self);		
			} 
		}	
	}
	
	self.handle_keyboard_input = function() {
	    if (!self.is_focused) exit;
    
	    // Get the last character input
	    var lastchar = keyboard_lastchar;
	    keyboard_lastchar = ""; // Clear the buffer after reading
    
	    // Handle special keys separately
	    var key_event = keyboard_check_pressed(vk_anykey);
	    var ctrl_pressed = keyboard_check(vk_control);
	    var shift_pressed = keyboard_check(vk_shift);
    
	    // Handle key repeat for special keys (arrows, backspace, delete)
	    if (keyboard_check(vk_left) || keyboard_check(vk_right) || 
	        keyboard_check(vk_backspace) || keyboard_check(vk_delete) ||
	        keyboard_check(vk_home) || keyboard_check(vk_end)) {
        
	        if (self.lastKeyPressed == keyboard_key) {
	            self.keyRepeatTimer++;
	            if (self.keyRepeatTimer == self.keyRepeatDelay || 
	                (self.keyRepeatTimer > self.keyRepeatDelay && self.keyRepeatTimer % self.keyRepeatSpeed == 0)) {
	                key_event = true;
	            }
	        } else {
	            self.lastKeyPressed = keyboard_key;
	            self.keyRepeatTimer = 0;
	        }
	    } else if (keyboard_check_released(vk_anykey)) {
	        self.lastKeyPressed = -1;
	        self.keyRepeatTimer = 0;
	    }
    
	    // Handle keyboard shortcuts
	    if (key_event && ctrl_pressed) {
	        // Select all (Ctrl+A)
	        if (keyboard_check(ord("A"))) {
	            self.setSelection(0, string_length(self.value));
	            self.setCursorPos(string_length(self.value));
	            return;
	        }
	        // Copy (Ctrl+C)
	        else if (keyboard_check(ord("C")) && self.selectionStart != -1) {
	            var selected_text = string_copy(
	                self.value, 
	                self.selectionStart + 1, 
	                self.selectionEnd - self.selectionStart
	            );
	            clipboard_set_text(selected_text);
	            return;
	        }
	        // Paste (Ctrl+V)
	        else if (keyboard_check(ord("V"))) {
	            var clipboard_text = clipboard_get_text();
            
	            // Filter clipboard text for digit-only type
	            if (self.type == INPUT_TYPE.DIGITS) {
	                clipboard_text = string_digits(clipboard_text);
	            }
            
	            // Delete selected text if there's a selection
	            if (self.selectionStart != -1) {
	                var before = string_copy(self.value, 1, self.selectionStart);
	                var after = string_copy(self.value, self.selectionEnd + 1, string_length(self.value) - self.selectionEnd);
                
	                // Save cursor position before changing text
	                var newCursorPos = self.selectionStart + string_length(clipboard_text);
                
	                self.setText(before + clipboard_text + after);
	                self.setCursorPos(newCursorPos);
	                self.clearSelection();
	            } else {
	                var before = string_copy(self.value, 1, self.cursorPos);
	                var after = string_copy(self.value, self.cursorPos + 1, string_length(self.value) - self.cursorPos);
                
	                // Save cursor position before changing text
	                var newCursorPos = self.cursorPos + string_length(clipboard_text);
                
	                self.setText(before + clipboard_text + after);
	                self.setCursorPos(newCursorPos);
	            }
	            return;
	        }
	    }
    
	    // Handle navigation keys
	    if (key_event) {
	        // Left arrow
	        if (keyboard_check(vk_left)) {
	            if (self.cursorPos > 0) {
	                if (ctrl_pressed) {
	                    // Move to start of previous word
	                    var pos = self.cursorPos - 1;
	                    while (pos > 0 && string_char_at(self.value, pos) == " ") {
	                        pos--;
	                    }
	                    while (pos > 0 && string_char_at(self.value, pos) != " ") {
	                        pos--;
	                    }
	                    self.setCursorPos(pos);
	                } else {
	                    self.setCursorPos(self.cursorPos - 1);
	                }
	                if (!shift_pressed) {
	                    self.clearSelection();
	                } else if (self.selectionStart == -1) {
	                    self.setSelection(self.cursorPos + 1, self.cursorPos);
	                } else {
	                    // Update selection
	                    if (self.cursorPos < self.selectionStart) {
	                        self.selectionStart = self.selectionEnd;
	                        self.selectionEnd = self.cursorPos;
	                    } else {
	                        self.selectionEnd = self.cursorPos;
	                    }
	                }
	            }
	            return;
	        } 
	        // Right arrow
	        else if (keyboard_check(vk_right)) {
	            if (self.cursorPos < string_length(self.value)) {
	                if (ctrl_pressed) {
	                    // Move to start of next word
	                    var pos = self.cursorPos + 1;
	                    while (pos < string_length(self.value) && string_char_at(self.value, pos) != " ") {
	                        pos++;
	                    }
	                    while (pos < string_length(self.value) && string_char_at(self.value, pos) == " ") {
	                        pos++;
	                    }
	                    self.setCursorPos(pos);
	                } else {
	                    self.setCursorPos(self.cursorPos + 1);
	                }
	                if (!shift_pressed) {
	                    self.clearSelection();
	                } else if (self.selectionStart == -1) {
	                    self.setSelection(self.cursorPos - 1, self.cursorPos);
	                } else {
	                    // Update selection
	                    if (self.cursorPos > self.selectionEnd) {
	                        self.selectionEnd = self.cursorPos;
	                    } else {
	                        self.selectionStart = self.cursorPos;
	                    }
	                }
	            }
	            return;
	        } 
	        // Home key
	        else if (keyboard_check(vk_home)) {
	            self.setCursorPos(0);
	            if (!shift_pressed) {
	                self.clearSelection();
	            } else if (self.selectionStart == -1) {
	                self.setSelection(self.cursorPos, 0);
	            } else {
	                self.selectionStart = 0;
	            }
	            return;
	        } 
	        // End key
	        else if (keyboard_check(vk_end)) {
	            var end_pos = string_length(self.value);
	            self.setCursorPos(end_pos);
	            if (!shift_pressed) {
	                self.clearSelection();
	            } else if (self.selectionStart == -1) {
	                self.setSelection(self.cursorPos, end_pos);
	            } else {
	                self.selectionEnd = end_pos;
	            }
	            return;
	        }
        
	        // Delete/Backspace
	        if (keyboard_check(vk_backspace)) {
	            if (self.selectionStart != -1) {
	                // Delete selected text
	                var before = string_copy(self.value, 1, self.selectionStart);
	                var after = string_copy(self.value, self.selectionEnd + 1, string_length(self.value) - self.selectionEnd);
                
	                // Save cursor position before changing text
	                var newCursorPos = self.selectionStart;
                
	                self.setText(before + after);
	                self.setCursorPos(newCursorPos);
	                self.clearSelection();
	            } else if (self.cursorPos > 0) {
	                // Delete character before cursor
	                var before = string_copy(self.value, 1, self.cursorPos - 1);
	                var after = string_copy(self.value, self.cursorPos + 1, string_length(self.value) - self.cursorPos);
                
	                // Save cursor position before changing text
	                var newCursorPos = max(0, self.cursorPos - 1);
                
	                self.setText(before + after);
	                self.setCursorPos(newCursorPos);
	            }
	            return;
	        } else if (keyboard_check(vk_delete)) {
	            if (self.selectionStart != -1) {
	                // Delete selected text
	                var before = string_copy(self.value, 1, self.selectionStart);
	                var after = string_copy(self.value, self.selectionEnd + 1, string_length(self.value) - self.selectionEnd);
                
	                // Save cursor position before changing text
	                var newCursorPos = self.selectionStart;
                
	                self.setText(before + after);
	                self.setCursorPos(newCursorPos);
	                self.clearSelection();
	            } else if (self.cursorPos < string_length(self.value)) {
	                // Delete character after cursor
	                var before = string_copy(self.value, 1, self.cursorPos);
	                var after = string_copy(self.value, self.cursorPos + 2, string_length(self.value) - self.cursorPos - 1);
                
	                // Save cursor position (should remain the same for delete)
	                var newCursorPos = self.cursorPos;
                
	                self.setText(before + after);
	                self.setCursorPos(newCursorPos);
	            }
	            return;
	        }
	    }
    
	    // Process character input from keyboard_lastchar
	    if (lastchar != "" && ord(lastchar) >= 32) {
	        // Filter input for digit-only type
	        if (self.type == INPUT_TYPE.DIGITS && string_digits(lastchar) != lastchar) {
	            return;
	        }
        
	        // Handle selection replacement
	        if (self.selectionStart != -1) {
	            var before = string_copy(self.value, 1, self.selectionStart);
	            var after = string_copy(self.value, self.selectionEnd + 1, string_length(self.value) - self.selectionEnd);
            
	            // Save cursor position before changing text
	            var newCursorPos = self.selectionStart + string_length(lastchar);
            
	            self.setText(before + lastchar + after);
	            self.setCursorPos(newCursorPos);
	            self.clearSelection();
	        } else {
	            // Normal character insertion
	            var before = string_copy(self.value, 1, self.cursorPos);
	            var after = string_copy(self.value, self.cursorPos + 1, string_length(self.value) - self.cursorPos);
            
	            // Save cursor position before changing text
	            var newCursorPos = self.cursorPos + string_length(lastchar);
            
	            self.setText(before + lastchar + after);
	            self.setCursorPos(newCursorPos);
	        }
	    }
	}
	
	self.create_surface = function() {
		var inputWidth = self.getWidth() - (self.getPaddingLeft() + self.getPaddingRight());
		var inputHeight = self.getHeight() - (self.getPaddingTop() + self.getPaddingBottom());
		
		// Ensure minimum dimensions
		inputWidth = max(inputWidth, 1);
		inputHeight = max(inputHeight, 1);
		
		// Create or resize surface if needed
		if (self.surface == -1 || !surface_exists(self.surface) || 
			self.surfaceWidth != inputWidth || self.surfaceHeight != inputHeight) {
			if (surface_exists(self.surface)) {
				surface_free(self.surface);
			}
			
			try {
				self.surface = surface_create(inputWidth, inputHeight);
				self.surfaceWidth = inputWidth;
				self.surfaceHeight = inputHeight;
			} catch (e) {
				show_debug_message("Surface creation failed: " + string(e));
				self.surface = -1;
			}
		}
		
		return self.surface;
	}
	
	self.draw_cursor = function() {
		if (!self.is_focused || !self.drawCursor) exit;
		
		var x1 = 0;
		var y1 = 0;
		
		var cursorX = x1 + string_width(string_copy(self.value, 1, self.cursorPos)) - self.textOffset;
		
		// Only draw if cursor is within visible area
		if (cursorX >= x1 && cursorX <= x1 + self.surfaceWidth) {
			draw_set_color(self.styles.color);
			draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
			var cursorTop = y1 + (self.surfaceHeight/2) - (self.surfaceHeight * 0.35);
			var cursorBottom = y1 + (self.surfaceHeight/2) + (self.surfaceHeight * 0.35);
			draw_line(cursorX, cursorTop, cursorX, cursorBottom);
			draw_set_color(UI_DEFAULT_DRAW_COLOR);
			draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
		}
	}
	
	self.draw_selection = function() {
		if (self.selectionStart == -1 || self.selectionEnd == -1) exit;
		
		var x1 = 0; // Use local coordinates on surface
		var y1 = 0;
		
		var startX = x1 + string_width(string_copy(self.value, 1, self.selectionStart)) - self.textOffset;
		var endX = x1 + string_width(string_copy(self.value, 1, self.selectionEnd)) - self.textOffset;
		
		// Draw selection rectangle
		draw_set_color(self.styles.fill);
		draw_set_alpha(self.styles.fillOpacity);
		draw_rectangle(startX, y1, endX, y1 + self.surfaceHeight, false);
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	}
	
	self.draw_value = function() {
		if (string_length(self.value) == 0) {
			self.draw_placeholder();
			exit;
		}
		
		var x1 = 0;
		var y1 = 0;
		
		// Draw the text
		draw_set_font(self.styles.font);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
		
		if (self.type == INPUT_TYPE.PASSWORD && self.value != "") {
			// Draw password dots
			var dots = "";
			for (var i = 1; i <= string_length(self.value); i++) {
				dots += self.dot;
			}
			
			draw_set_color(self.styles.color);
			draw_text(x1 - self.textOffset, y1 + self.surfaceHeight/2, dots);
		} else {
			// Draw normal text
			draw_set_color(self.styles.color);
			draw_text(x1 - self.textOffset, y1 + self.surfaceHeight/2, self.value);
		}
		
		// Reset
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	}
	
	self.draw_placeholder = function() {
		if (string_length(self.value) > 0 || string_length(self.placeholder) == 0) exit;
		
		var x1 = 0; 
		var y1 = 0;
		
		// Draw placeholder text
		draw_set_font(self.styles.font);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_color(self.styles.color);
		draw_set_alpha(0.9);
		draw_text(x1, y1 + self.surfaceHeight/2, self.placeholder);
		
		// Reset
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	}
	
	self.draw_body = function() {	
		var x1 = self.getX() + self.styles.translateX;
		var y1 = self.getY() + self.styles.translateY;
		var x2 = x1 + self.getWidth();
		var y2 = y1 + self.getHeight();
		
		// Input background
		draw_set_color(self.styles.backgroundColor);
		draw_set_alpha(self.styles.opacity);
		draw_roundrect_ext(x1, y1, x2, y2, self.styles.borderRadius, self.styles.borderRadius, false);
		
		// Create surface for text rendering
		var surf = self.create_surface();
		if (!surface_exists(surf)) {
			surf = self.create_surface(); // Try to create again if failed
		}
		
		if (surface_exists(surf)) {
			surface_set_target(surf);
			draw_clear_alpha(c_black, 0); // Clear with transparent background
			
			// Draw selection if any
			self.draw_selection();
			
			// Draw the text or placeholder
			self.draw_value();
			
			// Draw cursor
			self.draw_cursor();
			
			surface_reset_target();
			
			// Draw the surface to screen
			draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
			draw_surface(
				surf, 
				x1 + self.getPaddingLeft(), 
				y1 + self.getPaddingTop()
			);
			draw_set_alpha(UI_DEFAULT_DRAW_OPACITY); 
		} else {
			// Fallback if surface creation fails
			var text_x = x1 + self.getPaddingLeft();
			var text_y = y1 + self.getPaddingTop();
			
			draw_set_color(self.styles.color);
			draw_set_font(self.styles.font);
			draw_text(text_x, text_y, string_length(self.value) > 0 ? self.value : self.placeholder);
		}
		
		// Reset to default
		draw_set_color(UI_DEFAULT_DRAW_COLOR);
		draw_set_alpha(UI_DEFAULT_DRAW_OPACITY);
	}
	
	
	self.destroy = function() {
		if (surface_exists(self.surface)) {
			surface_free(self.surface);
		}
		
		// Handle other cleanup tasks as needed
	}
	#endregion
}