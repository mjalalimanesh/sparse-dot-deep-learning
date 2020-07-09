mesh = toastMesh('fmesh_1.msh','gmsh');
mesh.NodeCount
mesh.ElementCount
reg = mesh.Region;
figure()
mesh.Display()
unique(reg)

export_fig('fig1', '-q101', '-m3', '-transparent')