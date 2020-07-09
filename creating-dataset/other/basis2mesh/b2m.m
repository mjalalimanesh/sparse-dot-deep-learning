%% Three Sections, should't run together
 %%
hmesh = toastMesh('homo.msh','gmsh');       % read mesh
grd = [64 64];
hbasis = toastBasis(hmesh, grd);         % maps between mesh and reconstruction basis

for i=1:7
    
    num = ['3_' num2str(i)];
    
    gdata = load(['gdata/' num '.mat']); bmua_g = gdata.bmua;
    bmua_exp = readNPY(['pydata/' num '_exp.npy']);
    matdata = load(['matdata/' num '_exp.mat']); bmua_sim = reshape(matdata.bmua,grd);

    
    mua_g = hbasis.Map ('B->M', bmua_g');
    mua_exp = hbasis.Map ('B->M', bmua_exp);
    mua_sim = hbasis.Map ('B->M', bmua_sim);
    
    fig = figure();
    set(fig, 'Color', 'w', 'Position', get(0, 'Screensize'));
    subaxis(1,3,3, 'Spacing', 0.02, 'Padding', 0, 'Margin', 0.01); hmesh.Display(mua_exp,'range',[0 1*max(mua_exp)])
    colorbar('off')
    colorbar('southoutside','FontSize', 13, 'FontWeight', 'bold')
    colormap hot
    axis off
    subaxis(1,3,2, 'Spacing', 0.02, 'Padding', 0, 'Margin', 0.01); hmesh.Display(mua_sim,'range',[0 1*max(mua_sim)])
    colorbar('off')
    colorbar('southoutside','FontSize', 13, 'FontWeight', 'bold')
    colormap hot
    axis off
    subaxis(1,3,1, 'Spacing', 0.02, 'Padding', 0, 'Margin', 0.01); hmesh.Display(mua_g)
    colorbar('off')
    colorbar('southoutside', 'FontSize', 13, 'FontWeight', 'bold')
    colormap hot
    axis off
    
    name = ['outs/' num '.png'];
    export_fig(name, '-q101', '-m3')
end


 %% For sim data
% 
% 
% hmesh = toastMesh('homo.msh','gmsh');       % read mesh
% grd = [64 64];
% hbasis = toastBasis(hmesh, grd);         % maps between mesh and reconstruction basis
% list = [3, 4, 7];
% for j=1:length(list)
%     i = list(j);
%     num = ['3_' num2str(i)];
%     
%     gdata = load(['gdata_old/' num '.mat']); bmua_g = gdata.bmua;
%     bmua_exp = readNPY(['pydata/' num '_0.npy']);
%     matdata = load(['matdata/' num '_0.mat']); bmua_sim = reshape(matdata.bmua,grd);
% 
%     
%     mua_g = hbasis.Map ('B->M', bmua_g');
%     mua_exp = hbasis.Map ('B->M', bmua_exp);
%     mua_sim = hbasis.Map ('B->M', bmua_sim);
%     
%     fig = figure();
%     set(fig, 'Color', 'w', 'Position', get(0, 'Screensize'));
%     subaxis(1,3,1, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0); hmesh.Display(mua_exp,'range',[0 0.99*max(mua_exp)])
%     colorbar('FontSize', 11, 'FontWeight', 'bold')
%     colormap hot
%     axis off
%     subaxis(1,3,2, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0); hmesh.Display(mua_sim,'range',[0 0.99*max(mua_sim)])
%     colorbar('FontSize', 11, 'FontWeight', 'bold')
%     colormap hot
%     axis off
%     subaxis(1,3,3, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0); hmesh.Display(mua_g)
%     colorbar('FontSize', 11, 'FontWeight', 'bold')
%     colormap hot
%     axis off
%     
%     name = ['outs_sim/' num '.png'];
%     export_fig(name, '-q101', '-m3')
% end


%% For cnn data


% hmesh = toastMesh('homo.msh','gmsh');       % read mesh
% grd = [64 64];
% hbasis = toastBasis(hmesh, grd);         % maps between mesh and reconstruction basis
% 
% for j=7:7
%     i = j;
%     num = ['3_' num2str(i)];
%     
%     gdata = load(['gdata_old/' num '.mat']); bmua_g = gdata.bmua;
%     bmua_exp = readNPY(['pydata/' num '_exp.npy']);
%     cnn_exp = readNPY(['cnn_pydata/' num '_exp.npy']);
% 
%     if i>4
%         bmua_g = bmua_g';
%     end
%     
%     if i == 7
%         bmua_g = flip(bmua_g);
%     end
%     
%     
%     mua_g = hbasis.Map ('B->M', bmua_g');
%     mua_exp = hbasis.Map ('B->M', bmua_exp);
%     mua_sim = hbasis.Map ('B->M', cnn_exp);
%     
%     fig = figure();
%     set(fig, 'Color', 'w', 'Position', get(0, 'Screensize'));
%     subaxis(1,3,1, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0); hmesh.Display(mua_exp,'range',[0 0.99*max(mua_exp)])
%     colorbar('FontSize', 11, 'FontWeight', 'bold')
%     colormap hot
%     axis off
%     subaxis(1,3,2, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0); hmesh.Display(mua_sim,'range',[0 0.99*max(mua_sim)])
%     colorbar('FontSize', 11, 'FontWeight', 'bold')
%     colormap hot
%     axis off
%     subaxis(1,3,3, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0); hmesh.Display(mua_g)
%     colorbar('FontSize', 11, 'FontWeight', 'bold')
%     colormap hot
%     axis off
%     
%     name = ['outs_cnn/' num '.png'];
%     export_fig(name, '-q101', '-m3')
% end