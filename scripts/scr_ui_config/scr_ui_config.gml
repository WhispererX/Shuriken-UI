// === UI Styling and Behavior Macros ===

// Enables global UI styling (set to true to apply consistent styles across UI components)
#macro UI_ENABLE_GLOBAL_STYLING true		

// Default font used for all UI text rendering
#macro UI_DEFAULT_FONT fnt_default

// Default drawing color for UI elements
#macro UI_DEFAULT_DRAW_COLOR c_white

// Default opacity for UI elements (1 = fully opaque)
#macro UI_DEFAULT_DRAW_OPACITY 1

// Default background color for UI components
#macro UI_DEFAULT_BACKGROUND_COLOR c_dkgray

// Default event function placeholder for UI components (empty by default)
#macro UI_DEFAULT_EVENT function(component) { }

// Mouse X and Y positions translated to GUI layer (used in UI for mouse interaction)
#macro UI_MOUSE_X device_mouse_x_to_gui(0)
#macro UI_MOUSE_Y device_mouse_y_to_gui(0)

// Delay (in frames) after which obj_ui_manager will be automatically created in the room ( negative numbers won't auto-create the object)
#macro UI_AUTO_CREATE_DELAY 10	


// === Enumerations ===

// Types of input supported by UI input fields
enum INPUT_TYPE {
	TEXT,       // Any text input
	DIGITS,     // Only numeric input
	PASSWORD    // Masked input
}

// Flexbox-like layout direction for UI containers
enum FLEX_DIRECTION {
	ROW,        // Arrange child elements horizontally
	COLUMN      // Arrange child elements vertically
}

// Text decoration options for UI text styling
enum TEXT_DECORATION {
	NONE,           // No decoration
	UNDERLINE,      // Underlined text
	OVERLINE,       // Line above text
	HIGHLIGHT,      // Highlighted background
	LINE_THROUGH,   // Strike-through text
	LIST,           // Represented in a list format
}

// Delay between input key repeats when holding down a key
#macro UI_INPUT_DELAY 30		

// Number of frames before input begins repeating when key is held
#macro UI_INPUT_REPEAT 4		


// === Layout Macros ===

// Layout modes for UI elements
#macro LAYOUT_AUTO "auto"         // Automatically position itself
#macro LAYOUT_INLINE "inline"     // Inline layout (flow with surrounding elements)


// === Auto-create UI Manager ===

// Function to create the UI manager object
var auto_create = function() {
	instance_create_depth(0, 0, 0, obj_ui_manager);	
}

// If auto-create is enabled (delay is not negative), schedule the UI manager creation after the given delay
if (UI_AUTO_CREATE_DELAY >= 0)
	call_later(time_source_units_frames, UI_AUTO_CREATE_DELAY, auto_create, false);
