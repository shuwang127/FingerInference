clear; close all;
sensor = 'GreenBit';

load(['/home/shu/Desktop/Tenko/Data/',sensor,'.mat'])
load(['/home/shu/Desktop/Tenko/Data/',sensor,'_BSIF_11_8.mat'])
load(['/home/shu/Desktop/Tenko/Data/',sensor,'_DWT_5.mat'])
load(['/home/shu/Desktop/Tenko/Data/',sensor,'_LBP_1_8_riu2.mat'])
load(['/home/shu/Desktop/Tenko/Data/',sensor,'_LPQ_5.mat'])

load('./Model/wModel.mat')

%% Estimation
if ~exist('label', 'var')
    data_lpq = [train_lpq; test_lpq];
    data_bsif = [train_bsif; test_bsif];
    data_dwt = [train_dwt; test_dwt];
    label = [trainlabel; testlabel];
end
num = length(label);
[ p_lpq, ~ ] = elmforward( data_lpq, label, m1.W, m1.b, m1.o, 'sig');
[ p_bsif, ~ ] = elmforward( data_bsif, label, m2.W, m2.b, m2.o, 'sig');
[ p_dwt, ~ ] = elmforward( data_dwt, label, m3.W, m3.b, m3.o, 'sig');
p = p_lpq + p_bsif + p_dwt;
p = double(p >= 2);
acc = sum(p == label) / length(label);
disp(['The accuracy is ', num2str(acc*100), '%']);