shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform vec4 warna : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float emisi = 0.0;
uniform vec2 kisi = vec2(200.0, 100.0);

varying vec3 posisi_dunia;

void vertex() {
    posisi_dunia = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec4 p = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
    if (p.w > 0.5) {
        vec2 ndc = p.xy / p.w;
        ndc = floor(ndc * kisi + vec2(0.5)) / kisi;
        p.xy = ndc * p.w;
    }
    POSITION = p;
}

void fragment() {
    float n = fract(sin(dot(floor(posisi_dunia * 3.0), vec3(12.9898, 78.233, 37.719))) * 43758.5453);
    ALBEDO = warna.rgb * (0.8 + 0.2 * n);
    ROUGHNESS = 1.0;
    EMISSION = warna.rgb * emisi;
}
