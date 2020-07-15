function [Q,M] = make_QM( nq , phantom_radius )

Q(1,:) = phantom_radius * [cos(0) sin(0)];

for k=1:nq
    phi_m = (40 + 10*(k-1))*((2*pi)/360) ;
    M(k,:) = phantom_radius * [cos(phi_m) sin(phi_m)];
end

end