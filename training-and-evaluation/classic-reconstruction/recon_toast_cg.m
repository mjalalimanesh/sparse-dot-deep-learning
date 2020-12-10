
function score = recon_toast_cg(tau, beta, smode, num, itrmax_cg)
disp('2D image reconstruction with cg solver')
% ======================================================================
% User-defined parameters
% ======================================================================
verbosity = 0;
refind = 1.7;

grd = [64 64];
freq = 0 ;
%tau = 1e-3;                             % regularisation parameter
                                        % 1e-4 for 3_2
                                        % 5e-1 for 3_4
beta0 = beta;                            % TV regularisation parameter
tolGN = 1e-7;                           % Gauss-Newton convergence criterion
tolKrylov = 1e-2;                       % Krylov convergence criterion
itrmax = itrmax_cg;                           % Gauss-Newton max. iterations
Himplicit = true;                       % Implicit/explicit Hessian matrix
cmap = 'gray';
noiselevel = 0.10;
tolCG = 1e-6;                           % Gauss-Newton convergence criterion
resetCG = 10;                           % PCG reset interval

% ======================================================================
% End user-defined parameters
% ======================================================================


toastSetVerbosity(verbosity);           % output verbosity level
c0 = 0.3;                               % lightspeed in vacuum [mm/ps]
cm = c0/refind;                         % lightspeed in medium
%%
%load('network_outputs.mat', 'bbmua_save', 'Y_save');
[homo_experiment, experiment] = read_experiment_data();
homo_sim = dlmread('homo.txt');
%%
smode = smode; % 'exp', 'sim', 'else'
sim_id = num; 
exp_id = num; 
if all(smode == 'sim')
    sample = Y_save(sim_id,:);
elseif all(smode == 'exp')
    sample = experiment(exp_id, :);
else    
    sample = dlmread(['special_simulation_measurements/3_' num2str(exp_id) '.txt']);
end
%% Generate target data
%mdata = mdata + mdata.*noiselevel.*randn(size(mdata));
if all(smode == 'exp')
    scale = (max(homo_sim) - min(homo_sim)) / (max(homo_experiment)-min(homo_experiment));
    sample = (sample * scale)';
    sample = sample + (max(homo_sim)-max(sample));
elseif all(smode == 'sim')
    sample = sample';
end
log_sample = log(sample);
mdata = real(log_sample);
pdata = zeros(size(mdata));

data = [mdata];

m = length(data);

% display the target parameter distributions for comparison
if all(smode=='sim')
    bmua_tgt = reshape(bbmua_save(sim_id, :), 64, 64) ;
    mua_val =  dlmread('mua_val.txt');
    list_mua = mua_val(sim_id,:);
else
    load_struct = load(['gdata/3_' num2str(exp_id) '.mat']);
    bmua_tgt = (load_struct.bmua)';
    list_mua = [max(max(bmua_tgt)) ,1e-3 ,1e-6];
end
list_mus = [ 3 , 3 , 3 ] ;
muarng = [0.9*list_mua(2) 1.1*list_mua(1)];
f = figure('visible', 'on'); subplot(2,2,1); imagesc(bmua_tgt,muarng)
colormap(cmap); colorbar; axis equal
title ('\mu_a tgt');
xlim([0, 64])
ylim([0, 64])

%%
clear bbmua_save Y_save
%% Inverse solver

% Read a TOAST mesh definition from file.
invmesh = toastMesh('homogen0.msh','gmsh');       % read inverse solver mesh
phantom_radius = 16.1 ;
nq = 29 ;
[QQ,MM] = make_QM( nq , phantom_radius );         % add source/detector descriptions
n = invmesh.NodeCount ();


% Set up homogeneous initial parameter estimates
mua = ones(n,1) * list_mua(2);                            % initial mua estimate
mus = ones(n,1) * list_mus(2);                                % initial mus estimate
ref = ones(n,1) * refind;                           % refractive index estimate
kap = 1./(3*(mua+mus));                             % diffusion coefficient

%figure(); invmesh.Display(mua)

% Set up the mapper between FEM and solution bases
hbasis = toastBasis(invmesh, grd);         % maps between mesh and reconstruction basis

% add source-detector descriptions
invmesh.SetQM(QQ,MM);
% Generate source vectors
qvec = invmesh.Qvec('Neumann','Gaussian',2);
% Generate measurement vectors
mvec = invmesh.Mvec('Gaussian',2, ref);

