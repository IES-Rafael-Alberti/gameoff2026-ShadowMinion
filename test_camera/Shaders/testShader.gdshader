shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform sampler2D u_dither_tex : repeat_enable, filter_nearest;
uniform sampler2D u_color_tex : filter_nearest;

uniform int u_bit_depth = 8;
uniform float u_contrast = 1.0;
uniform float u_offset = 0.0;
uniform int u_dither_size = 2;

void fragment()
{
    vec2 screen_size = vec2(textureSize(screen_texture, 0)) / float(max(u_dither_size, 1));
    vec2 screen_sample_uv = floor(SCREEN_UV * screen_size) / screen_size;
    vec3 screen_col = texture(screen_texture, screen_sample_uv).rgb;

    float lum = dot(screen_col, vec3(0.299, 0.587, 0.114));

    lum = (lum - 0.5 + u_offset) * u_contrast + 0.5;
    lum = clamp(lum, 0.0, 1.0);

    float bits = float(max(u_bit_depth, 1));
    lum = floor(lum * bits) / bits;

    ivec2 col_size = textureSize(u_color_tex, 0);
    col_size /= col_size.y;

    float col_x = max(float(col_size.x) - 1.0, 1.0);
    float col_texel_size = 1.0 / col_x;

    lum = max(lum - 0.00001, 0.0);
    float lum_lower = floor(lum * col_x) * col_texel_size;
    float lum_upper = (floor(lum * col_x) + 1.0) * col_texel_size;
    float lum_scaled = lum * col_x - floor(lum * col_x);

    vec2 inv_noise_size = 1.0 / vec2(textureSize(u_dither_tex, 0));
    vec2 noise_uv = SCREEN_UV * screen_size * inv_noise_size;
    float threshold = texture(u_dither_tex, noise_uv).r;
    threshold = threshold * 0.99 + 0.005;

    float ramp_val = lum_scaled < threshold ? 0.0 : 1.0;
    float col_sample = mix(lum_lower, lum_upper, ramp_val);

    COLOR = vec4(texture(u_color_tex, vec2(col_sample, 0.5)).rgb, 1.0);
}