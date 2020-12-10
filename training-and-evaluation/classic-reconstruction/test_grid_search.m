tau = [5e-5, 1e-1, 5e-2, 1e-2, 5e-3, 1e-3, 5e-4, ...
       1e-4, 5e-5, 1e-5, 5e-6, 1e-6, 5e-7, 1e-7] ;
beta = [0.02, 0.01, 0.02, 0.05, 0.08, 0.1 , 0.2, 0.5];
smode = 'exp'; % exp, sim, esp
numbers = [1, 2, 3, 4, 5, 6, 7];
% numbers = [1, 2, 3, 4, 7];
itrmax_cg = [2, 5, 10, 20];
itrmax_gn = [1, 3, 6];

score_cg = zeros(length(tau), length(beta), 7);
score_gn = zeros(length(tau), length(beta), 7);

for k=1:length(numbers)
    
num = numbers(k);
    
for i=1:length(tau)
    for j=1:length(beta)
        for m=1:length(itrmax_cg)
            tmp_score(m) = recon_toast_cg(tau(i), beta(j), smode, num, itrmax_cg(m)); %#ok<*SAGROW>
        end
        score_cg(i, j, num) = min(tmp_score);
    end
end

save(['output\' 'score_cg_' smode '_' num2str(num) '.mat'], 'score_cg')


for i=1:length(tau)
    for j=1:length(beta)
        for m=1:length(itrmax_gn)
            tmp_score(m) = recon_toast_gn(tau(i), beta(j), smode, num, itrmax_gn(m));
        end
        score_gn(i, j, num) = min(tmp_score);
    end
end

save(['output\' 'score_gn_' smode '_' num2str(num) '.mat'], 'score_gn')

end

