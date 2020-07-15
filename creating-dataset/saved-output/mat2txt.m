
load('network_outputs.mat', 'bbmua_save', 'Y_save');





filename =  'bbmua.txt' ;
dlmwrite(filename,bbmua_save,'delimiter',',');

filename =  'Y.txt' ;
dlmwrite(filename,Y_save,'delimiter',',');





