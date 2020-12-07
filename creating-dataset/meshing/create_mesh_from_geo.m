total_num = 1 ;
% create mesh from geo files
tic
% Path to gmsh. Edit as required
gmsh_cmd = 'D:\University\Master\Optical_BioImaging\Application\gmsh-4.1.5-Windows64\gmsh-4.1.5-Windows64\gmsh';

for i=1:total_num
    % Generate mesh from geometry definition
    system([gmsh_cmd ' -2 geos/mesh_geo_' num2str(i) '.geo -v 0 -format msh1 -o meshes/fmesh_' num2str(i) '.msh']);

    if rem(i,100) == 0
        disp(['index :  ' num2str(i)])
    end

end

toc