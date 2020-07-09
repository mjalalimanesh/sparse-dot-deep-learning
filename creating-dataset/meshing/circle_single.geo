nden = 0.5;
r1 = 16.1;
r2 = 16.1;

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



Dilate {{x,y,z}, radius} {
  Duplicata { Line{1, 2, 3, 4}; }
}

//+
Curve Loop(6) = {8, 9, 6, 7};
//+
Plane Surface(1) = {6};
//+
Plane Surface(2) = {5, 6};
