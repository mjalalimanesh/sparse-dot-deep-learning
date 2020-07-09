function recon_lm
tic
disp('MATLAB-TOAST sample script:')
disp('2D image reconstruction with Levenberg-Marquardt solver')
disp('-------------------------------------------------------')

% ======================================================================
% User-defined parameters
% ======================================================================
verbosity = 1;
refind = 1.7;                           % refractive index

grd = [64 64];                        % solution basis: grid dimension
freq = 0;                             % modulation freqcleuency [MHz]
noiselevel = 0.0;                      % additive data noise level
tau = 1e-3;                             % regularisation parameter
beta = 0.01;                            % TV regularisation parameter
eps = 0.02;
tolGN = 1e-5;                           % Gauss-Newton convergence criterion
tolKrylov = 1e-2;                       % Krylov convergence criterion
itrmax = 25;                           % Gauss-Newton max. iterations
Himplicit = true;                       % Implicit/explicit Hessian matrix
cmap = 'gray';

% ======================================================================
% End user-defined parameters
% ======================================================================

% Initialisations
%toastCatchErrors();                     % redirect toast library errors
toastSetVerbosity(verbosity);           % output verbosity level
c0 = 0.3;                               % lightspeed in vacuum [mm/ps]
cm = c0/refind;                         % lightspeed in medium

%% load data
load('network_outputs.mat', 'bbmua_save', 'Y_save');

%% Generate target data
py_id = 14; % 39 33 34 
Y_full =  Y_save;
lgamma = log(Y_full(py_id+1,:))';
mdata = real(lgamma);
%scale = (max(mdata0) - min(mdata0)) / (max(nexperiment_3_2)-min(nexperiment_3_2));
%mdata = log(nexperiment_3_2)' * scale;
pdata = zeros(size(mdata)) ;
data = [mdata;pdata];

% add some noise
mdata = mdata + mdata.*noiselevel.*randn(size(mdata));
pdata = pdata + pdata.*noiselevel.*randn(size(pdata));
data = [mdata;pdata];                               % linear data vector
m = length(data);                                   % number of measurement data

% display the target parameter distributions for comparison
bbmua =  bbmua_save;
clear bbmua_save Y_save
bmua_tgt = reshape(bbmua(py_id+1, :), 64, 64) ;
mua_val =  dlmread('mua_val.txt');
list_mua = mua_val(py_id+1,:);
list_mus = [ 3 , 3 , 3 ] ;
muarng = [0.9*list_mua(2) 1.1*list_mua(1)];
figure(1); subplot(1,2,1); imagesc(bmua_tgt,muarng)
colormap(cmap); colorbar; axis equal
title ('\mu_a tgt');


%% Inverse solver

% Read a TOAST mesh definition from file.
invmesh = toastMesh('homogen0.msh','gmsh');       % read inverse solver mesh
phantom_radius = 16.1 ;
nq = 29 ;
[QQ,MM] = make_QM( nq , phantom_radius );         % add source/detector descriptions
n = invmesh.NodeCount ();                             % number of nodes

% Set up homogeneous initial parameter estimates
mua = ones(n,1) * list_mua(2);                            % initial mua estimate
mus = ones(n,1) * list_mus(2);                                % initial mus estimate
ref = ones(n,1) * refind;                           % refractive index estimate
kap = 1./(3*(mua+mus));                             % diffusion coefficient

figure(); invmesh.Display(mua)

% Set up the mapper between FEM and solution bases
hbasis = toastBasis (invmesh, grd, 'LINEAR');         % maps between mesh and reconstruction basis

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
proj = [mproj;pproj];                               % linear measurement vector

% data scaling
% linear scaling vector
msd = ones(size(lgamma)) * norm(mdata-mproj);       % scale log amp data with data difference
psd = ones(size(lgamma)) ;       % scale phase data with data difference
sd = [msd;psd];                                     % linear scaling vector

% map initial parameter estimates to solution basis
bmua = hbasis.Map ('M->B', mua);                    % mua mapped to full grid
bmus = hbasis.Map ('M->B', mus);                    % mus mapped to full grid
bkap = hbasis.Map ('M->B', kap);                    % kap mapped to full grid
bcmua = bmua*cm;                                    % scale parameters with speed of light
bckap = bkap*cm;                                    % scale parameters with speed of light
scmua = hbasis.Map ('B->S', bcmua);                 % map to solution basis
sckap = hbasis.Map ('B->S', bckap);                 % map to solution basis

% solution vector
x = [scmua;sckap];                                  % linea solution vector
logx = log(x);                                      % transform to log
p = length(x);                                      % solution vector dimension

% Initialise regularisation
%hreg = toastRegul ('TV', hbasis, logx, tau, 'Beta', beta);
hreg = toastRegul ('Huber', hbasis, logx, tau, 'Eps', eps);

