function [ predicts, accuracy ] = elmforward( data, label, W, b, o, Activ)
%ELMFORWARD Summary of this function goes here
%   Detailed explanation goes here

tempH_test = W * data';           
ind = ones(1, length(label));
BiasMatrix = b(:, ind);              %   Extend the bias matrix BiasofHiddenNeurons to match the demention of H
tempH_test = tempH_test + BiasMatrix;
switch lower(Activ)
    case {'sig','sigmoid'}
        %%%%%%%% Sigmoid 
        H_test = 1 ./ (1 + exp(-tempH_test));
    case {'sin','sine'}
        %%%%%%%% Sine
        H_test = sin(tempH_test);        
    case {'hardlim'}
        %%%%%%%% Hard Limit
        H_test = hardlim(tempH_test);        
    case {'tribas'}
        %%%%%%%% Triangular basis function
        H_test = tribas(tempH_test);        
    case {'radbas'}
        %%%%%%%% Radial basis function
        H_test = radbas(tempH_test);        
        %%%%%%%% More activation functions can be added here        
end
TY = (H_test' * o)';    

predicts = [];
misscls = 0;
for i = 1 : length(label)
    [~, index] = max(TY(:, i));
    index = index - 1;
    predicts = [predicts; index];
    if index ~= label(i)
        misscls = misscls + 1;
    end
end
accuracy = 1 - misscls / length(label);

end

