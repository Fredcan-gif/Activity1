shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0);
uniform float width : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * width;
    float alpha = texture(TEXTURE, UV).a;
    
    // Check neighboring pixels
    alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
    
    vec4 final_color = mix(outline_color, texture(TEXTURE, UV), texture(TEXTURE, UV).a);
    COLOR = vec4(final_color.rgb, clamp(alpha, 0.0, 1.0));
}