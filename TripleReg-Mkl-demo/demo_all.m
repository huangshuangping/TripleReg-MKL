%******************************
% Demo TripleReg-MKL 20150405
%******************************
close all;
clear all;
clc;
%% config global variables
config_file = 'config_file_all';
eval(config_file);
%% create the mat file we need to use later
% PreMat(config_file);
%% Creat similarity matrix TrainSim & TestSim
%  CalSim(config_file);
%%  Online process of TripleReg-MKL
Online_FaiDomain_hinge_two(config_file); 