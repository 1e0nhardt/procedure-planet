@tool
class_name BiomeColorSettings
extends Resource

@export_group("Biome Basic")
@export var biome_noise: FastNoiseLite:
    set(value):
        biome_noise = value
        biome_noise.changed.connect(emit_changed)
@export var biome_noise_strength: float = 1.0:
    set(value):
        biome_noise_strength = value
        emit_changed()
@export var biome_noise_offset: float = 0.0:
    set(value):
        biome_noise_offset = value
        emit_changed()
@export_range(0, 1, 0.01) var blend_amount: float = 0.0:
    set(value):
        blend_amount = value
        emit_changed()
@export_group("Biomes")
@export var biome_amount: int = 0:
    set(value):
        biome_amount = value
        _biome_settings.resize(value)
        for i in range(value):
            if _biome_settings[i] == null:
                _biome_settings[i] = [null, Color.BLACK, 0.0, 0.0]
        emit_changed()
        notify_property_list_changed()

var _biome_settings = []


func biome_percent_from_point(point: Vector3) -> float:
    var height_percent := (point.y + 1.0) / 2.0
    if biome_noise:
        height_percent += (biome_noise.get_noise_3dv(point * 40.0) - biome_noise_offset) * biome_noise_strength
    var biome_index := 0.0
    var blend_range := blend_amount / 2.0 + 0.001

    for i in range(biome_amount):
        # 添加过渡，抗锯齿
        var dst = height_percent - _biome_settings[i][2]
        var weight = clamp(inverse_lerp(-blend_range, blend_range, dst), 0, 1)
        biome_index *= (1 - weight)
        biome_index += i * weight

        # 无抗锯齿
        # if _biome_settings[i][2] < height_percent:
        #     biome_index = i
        # else:
        #     break

    return biome_index / max(1.0, biome_amount - 1.0)


func generate_planet_texture() -> Texture2D:
    var image := Image.create(64, max(1, biome_amount), false, Image.FORMAT_RGB8)
    for i in range(biome_amount):
        for j in range(64):
            var gradient_color = _biome_settings[i][0].sample(j / 63.0)
            var tint_color = _biome_settings[i][1]
            var final_color = gradient_color.lerp(tint_color, _biome_settings[i][3])
            image.set_pixel(j, i, final_color)

    return ImageTexture.create_from_image(image)


func _get_property_list():
    var properties = []
    
    for i in range(biome_amount):
        properties.append({
            "name": "biome_%d/gradient" % i,
            "type": TYPE_OBJECT,
            "hint": PROPERTY_HINT_RESOURCE_TYPE,
            "hint_string": "Gradient",
        })
        properties.append({
            "name": "biome_%d/tint" % i,
            "type": TYPE_COLOR,
            "hint": PROPERTY_HINT_COLOR_NO_ALPHA,
        })
        properties.append({
            "name": "biome_%d/start_height" % i,
            "type": TYPE_FLOAT,
            "hint": PROPERTY_HINT_RANGE,
            "hint_string": "0,1,0.01",
        })
        properties.append({
            "name": "biome_%d/tint_percent" % i,
            "type": TYPE_FLOAT,
            "hint": PROPERTY_HINT_RANGE,
            "hint_string": "0,1,0.01",
        })

    return properties


func _get(property):
    if biome_amount > 0 and property.begins_with("biome_"):
        var index = property.get_slice("/", 0).get_slice("_", 1).to_int()
        var prop = property.get_slice("/", 1)
        match prop:
            "gradient":
                return _biome_settings[index][0]
            "tint":
                return _biome_settings[index][1]
            "start_height":
                return _biome_settings[index][2]
            "tint_percent":
                return _biome_settings[index][3]


func _set(property, value):
    if biome_amount > 0 and property.begins_with("biome_"):
        var index = property.get_slice("/", 0).get_slice("_", 1).to_int()
        var prop = property.get_slice("/", 1)
        match prop:
            "gradient":
                value.changed.connect(emit_changed)
                _biome_settings[index][0] = value
            "tint":
                _biome_settings[index][1] = value
            "start_height":
                _biome_settings[index][2] = value
            "tint_percent":
                _biome_settings[index][3] = value
        emit_changed()
        return true

    return false
