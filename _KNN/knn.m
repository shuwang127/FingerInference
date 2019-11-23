function [predicts, accuracy] = knn(traindata, trainlabel, testdata, testlabel)
% Implemented basic k-NN classification.
%  Shu Wang
%

num_test = length(testlabel);
num_train = length(trainlabel);

%% k-NN
predicts = zeros(num_test, 1);
for i = 1 : num_test
    dist = sum(((traindata - repmat(testdata(i, :), num_train, 1)) .^ 2), 2);
    [~, ind] = min(dist);
    predicts(i) = trainlabel(ind);
end

%% Estimate
accuracy = sum(predicts == testlabel) / num_test;

