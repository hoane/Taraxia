shader_type canvas_item;

uniform bool spotlight = false;

const float speed = 2.0;
const float pi = 3.1415;
const float freq = 4.0;

void fragment() {
    if (!spotlight) {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }
    vec2 v = UV - vec2(0.5, 0.5);
    v *= 1.2;
    float delta = v.x * v.x * v.x * v.x + v.y * v.y * v.y * v.y;
    float border = (1.0 - cos((delta * pi * 10.0) + 1.0)) / 2.0;
    float y = delta * 8.0;
    border -= y * y;
    border *= 0.25 * (2.0 - sin(TIME * speed));
    COLOR = vec4(0.8, 0.7, 0.1, max(border, 0.0));
}