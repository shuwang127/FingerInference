clear; clc;
close all;

%% Set the dataset information.
datapath = './LivDet 2017';
scanner = 'GreenBit';
matpath = ['Data/', scanner, '.mat'];

%% Load training data and testing data.
if ~exist(matpath, 'file')
    [ traindata, trainlabel, ~, ~ ] = readData( datapath, scanner, 'train' );
    [ testdata, testlabel, ~, ~ ] = readData( datapath, scanner, 'test' );
    save(matpath, 'traindata', 'trainlabel', 'testdata', 'testlabel');
else
    load(matpath);
end
disp('Data Loaded!');

%% Get LBP features.
addpath('./LBP/');
img = traindata{1};
lbp_map = lbp(img, 1, 8);
lbp_code = lbpMapping(lbp_map, 8, 'u2');
lbp_hist = lbpHist(lbp_code);
