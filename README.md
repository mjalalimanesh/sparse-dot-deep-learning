
# sparse-dot-deep-learning
## Deep Learning Based Image Reconstruction for Single-Source Diffuse Optical Tomography system with Sparse Measurements 
#### Authors : M. H. Jalalimanesh, M. A. Ansari

#### Laser and Plasma Research Institute, Shahid Beheshti University, Iran
---

Files related to paper
Low-Cost Sparse-View Diffuse Optical Tomography using Deep-Learning Image Reconstruction
published on "Journal Name"
"paperimage"


This Repository consists of two main parts:

 - ### Creating Dataset
    In this part, we create a  dataset for training our neural network. Dataset is created with simulation of light propagation in tissue using the TOAST++ package to solve photon diffusion equation in 2D (DOT forward problem).  the creating-dataset folder consists of codes for creating mesh, solving forward problem, post-processing and evaluating results and several other parts some explained below

 - ###  Training of Neural Network and Evaluating Results
	In this part, we train a Deep Neural Networks using the dataset created in part one and Evaluate Results. More Information on files is available below.

### Creating Dataset
Dataset consists of sample pairs (X, Y) where X is boundary measurements and Y is absorption coefficient image. Final Output of this part is two matrices for X and Y of all samples. One can request access to the dataset from authors or create one with codes in this part. 

First we create all mesh files then we solve forward problem for each mesh to obtain boundary measurements and put them together in a matrix. All files and codes for creating meshes are stores in meshing folder. Fisrt We create gmsh .geo (Geometry) files and then we create meshes with these .geo files. Geometry files are created based on template geo files circle_single.geo and circle_double.geo which are geometries of circular phantoms with single or double inclusions. 

### Training and Evaluation
## ... 

## ... 


