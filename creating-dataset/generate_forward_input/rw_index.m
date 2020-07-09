

ind1 = 1 ;
ind2 = ind1 + 100;
fileID = fopen('index.txt','w');
fprintf(fileID,'%d %d',ind1, ind2);
fclose(fileID);


fileID = fopen('index.txt','r');
index = fscanf(fileID,'%d %d') ;
fclose(fileID);
