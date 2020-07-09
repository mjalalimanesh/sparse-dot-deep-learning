%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MMCLAB - Mesh-based Monte Carlo for MATLAB/Octave by Qianqina Fang
%
% In this example, we show the most basic usage of MMCLAB.
%
% This file is part of Mesh-based Monte Carlo (MMC) URL:http://mcx.sf.net/mmc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% prepare simulation input

clear cfg
phantom_radius = 16.1;
cfg.nphoton=5e5;


[no, fc]=meshacylinder([0 0 -10],[0 0 10],phantom_radius, 1, 1); % intralipid background
[nin,fin]=meshacylinder([-8,0,-15],[-8,0,15],4.5, 1, 1 ); % add the inclusion
[newnode,newelem]=surfboolean(no,fc,'first',nin,fin);  % merge the two domains

%c0=[10,100,150,26]';
seeds=[16, 0, 0; -8, 0 , 0];  % define the regions by index

%ISO2MESH_TETGENOPT='-Y -A'
[cfg.node,cfg.elem]=surf2mesh(newnode,newelem(:,1:3),[],[],1,30,seeds,[],0,'tetgen'); % creating the merged mesh domain


cfg.elemprop=ones(size(cfg.elem,1),1);
cfg.srcpos=[16.09 0  0];
cfg.srcdir=[-1 0 0];
cfg.prop=[0 0 1 1;0.0005 1 0.73 1.4; 0.002, 2, 0.73, 1.4];
cfg.tstart=0;
cfg.tend=5e-9;
cfg.tstep=5e-9;
cfg.debuglevel='TP';
cfg.issaveref=0;  % in addition to volumetric fluence, also save surface diffuse reflectance
nq = 29;
[Q,M] = make_QM( nq , phantom_radius );
cfg.detpos = zeros(nq,4);
cfg.detpos(:,1:2) = M;
cfg.detpos(:,3) = 0;
cfg.detpos(:,4) = 1 ;

figure();
plotmesh(cfg.node(:,1:3),cfg.elem(:,:),'z<0')

%% run the simulation

[flux, detp]=mmclab(cfg);

%% plotting the result

% plot the cross-section of the fluence
figure();
plotmesh([cfg.node(:,1:3),log10(abs(flux.data(1:size(cfg.node,1))))],cfg.elem(:,1:4),'z>0','facecolor','interp','linestyle','none')
view([0 0 1]);
colorbar;

for i=1:nq
    det_num(i) = sum(detp.detid==i);
end

figure();
ndet_num = det_num / max(max(det_num));
plot(ndet_num)
