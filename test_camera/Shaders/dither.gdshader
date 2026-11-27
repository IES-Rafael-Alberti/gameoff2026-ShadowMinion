shader_type spatial;
render_mode unshaded, shadows_disabled, depth_test_disabled, depth_draw_never;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform int color_depth : hint_range(1, 8) = 5;
uniform bool dithering = true;
uniform int resolution_scale = 4;

int dithering_pattern(ivec2 fragcoord) {
    const int pattern[] = {
        -4,  0, -3,  1,
         2, -2,  3, -1,
        -3,  1, -4,  0,
         3, -1,  2, -2
    };

    int x = fragcoord.x % 4;
    int y = fragcoord.y % 4;

    return pattern[y * 4 + x];
}

void vertex() {
    POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
    ivec2 uv = ivec2(FRAGCOORD.xy / float(resolution_scale));

    vec3 color = texelFetch(
        SCREEN_TEXTURE,
        uv * resolution_scale,
        0
    ).rgb;

    ivec3 c = ivec3(round(color * 255.0));

    if (dithering) {
        c += ivec3(dithering_pattern(uv));
    }

    c >>= (8 - color_depth);

    ALBEDO = vec3(c) / float(1 << color_depth);
}