class_name TerrainFace
extends RefCounted

var mesh: ArrayMesh
var mdt: MeshDataTool
## 单边总顶点数
var resolution: int 
var local_up: Vector3
var axis_a: Vector3
var axis_b: Vector3
var shape_settings: ShapeSettings


func _init(a_mesh: ArrayMesh, res: int, up: Vector3, settings: ShapeSettings) -> void:
    mesh = a_mesh
    resolution = res
    local_up = up
    axis_a = Vector3(up.y, up.z, up.x)
    axis_b = up.cross(axis_a)
    shape_settings = settings


func construct_mesh() -> void:
    var vertices = PackedVector3Array()
    vertices.resize(resolution * resolution)

    var normals = PackedVector3Array()
    normals.resize(resolution * resolution)

    var uvs = PackedVector2Array()
    uvs.resize(resolution * resolution)

    var triangles = PackedInt32Array()
    triangles.resize((resolution - 1) * (resolution - 1) * 2 * 3)

    var tri_index := 0

    for y in range(resolution):
        for x in range(resolution):
            var i = y * resolution + x
            var percent = Vector2(x, y) / (resolution - 1)
            var point_on_unit_cube = local_up + (percent.x - 0.5) * 2 * axis_a + (percent.y - 0.5) * 2 * axis_b
            var point_on_unit_sphere = point_on_unit_cube.normalized()
            var unscaled_elevation = shape_settings.calculate_unscaled_elevation(point_on_unit_sphere)
            vertices[i] = point_on_unit_sphere * shape_settings.calculate_scaled_elevation(unscaled_elevation)
            uvs[i].y = unscaled_elevation

            if x != resolution - 1 and y != resolution - 1:
                triangles[tri_index] = i
                triangles[tri_index+1] = i + resolution 
                triangles[tri_index+2] = i + resolution + 1
                triangles[tri_index+3] = i 
                triangles[tri_index+4] = i + resolution + 1
                triangles[tri_index+5] = i + 1
                tri_index += 6
    
    var surface_array = []
    surface_array.resize(Mesh.ARRAY_MAX)
    surface_array[Mesh.ARRAY_VERTEX] = vertices
    surface_array[Mesh.ARRAY_INDEX] = triangles
    surface_array[Mesh.ARRAY_TEX_UV] = uvs

    mesh.clear_surfaces()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

    mdt = MeshDataTool.new()
    mdt.create_from_surface(mesh, 0)
    Util.recalculate_normals(mdt, mesh)

    # var st = SurfaceTool.new()
    # st.begin(Mesh.PRIMITIVE_TRIANGLES)
    # for i in range(resolution * resolution):
    #     st.add_vertex(vertices[i])
    # for i in triangles:
    #     st.add_index(i)
    # st.generate_normals()
    # mesh.clear_surfaces()
    # mesh = st.commit(mesh)


func update_uv(biome_settings: BiomeColorSettings) -> void:
    # Logger.info("Updating UVs")

    for y in range(resolution):
        for x in range(resolution):
            var i = y * resolution + x
            var percent = Vector2(x, y) / (resolution - 1)
            var point_on_unit_cube = local_up + (percent.x - 0.5) * 2 * axis_a + (percent.y - 0.5) * 2 * axis_b
            var point_on_unit_sphere = point_on_unit_cube.normalized()
            var uv = mdt.get_vertex_uv(i)
            uv.x = biome_settings.biome_percent_from_point(point_on_unit_sphere)
            mdt.set_vertex_uv(i, uv)

    mesh.clear_surfaces()
    mdt.commit_to_surface(mesh)