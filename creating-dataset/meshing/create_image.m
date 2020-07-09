step = 100;

for i = 1 : step
mesh = toastMesh(['meshes/fmesh_' num2str(i) '.msh'],'gmsh');
node_count = mesh.NodeCount ; 
el_count = mesh.ElementCount ;
reg = mesh.Region;
reg_unique = unique(reg) ;
%mesh.Display


grd = [128 128];
basis = toastBasis(mesh,grd);
elref = basis.GridElref;
regim = zeros(size(elref));
for j=1:length(elref)
  el = elref(j);
  if el>0  % SHOUD WORK ON WHAT IT MEANS
    regim(j) = reg(el);
  end
end
regim = reshape(regim,grd);
%%
regimm = uint8(regim*(255/max(reg))) ;
%imshow(regimm);
imwrite(regimm,['images/fmesh_' num2str(i) '_image.jpg'])

end
%imwrite(regimm,'images/fmesh_2_image.jpg')
%save('iamges/fmesh_2_image_data.mat', 'node_count' , 'el_count' ) ; 
