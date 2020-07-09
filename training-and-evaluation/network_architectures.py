# -*- coding: utf-8 -*-
"""
Created on Mon Jun 17 2019
@author: Mohamad Jalalimanesh

These functions define structure of our Neural Networks
"""

import tensorflow as tf


def mlp(n_hidden_layers=1, n_neurons=None, activations=None):
	"""
	Create a sequentional model with Fully Connected Layers (Multilayer Perceptron)

	Inputs:
	 	n_hidden_layers : number of hidden Layers
						  input layer has 29 nodes and output node has 4096 nodes
					      equal to pixels of output image
		n_neurons :	 list containing number of neurons for each hidden layers
		 				  default is 128 for all layers
		activations : list containing activation function for each hidden layer
						  output layer has relu activition and first layer
						  usually has tanh

	Outputs :
		model : noncompiled Sequentional model
	"""
	if activations == None:
		activations = ['tanh']
		activations.extend(['relu' for i in range(n_hidden_layers-1)])

	if n_neurons == None:
		n_neurons = [128 for i in range(n_hidden_layers)]

	model = tf.keras.Sequential()
	model.add(tf.keras.layers.Dense(n_neurons[0], activation=activations[0], input_shape=(29,)))
	for i in range(1, n_hidden_layers):
		model.add(tf.keras.layers.Dense(n_neurons[i], activation=activations[i]))
#		model.add(tf.keras.layers.BatchNormalization(axis=1))
#	model.add(tf.keras.layers.Dropout(0.1, noise_shape=None, seed=None))
	model.add(tf.keras.layers.Dense(4096, activation='relu'))

	return model


def conv2d_FC():
	"""
	Create a sequentional model with conv2d layers followed by fully connected
	layers with predefined parameters
	This Architecture is similar to famous machine vision models
	"""

	model = tf.keras.models.Sequential([
	      	tf.keras.layers.Reshape((16,16,1), input_shape=(256,)),
      		tf.keras.layers.Conv2D(128, (2,2), strides=(1,1), activation='relu', padding='same'),
      		tf.keras.layers.Conv2D(128, (2,2), strides=(1,1), activation='relu'),
      		tf.keras.layers.Conv2D(128, (2,2), strides=(1,1), activation='relu'),
      		tf.keras.layers.Conv2D(128, (2,2), strides=(1,1), activation='relu'),
      		tf.keras.layers.Conv2D(128, (2,2), strides=(1,1), activation='relu'),
      		tf.keras.layers.Conv2D(128, (2,2), strides=(1,1), activation='relu'),
      		tf.keras.layers.Conv2D(128, (2,2), strides=(1,1), activation='relu'),
      		tf.keras.layers.Conv2D(128, (2,2), strides=(1,1), activation='relu'),
      		tf.keras.layers.Conv2D(128, (2,2), strides=(1,1), activation='relu'),
      		tf.keras.layers.Conv2D(128, (2,2), strides=(1,1), activation='relu'),

			tf.keras.layers.Flatten(),
    		tf.keras.layers.Dense(1000, activation='tanh'),
			tf.keras.layers.Dense(3096, activation='relu')])
	return model

def conv1d_FC():
	"""
	Create a sequentional model with conv1d layers followed by fully connected
	layers with predefined parameters
	"""
	model = tf.keras.models.Sequential([
	      	tf.keras.layers.Reshape((29,1), input_shape=(29,)),
      		tf.keras.layers.Conv1D(32, 2, strides=1, activation='relu'),
      		tf.keras.layers.Conv1D(32, 2, strides=1, activation='relu'),
      		tf.keras.layers.Conv1D(64, 2, strides=1, activation='relu'),
      		tf.keras.layers.Conv1D(64, 3, strides=1, activation='relu'),
      		tf.keras.layers.Conv1D(128, 2, strides=1, activation='relu'),
			tf.keras.layers.MaxPooling1D(pool_size=2),
      		tf.keras.layers.Conv1D(128, 2, strides=1, activation='relu'),
			tf.keras.layers.MaxPooling1D(pool_size=2),
      		tf.keras.layers.Conv1D(256, 2, strides=1, activation='relu'),
			tf.keras.layers.MaxPooling1D(pool_size=2),

			tf.keras.layers.Flatten(),
    		tf.keras.layers.Dense(800, activation='relu'),
			tf.keras.layers.Dense(4096, activation='relu')])
	return model


def FC_conv2d():
	"""
	Create a sequentional model with fully connected layers followed by
	convolutional layers with predefined parameters
	This Architecture is similar to article "Image reconstruction by
	domain-transform manifold learning"
	"""
	model = tf.keras.models.Sequential([
    		tf.keras.layers.Dense(600, activation='tanh', input_shape=(29,)),
    		tf.keras.layers.Dense(4096, activation='relu'),
	      	tf.keras.layers.Reshape((64,64,1)),
      		tf.keras.layers.Conv2D(32, (2,2), strides=(1,1), activation='relu', padding='same'),
#			tf.keras.layers.BatchNormalization(axis=-1),
      		tf.keras.layers.Conv2D(32, (2,2), strides=(1,1), activation='relu', padding='same'),
#			tf.keras.layers.BatchNormalization(axis=-1),
      		tf.keras.layers.Conv2D(32, (2,2), strides=(1,1), activation='relu', padding='same'),
#			tf.keras.layers.BatchNormalization(axis=-1),
      		tf.keras.layers.Conv2D(32, (2,2), strides=(1,1), activation='relu', padding='same'),
#			tf.keras.layers.BatchNormalization(axis=-1),

      		tf.keras.layers.Conv2D(1, (2,2), strides=(1,1), activation='relu', padding='same'),

	      	tf.keras.layers.Reshape((4096,))])
	return model

def resnet(modelA):
	"""
	Residual Network
	modelB which is a redual networks in concatenated to the end of modelA
	commented part makes modelA weights untrainable
	"""
	from ResNet_2 import resnet_v1
	modelB = resnet_v1((4096,),10)

	inputA = modelA.input
	outputA = modelA.output
	outputB = modelB(outputA)

	model = tf.keras.models.Model(inputA, outputB)

#	model.layers[0].trainable = False
#	model.layers[1].trainable = False
#	model.layers[2].trainable = False
#	model.layers[3].trainable = False
#	for l in model.layers:
#	    print(l.name, l.trainable)

	return model


def custom_objective(y_true, y_pred):
	"""
	costum objective function
	balanced sum of mse and mae
	"""
	mse_loss= tf.keras.backend.mean(tf.keras.backend.square(y_pred - y_true), axis=-1)
	mae_loss = tf.keras.backend.mean(tf.keras.backend.abs(y_pred - y_true), axis=-1)
	loss = mse_loss + mae_loss*(mse_loss/mae_loss)
	return loss
