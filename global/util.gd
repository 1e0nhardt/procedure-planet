class_name Util
extends RefCounted


static func recalculate_normals(mdt: MeshDataTool, mesh: ArrayMesh) -> void:
    for i in mdt.get_vertex_count():
        mdt.set_vertex_normal(i, Vector3.ZERO)
    
    for i in mdt.get_face_count():
        var ia = mdt.get_face_vertex(i, 0)
        var ib = mdt.get_face_vertex(i, 1)
        var ic = mdt.get_face_vertex(i, 2)

        var va = mdt.get_vertex(ia)
        var vb = mdt.get_vertex(ib)
        var vc = mdt.get_vertex(ic)
    
        var e1 = va - vb
        var e2 = vc - vb
        var n = e1.cross(e2)

        mdt.set_vertex_normal(ia, n + mdt.get_vertex_normal(ia))
        mdt.set_vertex_normal(ib, n + mdt.get_vertex_normal(ib))
        mdt.set_vertex_normal(ic, n + mdt.get_vertex_normal(ic))

    for i in mdt.get_vertex_count():
        mdt.set_vertex_normal(i, mdt.get_vertex_normal(i).normalized())
    
    # mdt做的所有修改都不是原地在mesh上进行的，在动态更新Mesh时，需要先清除mesh现存的surface。
    mesh.clear_surfaces()
    mdt.commit_to_surface(mesh)

