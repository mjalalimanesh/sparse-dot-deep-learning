
M = [12.7 5.02 -98 63.9 0 -.2 56];
tic
filename =  'data.txt' ;
dlmwrite(filename,M,'delimiter',',','-append');
N = M*2;
dlmwrite(filename,N,'delimiter',',','-append');
N = M*3;
dlmwrite(filename,N,'delimiter',',','-append');
N = M*4;
dlmwrite(filename,N,'delimiter',',','-append');

A = dlmread(filename);

toc

%import numpy as np
%input = np.loadtxt("input.txt", dtype='i', delimiter=',')
%print(input)