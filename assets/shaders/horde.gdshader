shader_type canvas_item;
// Swarm demon shader: per-instance wobble/bob, white hit-flash, stagger dim.
// INSTANCE_CUSTOM: x = flash 0..1, y = phase 0..1, z = staggered flag, w = unused.

varying float v_flash;
varying float v_stagger;

void vertex() {
	float phase = INSTANCE_CUSTOM.y * 6.2831;
	float t = TIME * 5.5 + phase * 4.0;
	// gait: squash-and-stretch + sway (amplitude in local px, quads are ~70-120px)
	float squash = sin(t) * 0.045;
	VERTEX.x *= 1.0 + squash;
	VERTEX.y *= 1.0 - squash;
	VERTEX.x += sin(t * 0.5) * 2.0;
	VERTEX.y += abs(sin(t)) * -3.0;
	v_flash = INSTANCE_CUSTOM.x;
	v_stagger = INSTANCE_CUSTOM.z;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 col = tex.rgb;
	// staggered demons drain grey-blue
	col = mix(col, vec3(dot(col, vec3(0.333)) * 0.7, dot(col, vec3(0.333)) * 0.75, dot(col, vec3(0.333))), v_stagger * 0.6);
	// hit flash: blow out to holy white (HDR — feeds bloom)
	col = mix(col, vec3(2.2, 2.0, 1.6), v_flash * 0.85);
	COLOR = vec4(col, tex.a);
}
