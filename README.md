
# sparse-dot-deep-learning
Deep Learning Based Image Reconstruction for single-source Diffuse Optical Tomography system with Sparse Measurements

Files related to paper
"papername"
published on "Journal Name"
"paperimage"


This Repository consists of two main parts:

 - ### creating dataset
    In this part, we create a  dataset for training our neural network. Dataset is created with simulation of light propagation in tissue using the TOAST++ package to solve photon diffusion equation in 2D (DOT forward problem).  the creating-dataset folder consists of codes for creating mesh, solving forward problem, post-processing and evaluating results and several other parts some explained below

 - ###  training of neural network and evaluating results
	In this part, we train a Deep Neural Networks using the dataset created in part one and Evaluate Results. More Information on files is available below.

### Creating Dataset
Dataset consists of sample pairs (X, Y) where X is boundary measurements and Y is absorption coefficient image. Final Output of this part is two matrices for X and Y of all samples. One can request access to the dataset from authors or create one with codes in this part. 
