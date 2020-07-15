function recon_toast
disp('2D image reconstruction with Gauss-Newton solver')
% ======================================================================
% User-defined parameters
% ======================================================================
verbosity = 1;
refind = 1.7;

grd = [64 64];
freq = 0 ;
tau = 5e-6;                             % regularisation parameter
                                        % 1e-4 for 3_2
                                        % 5e-1 for 3_4
beta = 0.02;                            % TV regularisation parameter
tolGN = 1e-7;                           % Gauss-Newton convergence criterion
tolKrylov = 1e-2;                       % Krylov convergence criterion
itrmax = 1;                           % Gauss-Newton max. iterations
Himplicit = true;                       % Implicit/explicit Hessian matrix
cmap = 'gray';
noiselevel = 0.25;

% ======================================================================
% End user-defined parameters
% ======================================================================


toastSetVerbosity(verbosity);           % output verbosity level
c0 = 0.3;                               % lightspeed in vacuum [mm/ps]
cm = c0/refind;                         % lightspeed in medium
%%
load('network_outputs.mat', 'bbmua_save', 'Y_save');

%%
[nhomo_experiment_3, nexperiment_3_1, nexperiment_3_2, nexperiment_3_3, nexperiment_3_4, nexperiment_3_5, nexperiment_3_6, nexperiment_3_7] = read_experiment_data(); %#ok<ASGLU,NASGU>
homo_sim = dlmread('homo.txt');
sample = dlmread('data/3_2.txt');
%% Generate target data
id = 59; % 37,43:90,  44,55:270,  52,59:180,  54:middle
Y_full =  Y_save;
lgamma = log(Y_full(id,:))';
mdata00 = real(lgamma);
%mdata = mdata + mdata.*noiselevel.*randn(size(mdata));
scale = (max(homo_sim) - min(homo_sim)) / (max(nhomo_experiment_3)-min(nhomo_experiment_3));
scale = 0.0028;
scale = 0.002897;
mdata0 = (nexperiment_3_4 * scale)';
mdata1 = mdata0 + (max(homo_sim)-max(mdata0));
mdata = log(mdata1);
pdata = zeros(size(mdata)) ;
data = [mdata];

m = length(data);

% display the target parameter distributions for comparison
bbmua =  bbmua_save;
clear bbmua_save Y_save
bmua_tgt = reshape(bbmua(id, :), 64, 64) ;
mua_val =  dlmread('mua_val.txt');
list_mua = mua_val(id,:);
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
n = invmesh.NodeCount ();


% Set up homogeneous initial parameter estimates
mua = ones(n,1) * list_mua(2);                            % initial mua estimate
mus = ones(n,1) * list_mus(2);                                % initial mus estimate
ref = ones(n,1) * refind;                           % refractive index estimate
kap = 1./(3*(mua+mus));                             % diffusion coefficient

figure(); invmesh.Display(mua)

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
% linear scaling vector
msd = ones(size(lgamma)) * norm(mdata-mproj);       % scale log amp data with data difference
psd = ones(size(lgamma)) ;       % scale phase data with data difference
sd = [msd];                                     % linear scaling vector
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
hreg = toastRegul('TV', hbasis, logx, tau, 'Beta', beta);

% initial data error (=2 due to data scaling)
err0 = toastObjective(proj, data, sd, hreg, logx); %initial error
err = err0;                                         % current error
errp = inf;                                         % previous error
erri(1) = err0;                                     % keep history
itr = 1;                                            % iteration counter
fprintf (1, '\n**** INITIAL ERROR %f\n\n', err);
step = 1.0;                                         % initial step length for line search



% Gauss-Newton loop
while (itr <= itrmax) && (err > tolGN*err0) && (errp-err > tolGN)
    
    errp = err;
    
    % Construct the Jacobian
    fprintf (1,'Calculating Jacobian\n');
    J = toastJacobian(invmesh, hbasis, qvec, mvec, mua, mus, ref, freq, 'direct');
    J = J(1:m, 1:(size(J,2)/2));
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
    
    if Himplicit == true
        % Update with implicit Krylov solver
        fprintf (1, 'Entering Krylov solver\n');
        dx = toastKrylov (x, J, r, M, 0, hreg, tolKrylov);
    else
        % Update with explicit Hessian
        H = J' * J;
        lambda = 0.1;
        H = H + eye(size(H)).* lambda;
        dx = H \ r;
        clear H;
    end
    
    clear J;
    
    % Line search
    fprintf (1, 'Entering line search\n');
    step0 = step;
    [step, err] = toastLineSearch (logx, dx, step0, err, @objective, 'verbose', verbosity>0);
    if errp-err <= tolGN
        dx = r; % try steepest descent
        step = toastLineSearch (logx, dx, step0, err, @objective, 'verbose', verbosity>0);
    end
    
    % Add update to solution
    logx = logx + dx*step;
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
    
    % display the reconstructions
    figure(1); subplot(1,2,2);
    muarec_img(itr, :, :) = reshape(bmua,grd);
    imagesc(squeeze(muarec_img(itr, :, :)))
    colormap(cmap); colorbar; axis equal
    
    % update projection from current parameter estimate
    mproj = toastProject (invmesh, mua, mus, ref, freq, qvec, mvec);
    pproj = zeros(size(mproj));
    proj = [mproj];
    
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
end


disp('recon2: finished')

figure();
ss = 1;
list = [1];
for s=1:length(list)
    subplot(1,1,ss)
    im = squeeze(muarec_img(list(s), :, :));
    imagesc(im)
    save(['beta/beta_0.005_tau_5e-6_itr_' num2str(list(s)) '.mat'], 'im')
    title(num2str(list(s)))
    colorbar
    axis equal
    ss = ss + 1;
end
    
% figure(10);invmesh.Display(mua)
% figure(11);invmesh.Display(mus)

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

