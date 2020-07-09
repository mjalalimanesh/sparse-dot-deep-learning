
% parameters
phantom_radius = 16.1 ;
nm = 29 ;
[Q,M] = make_QM( nm , phantom_radius );
freq = 0 ;
grd = [64 64];
% background [0.01 , 0.6, 1.7]
% background [0.001, 3 , 1.7]
% inclusion [1.82, 3 , 1.6]
lmua = [0.9 , 0.001]; % inclusion , intralipid
lmus = [ 3, 3];
lref = [1.7, 1.7];
% for loop over samples
tic
%% Read mesh and it's properties
clear mesh
mesh = toastMesh(['exp_middle.msh'],'gmsh');
nnode = mesh.NodeCount ; 
reg = mesh.Region;
%% Set Mua Mus Values
basis = toastBasis(mesh,grd);
elref = basis.GridElref;
bmua_pre = zeros(size(elref));
bmus_pre = zeros(size(elref));
ref_pre = zeros(size(elref));
for j=1:length(elref)
    el = elref(j);
    if el>0  % SHOUD WORK ON WHAT IT MEANS
        bmua_pre(j) = lmua(reg(el)) ;
        bmus_pre(j) = lmus(reg(el)) ;
        ref_pre(j) = lref(reg(el)) ;
    end
end

bmua = reshape(bmua_pre,grd);
bmus = reshape(bmus_pre,grd);
bref = reshape(ref_pre,grd);

%save('gdata/3_7.mat', 'bmua')

%%
mua = basis.Map('B->M',bmua);
mus = basis.Map('B->M',bmus);
ref = basis.Map('B->M',bref);

figure(); mesh.Display(mua)
%% Sources and Detectors
% Q and M was readed from function make_QM before loop
mesh.SetQM(Q,M);
qvec = mesh.Qvec('Neumann','Gaussian',2);
mvec = mesh.Mvec('Gaussian',2, ref);

    figure; p1 = mesh.Display(mua) ;
    colormap hot
    hold on
    p2 = plot(Q(:,1),Q(:,2),'ro','MarkerFaceColor','r','DisplayName','Source');
    p3 = plot(M(:,1),M(:,2),'s','MarkerFaceColor','b','DisplayName', 'Detector' );
    legend([p2,p3])
    axis('off')
%% Forward Solver

K = dotSysmat(mesh,mua,mus,ref,freq);
Phi = K\qvec;
Y = mvec.' * Phi;  % complex if freq != 0


%% save to filetoc
filename =  '33_inc.txt' ;
dlmwrite(filename,full(Y),'delimiter',',');
%%
dark_correction = [1.575, 3.85, 1, 0.85, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 , 0,  ...
                             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.85, 1, 3.85, 1.575];

homo_experiment_3 = [60.8, 40.8, 28.6, 20.6, 16, 12.8, 10.6, 9.3, 8.4, 8.1, 8.3, 8.7, 8.6, 8.3, 8.3, ...
    8.4, 8.8, 8.7, 8, 8, 8, 8.8, 10.1, 12.2, 15.2, 20.2, 27.6, 40.8, 60.8];

homo_experiment_3 = homo_experiment_3 - dark_correction;

experiment_3_2 = [58.6, 40, 27.6, 19.8, 15, 11.8, 9.4, 8, 6.8, 6.3, 6, 5.9, 5.2, 4.7, 4.5,  ...
                  4.9, 5.6, 5.9, 5.7, 6, 6.4, 7.4, 8.8, 11.3, 14.2, 18.8, 26.4, 38.4, 57.6];         
experiment_3_2 = experiment_3_2 - dark_correction;

experiment_3_1 = [59.8, 40.8, 27.2, 20.2, 15, 12, 10, 8.6, 7.7, 7.4, 7.4, 7.6, 7.4, 7.1, 6.8, ...
                  6.7, 6.8, 6.2, 5.3, 4.5, 4, 3.8, 3.9, 4.8, 6.6, 10.8, 18.8, 32.4, 53.6];
experiment_3_1 = experiment_3_1 - dark_correction;

