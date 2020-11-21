shader_type canvas_item;

uniform bool mono;
uniform bool highlight;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec4 out_color;
    if (mono) {
        float m = 0.3 * color.r + 0.59 * color.g + 0.11 * color.b;
        out_color = vec4(m, m, m, color.a);
    } else {
        out_color = color; //read from texture
    }

    if (highlight) {
        float coeff = 1.4;
        out_color = vec4(coeff * out_color.r, coeff * out_color.g, coeff * out_color.b, out_color.a)
    }

    COLOR = out_color;
}