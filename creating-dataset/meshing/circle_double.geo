nden = 0.4;
r1 = 16.1;
r2 = 17.65;

Point(1) = {0, 0, 0, nden};
Point(2) = {r1, 0, 0, nden};
Point(3) = {-r1, 0, 0, nden};
Point(4) = {0, r1, 0, nden};
Point(5) = {0, -r1, 0, nden};


Circle(1) = {3, 1, 5};
Circle(2) = {5, 1, 2};
Circle(3) = {2, 1, 4};
Circle(4) = {4, 1, 3};
Line Loop(5) = {1, 2, 3, 4};


Dilate {{x1,y1,z1}, radius1} {
  Duplicata { Line{1, 2, 3, 4}; }
}


Dilate {{x2,y2,z2}, radius2} {
  Duplicata { Line{1, 2, 3, 4}; }
}


//+
Curve Loop(6) = {13, 10, 11, 12};
//+
Curve Loop(7) = {9, 6, 7, 8};
//+
Surface(1) = {5, 6, 7};
//+
Surface(2) = {6};
//+
Surface(3) = {7};