nexperiment_3_2 = experiment_3_2/max(max(experiment_3_2));
nexperiment_3_1 = experiment_3_1/max(max(experiment_3_1));
nhomo_experiment_3 = homo_experiment_3/max(max(homo_experiment_3));

homo_experiment_1 = [62.4, 40, 28.8, 20.8, 14.8, 12, 8.8, 8, 7.2, 6.4, 6.4, 6.4, 6.6, 6.4, 6.4, ...
    6.4, 6.4, 6.4, 6.4, 6.4, 6.8, 8, 9, 11.6, 14.4, 20, 28, 40, 61.6];
%plot(homo_experiment_1/max(max(homo_experiment_1)), '-.') 

% phantom 1 in 270 about 1-2mm away
experiment_1_1 = [59.4, 39.2, 28, 19.4, 13.6, 9.6, 8, 6.4, 6.4, 5.4, 4.8, 5, 5, 4.8, 4,  ...
    3.8, 3.2, 3.2, 2.4, 2, 1.6, 1.8, 2.4, 3.2, 6.4, 12, 20, 33.6, 57.4];
% phantom 1 in 180 about 2mm away
experiment_1_2 = [60, 40, 28.8, 19.6, 13.6, 9.6, 7, 6, 4.4, 3.2, 3.2, 3.2, 3.2, 2.4, 2.4,  ...
    3.2, 3.2, 3.2, 3.4, 4, 5.6, 6.4, 8, 10.4, 13.6, 18.6, 26.4, 39.8, 60];

nY = (Y)/max(max(Y));
nexperiment_1_2 = experiment_1_2/max(max(experiment_1_2));
nexperiment_1_1 = experiment_1_1/max(max(experiment_1_1));
nhomo_experiment_1 = homo_experiment_1/max(max(homo_experiment_1));

scale = (max(nhomo_experiment_3) - min(nhomo_experiment_3)) / (max(nY)-min(nY));
scale = 0.9111;
nY = nY * scale ;
nYp = nY + (1-max(nY)) ;
%nhomo_experiment_3p = nhomo_experiment_3 - min(min(nexperiment_3_1)) + 0.1 ;

figure(); plot((nYp),'-o', 'linewidth', 2);
hold on
plot(nhomo_experiment_3, '-s', 'linewidth', 2)
legend('Simulation','Experiment')


[r2, rmse] = rsquare(nhomo_experiment_3, nYp')

 %%
% homo_experiment_3 = [60.8, 40.8, 28.6, 20.6, 16, 12.8, 10.6, 9.3, 8.4, 8.1, 8.3, 8.7, 8.6, 8.3, 8.3, ...
%     8.4, 8.8, 8.7, 8, 8, 8, 8.8, 10.1, 12.2, 15.2, 20.2, 27.6, 40.8, 60.8];
% %plot((homo_experiment_3/max(max(homo_experiment_1))), '-.') 
% 
% 
% experiment_3_2 = [58.6, 40, 27.6, 19.8, 15, 11.8, 9.4, 8, 6.8, 6.3, 6, 5.9, 5.2, 4.7, 4.5,  ...
%                   4.9, 5.6, 5.9, 5.7, 6, 6.4, 7.4, 8.8, 11.3, 14.2, 18.8, 26.4, 38.4, 57.6];
% 
%               
% experiment_3_1 = [59.8, 40.8, 27.2, 20.2, 15, 12, 10, 8.6, 7.7, 7.4, 7.4, 7.6, 7.4, 7.1, 6.8, ...
%                   6.7, 6.8, 6.2, 5.3, 4.5, 4, 3.8, 3.9, 4.8, 6.6, 10.8, 18.8, 32.4, 53.6];
% nY = (Y)/max(max(Y));
% figure(); plot((nY),'-o');
% hold on
% nexperiment_3_2 = experiment_3_2/max(max(experiment_3_2));
% nexperiment_3_1 = experiment_3_1/max(max(experiment_3_1));
% 
% plot(nexperiment_3_2, '-s')
% 
% 
% [r2 rmse] = rsquare(homo_experiment_3/max(max(homo_experiment_3)),((Y')/max(max(Y))));
% 
% [r2 rmse] = rsquare(experiment_3_2/max(max(experiment_3_2)),((Y')/max(max(Y))));
