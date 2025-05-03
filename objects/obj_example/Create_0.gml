
var item = {
	marginBottom: 10	
}

var text = {
	marginTop: 10,
};

new Toggle("Toggle Me!", item, 40, 40)
new RadioGroup(["Radio 1", "Radio 2"], item)

new Text("UI Background Color", text);
new ColorPicker(item)
.setOnChange(function(c) {
	ui_set_global_styles({ backgroundColor: c, fill: c });
});

new Text("UI Text Color", text);
new ColorPicker(item)
.setOnChange(function(c) {
	ui_set_global_styles({ color: c });
});

new Text("UI Border Color", text);
new ColorPicker(item)
.setOnChange(function(c) {
	ui_set_global_styles({ borderColor: c });
});

new Text("UI Fill Color", text);
new ColorPicker(item)
.setOnChange(function(c) {
	ui_set_global_styles({ fill: c });
});

new Checkbox("Enable Border", text)
.setOnClick(function(this) {
	ui_set_global_styles({ border: this.getChecked() });
});

new Checkbox("Enable Box Shadow", text)
.setOnClick(function(this) {
	ui_set_global_styles({ boxShadow: this.getChecked() });
});

new Checkbox("Enable Outline", text)
.setOnClick(function(this) {
	ui_set_global_styles({ outline: this.getChecked() });
});

new Text("Border Radius", text);
new Slider(0, 50, 4, 1, item)
.setOnChange(function(val) {
	ui_set_global_styles({ borderRadius: val });
});

new Text("Shadow", text);
new Slider(0, 1, 0, 0.01, item)
.setOnChange(function(val) {
	ui_set_global_styles({ boxShadow: val });
});

new Text("Opacity", text);
new Slider(0, 1, 1, 0.01, item)
.setOnChange(function(val) {
	ui_set_global_styles({ opacity: val });
});

new Dropdown( "Choose an option", ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5"], item)

new Input("Type here", item)

new Button("Randomize Styles", item)
.setOnClick(function() {
	var components = ui_get_components();
	array_foreach(components, function(c) {
		randomize_style(c);
	});
});