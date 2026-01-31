shader_type canvas_item;

uniform vec4 my_modulate: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV) * my_modulate;
}
