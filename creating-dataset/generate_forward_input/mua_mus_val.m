


total_num = 30000;

lmua = [ 0.100 , 0.100 , 0.100, 0.100, 0.100 ] ;
mua_val = zeros( total_num , 3 ) ;
mua_val(:,1) = lmua(randi( 5 , [ total_num, 1 ] )) ; %inclusion
mua_val(:,2) = 0.01   ; % intralipid 
mua_val(:,3) = mua_val(:,2) ; % glass


filename =  'mua_val.txt' ;
dlmwrite(filename,mua_val,'delimiter',',');


