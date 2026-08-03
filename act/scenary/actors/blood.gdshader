shader_type canvas_item;

uniform sampler2D blood_texture;
uniform float blood_amount = 0.0;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	vec4 sprite = texture(TEXTURE, UV);
    vec4 blood = texture(blood_texture, UV);
	float mask = sprite.a * blood.a * blood_amount;
    COLOR = mix(sprite, blood, mask);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
