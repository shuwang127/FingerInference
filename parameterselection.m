%% Emsemble features.
% LPQ  256 77.3465 30
% BSIF 256 77.7768 40
% DWT  13  79.1697 22

clear; close all;
load('/home/shu/Desktop/Tenko/Data/CrossmatchR2.mat')
load('/home/shu/Desktop/Tenko/Data/CrossmatchR2_BSIF_11_8.mat')
load('/home/shu/Desktop/Tenko/Data/CrossmatchR2_DWT_5.mat')
load('/home/shu/Desktop/Tenko/Data/CrossmatchR2_LBP_1_8_riu2.mat')
load('/home/shu/Desktop/Tenko/Data/CrossmatchR2_LPQ_5.mat')

feat = [data_dwt];

%%
train_stat = zeros(1, 100); 
test_stat = zeros(1, 100); 
iternum = 1000;
for k = 1 : 100
    for i = 1 : iternum
        % Shuffle data and get index.
        trainrate = 0.8;
        trainnum = ceil(trainrate * numel(label));
        idx = randperm(numel(label));
        trainidx = idx(1:trainnum);
        testidx = idx(trainnum+1:end);

        % get label
        trainlabel = label(trainidx, :);
        testlabel = label(testidx, :);
        % get data
        trainfeat = feat(trainidx, :);
        testfeat = feat(testidx, :);
        
        % Training
        [~, ~, TrainAcc, TestAcc, W, b, o] ...
            = elm([trainlabel, trainfeat], [testlabel, testfeat], 1, k, 'sig');
        train_stat(k) = train_stat(k) + TrainAcc;
        test_stat(k) = test_stat(k) + TestAcc;
    end
end

%%
train_stat = train_stat * 100 / iternum;
test_stat = test_stat * 100 / iternum;
plot(1:100, train_stat, 1:100, test_stat);
xlabel('Number of Neurons in Hidden Layer');
ylabel('Accuracy (%)');
legend('Train', 'Test');
hold on; plot([1,100], [80,80], 'r--');
[accmax, kmax] = max(test_stat);
hold on; plot([kmax,kmax], [50, accmax], 'r--');
text(50, 70, [num2str(accmax), '%']);
text(50, 68, ['kmax=', num2str(kmax)]);
disp(['The optimal number of hidden neurons is ', num2str(kmax)]);
disp(['The best testing performance is ', num2str(accmax), '%.']);