@tool
class_name Planet
extends Node3D

@export_range(2, 256) var resolution: int = 40:
    set(value):
        resolution = value
        if not is_inside_tree():
            return
        generate_meshes()
@export var planet_material: Material
@export var biome_settings: BiomeColorSettings
@export var shape_settings: ShapeSettings
@export_enum("ALL:1", "LEFT:2", "RIGHT:4", "TOP:8", "BOTTOM:16", "FRONT:32", "BACK:64") var render_mask: int = 0:
    set(value):
        render_mask = value
        if not is_inside_tree():
            return
        generate_meshes()

var face_meshes := []
var terrain_faces := []
var directions := [
        Vector3(1, 0, 0), Vector3(-1, 0, 0),
        Vector3(0, 1, 0), Vector3(0, -1, 0),
        Vector3(0, 0, 1), Vector3(0, 0, -1)
    ]
var planet_texture: Texture2D


func _ready() -> void:
    if shape_settings:
        shape_settings.changed.connect(generate_meshes)
    if biome_settings:
        biome_settings.changed.connect(generate_colors)

    for i in range(6):
        face_meshes.append(MeshInstance3D.new())
        face_meshes[i].mesh = ArrayMesh.new()
        add_child(face_meshes[i])

    terrain_faces.resize(6)
    generate_meshes()


func generate_meshes() -> void:
    shape_settings.min_elevation = 9999.0
    shape_settings.max_elevation = -9999.0
    # Logger.info("Generating meshes")
    terrain_faces.fill(null)
    for i in range(6):
        var terrain_face = TerrainFace.new(face_meshes[i].mesh, resolution, directions[i], shape_settings)
        face_meshes[i].visible = false
        if render_mask == 1 or (render_mask & (1 << (i + 1))):
            face_meshes[i].visible = true
            terrain_face.construct_mesh()
            terrain_face.mesh.surface_set_material(0, planet_material)
            terrain_faces[i] = terrain_face
    generate_colors()


func generate_colors() -> void:
    # Logger.info("Generating colors")
    planet_material.set_shader_parameter("min_elevation", shape_settings.min_elevation)
    planet_material.set_shader_parameter("max_elevation", shape_settings.max_elevation)
    planet_material.set_shader_parameter("planet_texture", biome_settings.generate_planet_texture())
    for i in range(6):
        if face_meshes[i].visible and terrain_faces[i]:
            terrain_faces[i].update_uv(biome_settings)
            terrain_faces[i].mesh.surface_set_material(0, planet_material)
