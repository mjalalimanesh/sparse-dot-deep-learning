tau = 0.05 ;
beta = 0.05;
mode = 'exp';
num = 7;
itrmax = 5;

tic
tmp_score = recon_toast_cg(tau, beta, mode, num, itrmax); %#ok<*SAGROW>
toc
%tmp_score = recon_toast_gn(tau(i), beta(j), mode, num, itrmax_gn(m));
