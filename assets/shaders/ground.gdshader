shader_type canvas_item;
// The Ashen Reaches. Drawn on a camera-following quad; all pattern from WORLD position,
// so the ground is infinite and stable. Lava math is mirrored in map.gd (keep in sync!).

uniform float world_radius = 5800.0;
uniform float river_half_width = 95.0;
uniform int river_count = 4;

varying vec2 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x),
	           mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	v += 0.5 * vnoise(p);
	v += 0.25 * vnoise(p * 2.03);
	v += 0.125 * vnoise(p * 4.11);
	return v / 0.875;
}

// signed lava field in px: >0 means lava. Mirrored in map.gd::lava_at
float lava_field(vec2 p) {
	float r = length(p);
	// boundary lake of fire
	float ring = r - (world_radius - 140.0);
	// radial rivers, meander in px (stable at any radius), two bridge gaps
	float best = -1e6;
	float ang = atan(p.y, p.x);
	for (int k = 0; k < 4; k++) {
		float base_a = 6.2831 * float(k) / float(river_count) + 0.7;
		float da = ang - base_a;
		da = atan(sin(da), cos(da));
		float across_px = da * max(r, 1.0) - sin(r * 0.004 + float(k) * 2.1) * 240.0;
		float river = river_half_width - abs(across_px);
		// taper away near the Gate and at the two bone bridges (smooth ends, no hard cuts)
		river -= max(0.0, 950.0 - r) * 0.8;
		river -= max(0.0, 140.0 - abs(r - 1600.0)) * 0.9;
		river -= max(0.0, 140.0 - abs(r - 3450.0)) * 0.9;
		best = max(best, river);
	}
	return max(ring, best);
}

void fragment() {
	vec2 p = wpos;
	float n = fbm(p * 0.006);
	float n2 = fbm(p * 0.02 + 40.0);
	// ash base
	vec3 char_col = vec3(0.10, 0.09, 0.115);
	vec3 ash_col = vec3(0.21, 0.195, 0.22);
	vec3 col = mix(char_col, ash_col, n);
	// large scorched patches
	float patch = smoothstep(0.55, 0.75, fbm(p * 0.0012 + 7.0));
	col = mix(col, vec3(0.115, 0.085, 0.095), patch * 0.7);
	// fine grain
	col *= 0.92 + 0.16 * n2;
	// ember veins smouldering in thin cracks, only inside scorched patches
	float vein_n = fbm(p * 0.011 + 99.0);
	float vein = 1.0 - smoothstep(0.0, 0.022, abs(vein_n - 0.5));
	float pulse = 0.6 + 0.4 * sin(TIME * 1.3 + vein_n * 30.0);
	col += vec3(0.5, 0.12, 0.035) * vein * pulse * patch;
	// bone-dust flecks
	float fleck = step(0.985, vnoise(p * 0.09));
	col += vec3(0.35, 0.33, 0.28) * fleck;

	// lava
	float lv = lava_field(p);
	if (lv > -60.0) {
		float flow = fbm(p * 0.012 + vec2(TIME * 0.10, -TIME * 0.16));
		float heat = smoothstep(-60.0, 30.0, lv);
		vec3 lava = mix(vec3(0.5, 0.09, 0.04), vec3(1.9, 0.7, 0.15), flow * flow * 1.4);
		lava += vec3(1.3, 0.65, 0.2) * smoothstep(0.62, 0.95, flow);
		col = mix(col, lava, heat);
		// shore glow
		col += vec3(0.9, 0.25, 0.06) * (1.0 - abs(clamp(lv / 60.0, -1.0, 1.0))) * 0.5;
	}
	COLOR = vec4(col, 1.0);
}
