% This Script will create input and output of network
% input is saved as Y and output is mua distribution in 
% mesh or matrix basis


% Number of samples
single_num = 20000z ;
double_num = 0 ;
total_num = single_num + double_num ;
total_num = 50;
% index will help to run program gradually and continue when error occurs 
fileID = fopen('index.txt','r');
index = fscanf(fileID,'%d') ;
fclose(fileID);
step = 3 ;

% parameters
phantom_radius = 17.5 ;
nq = 29 ;
[Q,M] = make_QM( nq , phantom_radius );
freq = 0 ;
mua_val = dlmread('coefficients/mua_val.txt');
lmus = [ 4.8 , 13. , 13. ] ; % [inclusion, intralipid, glass]
grd = [64 64];

% Initialize Variables
if index == 1 
    nnode = zeros(total_num,1) ;
    nelem = zeros(total_num,1) ;

    bmua_save = zeros( total_num, grd(1), grd(1)) ;
    bbmua_save = zeros( total_num, grd(1), grd(1)) ;
    Y_save = zeros( total_num , nq*1 ) ;
else
    load('saved_output/network_outputs.mat')
end


% for loop over samples
tic
for i = index : ( index + step )
    %% Read mesh and it's properties
    clear mesh
    mesh = toastMesh(['meshing/meshes/fmesh_' num2str(i) '.msh'],'gmsh');
    
    nnode(i) = mesh.NodeCount ; 
    nelem(i) = mesh.ElementCount ;
    reg = mesh.Region;
    reg_unique = unique(reg) ;
    %% Set Mua Mus Values
    basis = toastBasis(mesh,grd);
    elref = basis.GridElref;
    bmua_pre = zeros(size(elref));
    bmus_pre = zeros(size(elref));
    for j=1:length(elref)
      el = elref(j);
      if el>0  % SHOUD WORK ON WHAT IT MEANS
          bmua_pre(j) = mua_val(i, reg(el)) ;
          bmus_pre(j) = lmus(reg(el)) ;
      end
    end
    
    bmua = reshape(bmua_pre,grd);
    bmus = reshape(bmus_pre,grd);

    mua = basis.Map('B->M',bmua);
    mus = basis.Map('B->M',bmus);
    ref_bkg = 1.4;
    ref = ones(nnode(i),1) * ref_bkg;

    %figure();mesh.Display(mua);
    % read back to basis space to see effect of interpolation in B->M
    bbmua = basis.Map('M->B',mua);
    bbmua = reshape(bbmua,grd) ;
    
%     figure(5); imagesc((bbmua)); % original for network output
%     figure(6); imagesc((imresize(bbmua,2))); % for network output
%    figure(7); imagesc(imresize(imresize(bbmua,[45,45]),grd,'bilinear')); % for final show
    
    %% Sources and Detectors
    % Q and M was readed from function make_QM before loop
    mesh.SetQM(Q,M);    
    qvec = mesh.Qvec('Neumann','Gaussian',2);
    mvec = mesh.Mvec('Gaussian',2, ref);
    
%     figure; p1 = mesh.Display(mua) ;
%     hold on
%     p2 = plot(Q(:,1),Q(:,2),'ro','MarkerFaceColor','r','DisplayName','Source');
%     p3 = plot(M(1:3,1),M(1:3,2),'s','MarkerFaceColor','b','DisplayName', 'Detector' );
%     legend([p2,p3])
%     
    %% Forward Solver
    
    K = dotSysmat(mesh,mua,mus,ref,freq);
    Phi = K\qvec;
    Y = mvec.' * Phi;  % complex if freq != 0
    
%     figure
%     imagesc(log(Y));
%     xlabel('source index q');
%     ylabel('detector index m');
%     axis equal tight;
%     colorbar
    
    
    %% save to variables
    bbmua_image_save = uint8(bbmua*(255./max(max(bmua)))) ;
    imwrite(bbmua_image_save,['meshing/images/fmesh_' num2str(i) '_image.jpg'])
        
    
    bbmua_save(i,:,:) = bbmua ;
     figure(); plot( log(Y) );
    Y_save(i, :) = reshape( Y, [1,nq*1] ) ;

        
end

%% save to file
save('saved_output/network_outputs.mat', ...
     'bbmua_save','Y_save' ,'nnode', 'grd', 'nelem', '-v7.3'  ) ; 
%% index update
index = index + step + 1 ;
fileID = fopen('index.txt','w');
fprintf(fileID,'%d',index);
fclose(fileID);

toc