shader_type canvas_item;
// Grace embers. Tier in INSTANCE_CUSTOM.x: 0 small, 1 medium, 2 large, 3 prismatic.

varying float v_tier;
varying float v_phase;

void vertex() {
	v_tier = INSTANCE_CUSTOM.x;
	v_phase = INSTANCE_CUSTOM.y * 6.2831;
	float b = sin(TIME * 3.0 + v_phase);
	VERTEX *= 1.0 + b * 0.12;
	VERTEX.y += b * 2.0;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 cold = vec3(0.85, 1.0, 1.5);            // grace blue-white
	vec3 mid  = vec3(1.3, 1.15, 0.7);            // gilded
	vec3 high = vec3(1.6, 1.3, 2.0);             // violet-white
	vec3 tint = cold;
	if (v_tier > 2.5) {
		tint = mix(high, vec3(1.8, 1.2, 0.9), 0.5 + 0.5 * sin(TIME * 4.0 + v_phase));
	} else if (v_tier > 1.5) {
		tint = high;
	} else if (v_tier > 0.5) {
		tint = mid;
	}
	float glow = 1.2 + 0.35 * sin(TIME * 3.0 + v_phase);
	COLOR = vec4(tex.rgb * tint * glow, tex.a);
}
