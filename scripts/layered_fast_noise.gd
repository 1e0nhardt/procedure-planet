@tool
class_name LayeredFastNoise
extends Resource

@export var layer_amount: int = 0:
    set(value):
        layer_amount = value
        _noise_layers.resize(value)
        emit_changed()
        notify_property_list_changed()

var _enabled_layer_flags: int = 0
var _use_first_layer_as_mask_flags: int = 0
var _noise_layers: Array


func get_layered_noise_3dv(v: Vector3):
    # Logger.debug("enabled_layer_flags: %d" % _enabled_layer_flags)

    var noise_sum = 0.0
    var first_layer_value = 0.0
    if layer_amount > 1 and (_enabled_layer_flags & 1):
        first_layer_value = _noise_layers[0].get_noise_3dv(v)
        noise_sum += first_layer_value

    for i in range(1, layer_amount):
        var noise_layer: NoiseSettings = _noise_layers[i]
        if noise_layer != null and (_enabled_layer_flags & (1 << i)):
            var mask = first_layer_value / _noise_layers[0].strength if _use_first_layer_as_mask_flags & (1 << i) else 1.0
            noise_sum += noise_layer.get_noise_3dv(v) * mask
    return noise_sum


func _get_property_list():
    var properties = []
    
    var enabled_layer_hint_string = ""
    var use_first_layer_as_mask_hint_string = ""

    properties.append({
        "name": "enabled_layer",
        "type": TYPE_INT,
        "hint": PROPERTY_HINT_FLAGS,
        "hint_string": "",
    })
    
    properties.append({
        "name": "use_first_layer_as_mask",
        "type": TYPE_INT,
        "hint": PROPERTY_HINT_FLAGS,
        "hint_string": "",
    })

    for i in range(layer_amount):
        properties.append({
            "name": "noise_layer_%d" % i,
            "type": TYPE_OBJECT,
            "hint": PROPERTY_HINT_RESOURCE_TYPE,
            "hint_string": "NoiseSettings",
        })
        enabled_layer_hint_string += "%d:%d," % [i, pow(2, i)]
        use_first_layer_as_mask_hint_string += "%d:%d," % [i, pow(2, i)]

    properties[0]["hint_string"] = enabled_layer_hint_string
    properties[1]["hint_string"] = use_first_layer_as_mask_hint_string
    return properties


func _get(property):
    if property.begins_with("noise_layer_"):
        var index = property.get_slice("_", 2).to_int()
        return _noise_layers[index]
    
    if property == "enabled_layer":
        return _enabled_layer_flags
    
    if property == "use_first_layer_as_mask":
        return _use_first_layer_as_mask_flags


func _set(property, value):
    if property.begins_with("noise_layer_"):
        var index = property.get_slice("_", 2).to_int()
        _noise_layers[index] = value
        if value and not value.is_connected("changed", emit_changed):
            value.changed.connect(emit_changed)
        return true
    
    if property == "enabled_layer":
        _enabled_layer_flags = value
        emit_changed()
        return true
    
    if property == "use_first_layer_as_mask":
        _use_first_layer_as_mask_flags = value
        emit_changed()
        return true

    return false
