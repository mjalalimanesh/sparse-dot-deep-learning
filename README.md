

# sparse-dot-deep-learning
## Deep Learning Based Image Reconstruction for Single-Source Diffuse Optical Tomography system with Sparse Measurements 
#### Authors : M. H. Jalalimanesh, M. A. Ansari

#### Laser and Plasma Research Institute, Shahid Beheshti University, Iran
---

Files related to paper
Deep Learning Based Image Reconstruction for single-source Diffuse Optical Tomography system with sparse measurements
published on "Journal Name"
"paperimage"


This Repository consists of two main parts:

 - ### [Creating Dataset](https://github.com/mjalalimanesh/sparse-dot-deep-learning/tree/master/creating-dataset)
    In this part, we create a  dataset for training our neural network. Dataset is created with simulation of light propagation in tissue using the TOAST++ package to solve photon diffusion equation in 2D (DOT forward problem).  the creating-dataset folder consists of scripts for creating mesh, solving forward problem, post-processing and evaluating results and several other parts some explained below

 - ###  [Training of Neural Network and Evaluating Results](https://github.com/mjalalimanesh/sparse-dot-deep-learning/tree/master/training-and-evaluation)
	In this part, we train a Deep Neural Networks using the dataset created in part one and Evaluate Results. More Information on files is available below.

### Creating Dataset
Dataset consists of sample pairs (X, Y) where X is boundary measurements and Y is absorption coefficient image. Final Output of this part is two matrices for X and Y of all examples. One can request access to the dataset from authors or create one with scripts in this part. 

First we create all mesh files then we solve forward problem for each mesh to obtain boundary measurements and put them together in a matrix. All files and codes for creating meshes are stores in meshing folder. Fisrt We create gmsh .geo (Geometry) files and then we create meshes with these .geo files. Geometry files are created based on template geo files circle_single.geo and circle_double.geo which are geometries of circular phantoms with single or double inclusions. 

Forward problem is  then solved in forwad_create_dataset.m where we read mesh files, obtain boundary measurements and save two matrices X (boundary measurements) which is input of neural network and Y (absorption coefficient image) which is output of our network.

### Training and Evaluation
#### Training Network
Training is done in training notebook [![Open In Colab](https://camo.githubusercontent.com/52feade06f2fecbf006889a904d221e6a730c194/68747470733a2f2f636f6c61622e72657365617263682e676f6f676c652e636f6d2f6173736574732f636f6c61622d62616467652e737667)](https://colab.research.google.com/github/mjalalimanesh/sparse-dot-deep-learning/blob/master/training.ipynb)
Functions for reading and preprocessing data are stored in [read_preprocess_data.py](https://github.com/mjalalimanesh/sparse-dot-deep-learning/blob/master/training-and-evaluation/read_preprocess_data.py "read_preprocess_data.py") and various network architectures we tested are stored in [network_architectures.py](https://github.com/mjalalimanesh/sparse-dot-deep-learning/blob/master/training-and-evaluation/network_architectures.py "network_architectures.py") 

#### Evaluation
Analysis of model built in prevoius section and it's outputs is done in analysis.ipynb. Evaluation metrics used to compare reconstruction performance of DL and Classic method are stored in [evaluation_metrics.py](https://github.com/mjalalimanesh/sparse-dot-deep-learning/blob/master/training-and-evaluation/evaluation_metrics.py "evaluation_metrics.py").
##### Classic Reconstruction
Files for classical method image reconstruction including Gauss-Newton reconstruction and Conjugate gradient reconstruction and Grid search to select best parameters for these methods.