% Initial data set f[x0]
smat = dotSysmat (invmesh, mua, mus, ref, freq);      % FEM system matrix
lgamma = reshape (log(mvec.' * (smat\qvec)), [], 1);% solve for photon density and map to boundary measurements


mproj = real(lgamma);                               % log amplitude data
pproj = zeros(size(mproj));                               % phase data
proj = [mproj];                               % linear measurement vector


% data scaling
msd = ones(size(lgamma)) * norm(mdata-mproj);       % scale log amp data with data difference
psd = ones(size(lgamma)) ;       % scale phase data with data difference
sd = [msd];                                     % linear scaling vector                                    % linear scaling vector

% map initial parameter estimates to solution basis
bmua = hbasis.Map ('M->B', mua);                    % mua mapped to full grid
bmus = hbasis.Map ('M->B', mus);                    % mus mapped to full grid
bkap = hbasis.Map ('M->B', kap);                    % kap mapped to full grid
bcmua = bmua*cm;                                    % scale parameters with speed of light
bckap = bkap*cm;                                    % scale parameters with speed of light
scmua = hbasis.Map ('B->S', bcmua);                 % map to solution basis
sckap = hbasis.Map ('B->S', bckap);                 % map to solution basis

% solution vector
x = [scmua];                                  % linea solution vector
logx = log(x);                              % transform to log
p = length(x);                              % solution vector dimension


% Initialise regularisation
hreg = toastRegul ('TV', hbasis, logx, tau, 'Beta', beta);
%hreg = toastRegul('MRF',hbasis,logx,tau);

% initial data error (=2 due to data scaling)
err0 = toastObjective (proj, data, sd, hreg, logx); %initial error
err = err0;                                         % current error
errp = inf;                                         % previous error
erri(1) = err0;                                     % keep history
itr = 1;                                            % iteration counter
fprintf (1, '\n**** INITIAL ERROR %f\n\n', err);
step = 1.0;                                         % initial step length for line search

% Nonlinear conjugate gradient loop
while (itr <= itrmax) && (err > tolCG*err0) && (errp-err > tolCG)

    errp = err;
    
    % Gradient of cost function
    r = -toastGradient (invmesh, hbasis, qvec, mvec, mua, mus, ref, 0, ...
                       data, sd, 'method', 'CG', 'tolerance', 1e-12);
    r = r(1:3096);
    r = r .* x;                   % parameter scaling
    r = r - hreg.Gradient (logx); % regularisation contribution
    
    if itr > 1
        delta_old = delta_new;
        delta_mid = r' * s;
    end
    
    % Apply PCG preconditioner
    s = r; % dummy for now
    
    if itr == 1
        d = s;
        delta_new = r' * d;
    else
        delta_new = r' * s;
        beta = (delta_new - delta_mid) / delta_old;
        if mod (itr, resetCG) == 0 || beta <= 0
            d = s;  % reset CG
        else
            d = s + d*beta;
        end
    end
    
    % Line search
    fprintf (1, 'Line search:\n');
    step = toastLineSearch (logx, d, step, err, @objective);
    
    % Add update to solution
    logx = logx + d*step;
    x = exp(logx);
    
    % Map parameters back to mesh
    scmua = x(1:size(x));
%    sckap = x(size(x)/2+1:size(x));
    smua = scmua/cm;
    skap = sckap/cm;
%    smus = 1./(3*skap) - smua;
    mua = hbasis.Map ('S->M', smua);
    mus = mus;
    bmua = hbasis.Map ('S->B', smua);
    bmus = bmus;

    %figure(1);
    f; subplot(2,2,2);
    muarec_img(itr, :, :) = reshape(bmua,grd);
    imagesc(squeeze(muarec_img(itr, :, :)))
    colormap(cmap); colorbar; axis equal
    xlim([0, 64])
    ylim([0, 64])
    
    % update projection from current parameter estimate
    mproj = toastProject (invmesh, mua, mus, ref, freq, qvec, mvec);
    pproj = zeros(size(mproj));
    proj = [mproj];

    
    % update objective function
    err = toastObjective (proj, data, sd, hreg, logx);
    fprintf ('GN iteration %d\n', itr);
    fprintf ('--> Objective: %f\n', err);

    itr = itr+1;
    erri(itr) = err;
    
    % show objective function
    f;subplot(2,2,[3, 4]);
    semilogy(erri);
    axis([1 itr 1e-2 2])
    xlabel('iteration');
    ylabel('objective function');
    xticks([1:itrmax+1])
end
score = mean((reshape(bmua,grd) - bmua_tgt).^2, 'all');
saveim = reshape(bmua,grd);
save(['exp_cg\expid-' num2str(exp_id)],'saveim');
disp('recon1: finished')
path = ['images_cg\tau-' num2str(tau) '-beta-' num2str(beta0) '-itrmax-' num2str(itrmax) '-' smode 'id-' num2str(exp_id) '.jpg'];
print(path, '-djpeg')
    % =====================================================================
    % Callback function for objective evaluation (called by toastLineSearch)
    function p = objective(x)
        
        [mua,mus] = dotXToMuaMus (hbasis, exp(x), ref, mus);
        mproj = toastProject (invmesh, mua, mus, ref, freq, qvec, mvec);
        pproj = zeros(size(mproj));
        proj = [mproj];
        [p, p_data, p_prior] = toastObjective (proj, data, sd, hreg, x);
        if verbosity > 0
            fprintf (1, '    [LH: %f, PR: %f]\n', p_data, p_prior);
        end
    end


    function logx = my_log(x)
        filter = x > 0 ;
        logx = zeros( size(x) );
        logx(filter) = log(x(filter));
        logx( ~filter ) = log(min(x(filter))) ;
    end

end
