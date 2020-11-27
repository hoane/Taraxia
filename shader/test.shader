shader_type canvas_item;

uniform vec2 direction = vec2(1.0,0.0);
uniform float speed_scale = 0.02;

float logistic(float x, float k, float x0) {
    return 1.0 / (1.0 + exp(-k * (x - x0)));
}

void fragment() {
    vec2 move = speed_scale * direction * TIME;
    vec2 basep = UV * vec2(0.66, 0.33);

    float t = 0.00;
    float mscale = 0.4;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            vec2 p = basep + vec2(0.33 * float(i), 0.33 * float(j));
            float tp = logistic(texture(TEXTURE, p + (move * mscale)).r, 100.0, 0.85);
            mscale *= 1.2;
            tp = tp * mscale * 0.8;
            t = max(t, tp);
        }
    }

    COLOR = vec4(t, t, t, 1.0);
}