% initial data error (=2 due to data scaling)
err0 = toastObjective (proj, data, sd, hreg, logx); %initial error
err = err0;                                         % current error
errp = inf;                                         % previous error
erri(1) = err0;                                     % keep history
itr = 1;                                            % iteration counter
fprintf (1, '\n**** INITIAL ERROR %f\n\n', err);
lambda = 1e-8;                                      % initial value of LM control parameter

img_rec_mua = reshape(bmua,grd);
img_rec_mus = reshape(bmus,grd);

% Gauss-Newton loop
while (itr <= itrmax) && (err > tolGN*err0) && (errp-err > tolGN)

    errp = err;
    
    % Construct the Jacobian
    fprintf (1,'Calculating Jacobian\n');
    J = toastJacobian (invmesh, hbasis, qvec, mvec, mua, mus, ref, freq, 'direct');

    % data normalisation
    for i = 1:m
        J(i,:) = J(i,:) / sd(i);
    end

    % parameter normalisation (map to log)
    for i = 1:p
        J(:,i) = J(:,i) * x(i);
    end
    
    % Normalisation of Hessian (map to diagonal 1)
    psiHdiag = hreg.HDiag(logx);
    M = zeros(p,1);
    for i = 1:p
        M(i) = sum(J(:,i) .* J(:,i));
        M(i) = M(i) + psiHdiag(i);
        M(i) = 1 ./ sqrt(M(i));
    end
    for i = 1:p
        J(:,i) = J(:,i) * M(i);
    end
    
    % Gradient of cost function
    r = J' * ((data-proj)./sd);
    r = r - hreg.Gradient (logx) .* M;
    
    while 1
        
    if Himplicit == true
        % Update with implicit Krylov solver
        fprintf (1, 'Entering Krylov solver\n');
        dx = toastKrylov (x, J, r, M, lambda, hreg, tolKrylov);
    else
        % Update with explicit Hessian
        H = J' * J;
        H = H + eye(size(H)).* lambda;
        dx = H \ r;
        clear H;
    end
    
    logx_new = logx + dx;
    x_new = exp(logx_new);
    scmua = x_new(1:size(x_new)/2);
    sckap = x_new(size(x_new)/2+1:size(x_new));
    smua = scmua/cm;
    skap = sckap/cm;
    smus = 1./(3*skap) - smua;
    mua = hbasis.Map ('S->M', smua);
    mus = hbasis.Map ('S->M', smus);

    mproj = toastProject (invmesh, mua, mus, ref, freq, qvec, mvec);
    pproj = zeros(size(mproj));
    proj = [mproj;pproj];
	err_new = toastObjective (proj, data, sd, hreg, logx);
    
    if err_new < err
        logx = logx_new;
        err = err_new;
        lambda = lambda/2;
        break;
    else
        lambda = lambda*2;
    end
    
    end
    
    clear J;
    
    lambda
    x = exp(logx);
    
    % Map parameters back to mesh
    scmua = x(1:size(x)/2);
    sckap = x(size(x)/2+1:size(x));
    smua = scmua/cm;
    skap = sckap/cm;
    smus = 1./(3*skap) - smua;
    mua = hbasis.Map ('S->M', smua);
    mus = hbasis.Map ('S->M', smus);
    bmua = hbasis.Map ('S->B', smua);
    bmus = hbasis.Map ('S->B', smus);

    % display the reconstructions
    figure(1); subplot(1,2,2);
    muarec_img = reshape(bmua,grd);
    imagesc(muarec_img)
    colormap(cmap); colorbar; axis equal
    
    % update projection from current parameter estimate
    mproj = toastProject (invmesh, mua, mus, ref, freq, qvec, mvec);
    pproj = zeros(size(mproj));
    proj = [mproj;pproj];

    % update objective function
    err = toastObjective (proj, data, sd, hreg, logx);
    fprintf (1, '**** GN ITERATION %d, ERROR %f\n\n', itr, err);

    itr = itr+1;
    erri(itr) = err;
    
    % show objective function
	figure(2)
	semilogy(erri);
    axis([1 itr 1e-2 2])
    xlabel('iteration');
    ylabel('objective function');
    drawnow
    
    if mod(itr,1) == 0
        img_rec_mua = [img_rec_mua muarec_img];
    end
end

disp('recon2: finished')
figure(10);invmesh.Display(mua)
    % =====================================================================
    % Callback function for objective evaluation (called by toastLineSearch)
    function p = objective(x)

    [mua,mus] = dotXToMuaMus (hbasis, exp(x), ref);
    mproj = toastProject (invmesh, mua, mus, ref, freq, qvec, mvec);
    pproj = zeros(size(mproj));
    proj = [mproj;pproj];
  
	[p, p_data, p_prior] = toastObjective (proj, data, sd, hreg, x);
    if verbosity > 0
        fprintf (1, '    [LH: %f, PR: %f]\n', p_data, p_prior);
    end
    end
toc
end
