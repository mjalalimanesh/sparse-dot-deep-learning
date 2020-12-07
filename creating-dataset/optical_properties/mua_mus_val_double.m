


total_num = 20000;

lmua = [ 0.1 , 0.5 , 1.0, 3.0, 5.0 ] ;
mua_val = zeros( total_num , 3 ) ;
mua_val(:,3) = lmua(randi( 5 , [ total_num, 1 ] )) ; % inclusion 1
mua_val(:,2) = mua_val(:,1)   ; % inclusion 2 
mua_val(:,1) = 0.001 ; % intralipid


filename =  'mua_val_double.txt' ;
dlmwrite(filename,mua_val,'delimiter',',');


