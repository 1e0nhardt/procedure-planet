shader_type spatial;

uniform float min_elevation;
uniform float max_elevation;
uniform sampler2D planet_texture: repeat_disable;
uniform sampler2D ocean_texture: repeat_disable;

float inverse_lerp(float v,  float min_val, float max_val) {
    return clamp((v - min_val) / (max_val - min_val), 0, 1); 
}

void fragment() {
    //vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	//float elevation = length(world_pos);
    //float percent = inverse_lerp(UV.y, min_elevation, max_elevation);
    float percent = 0.0;
    float unscaled_elevation = UV.y;
    
    float ocean_mask = float(UV.y < 0.0);
    if (UV.y < 0.0) {
        float ocean_percent = inverse_lerp(unscaled_elevation, min_elevation, 0.0);
        ALBEDO = texture(ocean_texture, vec2(ocean_percent, 0.0)).rgb;
        ROUGHNESS = 0.2;
    }else{
        float land_percent = inverse_lerp(unscaled_elevation, 0.0, max_elevation);
        ALBEDO = texture(planet_texture, vec2(land_percent, UV.x)).rgb;
        ROUGHNESS = 0.8;
    }
}
