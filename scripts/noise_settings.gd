@tool
class_name NoiseSettings
extends Resource

@export var strength: float = 1.0:
    set(value):
        strength = value
        emit_changed()
@export var sample_radius: float = 10.0:
    set(value):
        sample_radius = value
        emit_changed()
@export var noise: FastNoiseLite:
    set(value):
        noise = value
        noise.changed.connect(emit_changed)
@export_range(0, 1, 0.01) var min_value: float = 0.0:
    set(value):
        min_value = value
        emit_changed()


func get_noise_3dv(v: Vector3) -> float:
    if noise:
        var noise_value = noise.get_noise_3dv(v * sample_radius)
        # var noise_value = (noise.get_noise_3dv(v * sample_radius) + 1) * 0.5
        noise_value = noise_value - min_value
        return noise_value * strength
    else:
        return min_value