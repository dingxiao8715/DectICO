# DectICO
An alignment-free supervised metagenomic classification method based on feature extraction and dynamic selection

============
Introduction
============

DectICO is an alignment-free supervised metagenomic sample classification algorithm. It selects the ICO dynamically and classifies the metagenomic samples based on the refined ICO vectors with SVM.

====================
Software Requirement
====================

We require a Windows or linux system with the Matlab and Perl software. Matlab (R2013a 64-bit) and Perl (v5.16.3 64-bit) were used in our experiments.

=====
Usage
=====

DectICO contains mainly three steps:

Step1: Extract feature matrix of metagenomic sequencing raw data with the entire sequence feature.
In this step, we provide a perl script to calculate the feature vectors for the metagenomic sequencing raw data. Open the cmd in windows and import:

>perl integrate_sample_feature.pl  (fasta.list)  (k-mer)  (feature type) >  (output)

Input Arguments:
(fasta.list): The list of names of the metagenomic sequencing files.

(k-mer): The length of oligonucleotide that used for extracting sequence feature vectors.

(feature type): The type of sequence feature for characterizing the metagenomes. (1 for the sequence composition and 2 for the ICO)

Output file:
The output file is a feature matrix whose rows represent the feature vector of metagenomic samples. Its name is defined by users.


Step2: Select features dynamically and train classifiers with the refined feature matrix.
In this step, users can use “DectICO” function in Matlab to perform both feature selection and training. Open the Matlab console and import:

>DectICO

Requirement:
<feature selected ladder file>: A text file named “selection.txt” with the selected feature sizes decreasing from up to bottom. 


Input Arguments:
<the filename of the training feature maxtrix>: The filename of the training feature matrix extracted in step1.
<the number of positive samples>: The number of positive samples in training set.
<the number of negative samples>: The number of negative samples in training set.

Output file:
The output in this step is a folder named “results” which contains the selected feature set, the LOOCV (leave-one-out cross validation) accuracy and the trained classifier’s model file for each round.

Step3: Select the best performed classifier and classify the testing samples.
This step also divides into two processes. First, users need to select the best performed classifier based on the LOOCV accuracies manually. Then we provide a perl script to obtain the refined feature matrix of testing metagenomic samples with the selected feature set file. Open the cmd in windows and import:

>perl output_selected_feature_matrix.pl  <feature matrix>  <features selected>  <output>

Input Arguments:
<feature matrix>: The feature matrix of metagenomes with the entire features
<features selected>: The feature set that has the best performance.
<output>: The name of refined feature matrix with the selected features which is defined by users.
Output file:
The output file is a feature matrix with the selected features.

Second, users can classify the testing samples with the refined feature matrix and the best performed classifier’s model file. 


>perl format_transform_SVM_singlefile_title.pl <testing file>  <parameter>  >  <output>

Input Arguments:
<testing file>:The feature matrix file that need to transfer format.
<parameter>: Import 1 or -1 optionally (this argument will be acting for the training set).
Output file:
The output file is the feature matrix file with the appropriate format for Libsvm.

Then users can classify the testing samples by Libsvm. Open the cmd in windows and import:

> svm-predict.exe  <transformed file>  <model file>  <output>

Input Arguments:
<transformed file>:The transformed feature matrix file.
<model file>: The model file of the best performed classifier.
Output file:
The output file is the result of classification.


========
Statement
========
The DectICO source builds on the following software:

kernelPLS: https://github.com/sqsun/kernelPLS
Libsvm (3.17): http://www.csie.ntu.edu.tw/~cjlin/libsvm/index.html



