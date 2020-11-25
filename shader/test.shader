shader_type canvas_item;

uniform vec2 direction = vec2(1.0,0.0);
uniform float speed_scale = 0.01;

float logistic(float x) {
    return 1.0 / (1.0 + exp(-100.0 * (x - 0.85)));
}

float imgmag(float inp) {
    return logistic(inp);
}

void fragment() {
    float speed = speed_scale;
    vec2 move = speed * direction * TIME;

    vec2 basep = UV * vec2(0.66, 0.33);

    float t = 0.03;
    float mscale = 0.2;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            vec2 p = basep + vec2(0.33 * float(i), 0.33 * float(j));
            float tp = imgmag(texture(TEXTURE, p + (move * mscale)).r);
            mscale *= 1.1;
            t = max(t, tp);
        }
    }

    t -= 0.1;

    COLOR = vec4(t, t, t, 1.0);
}