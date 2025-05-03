/**
 * @description Randomizes and applies a set of style properties to a UI element. 
 * @param {struct} element - The UI component to style.
 */
function randomize_style(element) {
	var styles = {
		color: choose(c_white, c_red, c_blue),
		fill: choose(c_green, c_blue, c_yellow, c_fuchsia),
		backgroundColor: choose(c_dkgray, c_green, c_blue, c_yellow, c_fuchsia),
		opacity: UI_DEFAULT_DRAW_OPACITY,
		
		handleFill: choose(c_green, c_blue, c_yellow, c_fuchsia),
		handleOpacity: random(1),
		
		borderRadius: irandom(50),
		borderColor: choose(c_white, c_black, c_green, c_blue, c_yellow, c_fuchsia),
		borderOpacity: UI_DEFAULT_DRAW_OPACITY,
		
		boxShadowColor: choose(c_white, c_black, c_green, c_blue, c_yellow, c_fuchsia),
		boxShadowOffset: irandom(10),
		
		outline: choose(true, false),
		outlineColor: choose(c_white, c_black, c_green, c_blue, c_yellow, c_fuchsia),
		outlineOpacity: random(1),
		
		flexDirection: choose(FLEX_DIRECTION.ROW, FLEX_DIRECTION.COLUMN),
		gap: irandom(64),
	};	
	
	element.setStyles(styles);
}
