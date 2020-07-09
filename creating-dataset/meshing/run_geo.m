tic
single_num = 1 ;
double_num = 15000 ;
total_num = single_num + double_num ;

index = 1 ; 

% to save seccessful statuses of os command
status = zeros( total_num , 1 ) ;

[ index , status ] = create_geo_single(total_num, single_num, index, status) ;
%[ index , status ] = create_geo_double(total_num, double_num, index , status) ;
% 10:4.3
toc


