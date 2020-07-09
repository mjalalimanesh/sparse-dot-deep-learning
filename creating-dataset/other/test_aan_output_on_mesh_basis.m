
a = load('test24.mat');
load('network_outputs.mat', 'bbmua_save');
bbmua =  dlmread('bbmua.txt');

bmua_ann = a.test24;
bmua_input = reshape(bbmua(20141+1, :), 64, 64) ;

filter  = fspecial('disk', 5);
aa = imfilter(bmua_ann, filter,'replicate');
bmua_ann = medfilt2(bmua_ann, [8 8]);

figure; imagesc(bmua_ann) ;
figure; imagesc(bmua_input) ;
%%
mesh = toastMesh(['fmesh_' num2str(20142) '.msh'],'gmsh');

grd = [64 64] ;
nnode = mesh.NodeCount ;
nelem = mesh.ElementCount ;
reg = mesh.Region;
reg_unique = unique(reg) ;

basis = toastBasis(mesh,grd);

mua = basis.Map('B->M',bmua_ann);
figure; mesh.Display(mua)







