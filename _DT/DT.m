function [ tree, trainacc, testacc, predicts ] = DT( traindata, trainlabel, testdata, testlabel )
% Implementation of CART Decision Tree.

%% CART Decision Tree
tree = fitctree(traindata, trainlabel);

trainpred = predict(tree, traindata);
trainacc = sum(trainpred == trainlabel) / length(trainlabel);

predicts = predict(tree, testdata);
testacc = sum(predicts == testlabel) / length(testlabel);

end

