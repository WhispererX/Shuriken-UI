/**
 * @description Converts a GameMaker color integer (RGB) to a hexadecimal string (e.g. "#FF00FF").
 * @param {real} c - The GameMaker color value to convert (e.g. `c_red`, `make_color_rgb(...)`).
 * @returns {string} A hex color string in the format "#RRGGBB".
 */
function color_to_hex(c) {

	var n = (c & 16711680) >> 16 | (c & 65280) | (c & 255) << 16,
		s = "0123456789ABCDEF",
		r = "";

	repeat (3) {
		var b = n & 255;
		r = string_char_at(s, b div 16 + 1) + string_char_at(s, b % 16 + 1) + r;
		n = n >> 8;
	}

	return "#" + r;

}

/**
 * @description Converts a hexadecimal color string (e.g. "#FF00FF", "F0F") to a GameMaker color value.
 * Supports both 3-digit and 6-digit hex formats.
 * @param {string} h - The hex color string to convert (with or without "#").
 * @returns {real}
 */
function hex_to_color(h) {
	
	var s = string_upper(string_lettersdigits(h)),
		s = string_copy(s, 1, 6),
		l = string_length(s);
		
	if (l == 3) {
		var c1 = string_char_at(s, 1),
			c2 = c1,
			c3 = string_char_at(s, 2),
			c4 = c3,
			c5 = string_char_at(s, 3),
			c6 = c5;
	} else {
		var c1 = string_char_at(s, 1),
			c2 = string_char_at(s, 2),
			c3 = string_char_at(s, 3),
			c4 = string_char_at(s, 4),
			c5 = string_char_at(s, 5),
			c6 = string_char_at(s, 6);
	}

	var r = char_to_num(c1) * 16 + char_to_num(c2),
		g = char_to_num(c3) * 16 + char_to_num(c4),
		b = char_to_num(c5) * 16 + char_to_num(c6);

	return make_color_rgb(r, g, b);

}

/**
 * @description Converts a single hexadecimal character (0-9, A-F) to its numeric value (0–15).
 * Used when parsing hex color strings.
 * @param {string} c - A single character representing a hexadecimal digit.
 * @returns {real} The numeric value of the hex digit, or 0 if invalid.
 */
function char_to_num(c) {
	
	var r = string_digits(c);
	if (r != "") return real(r);
	
	switch (c) {
		case "A": r = 10; break;
		case "B": r = 11; break;
		case "C": r = 12; break;
		case "D": r = 13; break;
		case "E": r = 14; break;
		case "F": r = 15; break;
		default : r = 0;
	}

	return r;

}