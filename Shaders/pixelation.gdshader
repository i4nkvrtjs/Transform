shader_type canvas_item;

uniform float pixel_size : hint_range(1.0, 64.0, 1.0) = 4.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest, repeat_disable;

void fragment() {
    // Calculate the size of a single pixel in UV coordinates
    vec2 size = vec2(SCREEN_PIXEL_SIZE.x * pixel_size, SCREEN_PIXEL_SIZE.y * pixel_size);

    // Snap the current UV coordinates to the pixelation grid
    vec2 uv = floor(SCREEN_UV / size) * size;

    // Sample the screen texture at the snapped UVs
    COLOR = texture(SCREEN_TEXTURE, uv);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
