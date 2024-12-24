@tool
class_name ShapeSettings
extends Resource

@export var radius: float = 1.0:
    set(value):
        radius = value
        emit_changed()
@export var layered_noises: LayeredFastNoise:
    set(value):
        layered_noises = value
        if layered_noises and not layered_noises.is_connected("changed", emit_changed):
            layered_noises.changed.connect(emit_changed)

var min_elevation: float = 999.0
var max_elevation: float = 0.0


func update_minmax(value: float) -> void:
    min_elevation = min(min_elevation, value)
    max_elevation = max(max_elevation, value)


func calculate_unscaled_elevation(point: Vector3) -> float:
    if layered_noises:
        var elevation = layered_noises.get_layered_noise_3dv(point)
        update_minmax(elevation)
        return elevation
    else:
        return 0.0


func calculate_scaled_elevation(unscaled_elevation: float) -> float:
    var elevation = max(0, unscaled_elevation)
    elevation = radius * (1 + elevation)
    return elevation


# func calculate_point_on_planet(point: Vector3) -> Vector3:
#     if layered_noises:
#         var elevation = radius * (1 + layered_noises.get_layered_noise_3dv(point))
#         update_minmax(elevation)
#         return point * elevation
#     else:
#         return point * radius