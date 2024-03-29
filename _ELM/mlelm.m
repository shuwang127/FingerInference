function [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy, stack, HN, sigscale] = ...
    mlelm(TrainingAllData, TestingAllData, Testcode, TrainDataSize, ...
    TotalLayers, HiddernNeurons, C1, rhoValue, sigpara, sigpara1)

% Usage: elm(TrainingData_File, TestingData_File, Elm_Type, NumberofHiddenNeurons, ActivationFunction)
% OR:    [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy] = elm(TrainingData_File, TestingData_File, Elm_Type, NumberofHiddenNeurons, ActivationFunction)
% 
% Input:
% Testcode              - Filename of training data set
% TrainDataSize         - Filename of testing data set
% TotalLayers           - 0 for regression; 1 for (both binary and multi-classes) classification
% HiddernNeurons        - Number of hidden neurons assigned to the ELM
% C1                    - Type of activation function:
%                           'sig' for Sigmoidal function
%                           'sin' for Sine function
%                           'hardlim' for Hardlim function
%                           'tribas' for Triangular basis function
%                           'radbas' for Radial basis function (for additive type of SLFNs instead of RBF type of SLFNs)
%
% Output:
% TrainingTime          - Time (seconds) spent on training ELM
% TestingTime           - Time (seconds) spent on predicting ALL testing data
% TrainingAccuracy      - Training accuracy:
%                           RMSE for regression or correct classification rate for classification
% TestingAccuracy       - Testing accuracy:
%                           RMSE for regression or correct classification rate for classification
%
% MULTI-CLASSE CLASSIFICATION: NUMBER OF OUTPUT NEURONS WILL BE AUTOMATICALLY SET EQUAL TO NUMBER OF CLASSES
% FOR EXAMPLE, if there are 7 classes in all, there will have 7 output
% neurons; neuron 5 has the highest output means input belongs to 5-th class
%
% MNIST dataset from http://yann.lecun.com/exdb/mnist/
%
% [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy] = mlelm(*, *, 0, 0, 3, [700,15000], [1e-1,1e4,1e8],0.05, [0.7,1], [0.8,0.9])
% Or
% [TrainingTime, TestingTime, TrainingAccuracy, TestingAccuracy] = mlelm(*, *, 0, 0, 3, [700,15000], [1e-1,1e3,1e8],0.05, [0.7,6], [0.8,4])
%


%% Load training dataset
T = TrainingAllData(:,1)';
P = TrainingAllData(:,2:size(TrainingAllData,2))';
clear TrainingAllData; % Release raw training data array

%% Load testing dataset
TV.T = TestingAllData(:,1)';
TV.P = TestingAllData(:,2:size(TestingAllData,2))';
clear TestingAllData; % Release raw testing data array                        

%% Select the training data
if TrainDataSize ~= 0
    rand_sequence = randperm(TrainDataSize);
    temp_P = P';
    temp_T = T';
    clear P;
    clear T;
    P = temp_P(rand_sequence, :)';
    T = temp_T(rand_sequence, :)';
    clear temp_P;
    clear temp_T;
end

%% Calculate the parameters
NumberofTrainingData = size(P,2);
NumberofTestingData  = size(TV.T,2);
NumberofInputNeurons = size(P,1);

%% Preprocessing the data of classification
sorted_target = sort( cat( 2, T, TV.T ), 2 );
label = zeros(1,1); % Find and save in 'label' class label from training and testing data sets
label(1,1) = sorted_target(1,1);
j = 1;
for i = 2:(NumberofTrainingData+NumberofTestingData)
    if sorted_target(1,i) ~= label(1,j)
        j = j + 1;
        label(1,j) = sorted_target(1,i);
    end
end
number_class = j;
NumberofOutputNeurons = number_class;

%% Processing the targets of training
temp_T = zeros(NumberofOutputNeurons, NumberofTrainingData);
for i = 1:NumberofTrainingData
    for j = 1:number_class
        if label(1,j) == T(1,i)
            break;
        end
    end
    temp_T(j,i) = 1;
end
T = temp_T * 2 - 1;

%% Processing the targets of testing
temp_TV_T = zeros(NumberofOutputNeurons, NumberofTestingData);
for i = 1:NumberofTestingData
    for j = 1:number_class
        if label(1,j) == TV.T(1,i)
            break;
        end
    end
    temp_TV_T(j,i) = 1;
end
TV.T = temp_TV_T * 2 - 1;

%% Calculate weights & biases
train_time = tic;
no_Layers = TotalLayers;
stack = cell(no_Layers+1,1);

lenHN = length(HiddernNeurons);
lenC1 = length(C1);
lensig = length(sigpara);
lensig1 = length(sigpara1);

HN_temp = [NumberofInputNeurons, HiddernNeurons(1:lenHN-1)];
if length(HN_temp) < no_Layers
    HN = [ HN_temp, repmat( HN_temp( length( HN_temp ) ),1,no_Layers-length(HN_temp) ), HiddernNeurons(lenHN) ];
    C = [C1(1:lenC1-2), zeros(1,no_Layers - length(HN_temp)  ), C1(lenC1-1:lenC1) ];
    sigscale = [sigpara(1:lensig-1),ones(1,no_Layers - length(HN_temp)),sigpara(lensig)];
    sigscale1 = [sigpara1(1:lensig1-1),ones(1,no_Layers - length(HN_temp)),sigpara1(lensig1)];
else
    HN = [NumberofInputNeurons,HiddernNeurons];
    C = C1;
    sigscale = sigpara;
    sigscale1 = sigpara1;
end
clear HN_temp;

%% Calculate the weights
InputDataLayer = zscore(P);
clear P;

if Testcode == 1
    rng('default');
end

for i = 1:1:no_Layers
    % generate the input weight
    InputWeight = rand(HN(i+1),HN(i)) * 2 - 1;
    if HN(i+1) > HN(i)
        InputWeight = orth(InputWeight);
    else
        InputWeight = orth(InputWeight')';
    end
    % generate the bias weight
    BiasofHiddenNeurons = rand(HN(i+1),1) * 2 - 1;
    BiasofHiddenNeurons = orth(BiasofHiddenNeurons);
    % generate the temp hidden output matrix
    tempH = InputWeight * InputDataLayer; 
    clear InputWeight; 
    ind = ones(1,NumberofTrainingData);
    BiasMatrix = BiasofHiddenNeurons(:, ind);
    tempH = tempH + BiasMatrix;
    clear BiasMatrix;
    clear BiasofHiddenNeurons;
    fprintf(1, 'AutoEncorder Max Val %f Min Val %f\n', max(tempH(:)), min(tempH(:)));
    % generate the hidden output matrix
    H = 1 ./ ( 1 + exp( -sigscale1(i) * tempH ) );
    clear tempH;
    
    % Calculate output weights OutputWeight (beta_i)
    if HN(i+1) == HN(i)
        [~,stack{i}.w,~] = procrustNew( InputDataLayer', H' );
    else
        if C(i) == 0
            stack{i}.w = pinv(H') * InputDataLayer';                        % implementation without regularization factor //refer to 2006 Neurocomputing paper
        else
            rhohats = mean(H,2);
            rho = rhoValue;
            KLsum = sum(rho * log(rho ./ rhohats) + (1-rho) * log((1-rho) ./ (1-rhohats)));
            
            Hsquare =  H * H';
            HsquareL = diag(max(Hsquare,[],2));
            stack{i}.w = ( ( eye(size(H,1)).*KLsum +HsquareL ) * (1/C(i)) + Hsquare ) \ (H * InputDataLayer');
            
            clear Hsquare;
            clear HsquareL;
        end
    end
    
    tempH = (stack{i}.w) * (InputDataLayer);
    clear InputDataLayer;
    
    if HN(i+1) == HN(i)
        InputDataLayer = tempH;
    else
        fprintf(1, 'Layered Max Val %f Min Val %f\n', max(tempH(:)), min(tempH(:)) );
        InputDataLayer =  1 ./ ( 1 + exp(-sigscale(i) * tempH ) );
    end
    
    clear tempH;
    clear H;
end

%% Calculate the last layer parameter (ELM)
if C(no_Layers+1) == 0
    stack{no_Layers+1}.w = pinv(InputDataLayer') * T';
else
    stack{no_Layers+1}.w = ( eye(size(InputDataLayer,1)) / C(no_Layers+1) + InputDataLayer * InputDataLayer' ) \ ( InputDataLayer * T' );
end

%% Calculate CPU time (seconds) spent for training ELM
TrainingTime = toc(train_time);        
% display_network(orth(stack{1}.w'));
% Y: the actual output of the training data
Y = (InputDataLayer' * stack{no_Layers+1}.w)';                             
clear InputDataLayer;
clear H;

%% Calculate the output of testing input
test_time = tic;
InputDataLayer = zscore(TV.P);
clear TV.P;

for i = 1:1:no_Layers
    tempH_test = (stack{i}.w) * (InputDataLayer);
    clear TV.P;           
    
    if HN(i+1) == HN(i)
        InputDataLayer = tempH_test;
    else
        InputDataLayer =  1 ./ ( 1 + exp( -sigscale(i) * tempH_test ) );
    end
    clear tempH_test;
end
% TY: the actual output of the testing data
TY = (InputDataLayer' * stack{no_Layers+1}.w)';                       
% Calculate CPU time (seconds) spent by ELM predicting the whole testing data
TestingTime = toc(test_time);           

%% Calculate training & testing classification accuracy
MissClassificationRate_Training = 0;
MissClassificationRate_Testing = 0;
for i = 1 : size(T, 2)
    [~, label_index_expected] = max(T(:,i));
    [x, label_index_actual] = max(Y(:,i));
    if label_index_actual ~= label_index_expected
        MissClassificationRate_Training = MissClassificationRate_Training + 1;
    end
end
TrainingAccuracy = 1 - MissClassificationRate_Training / size(T,2);
for i = 1 : size(TV.T, 2)
    [x, label_index_expected] = max(TV.T(:,i));
    [x, label_index_actual] = max(TY(:,i));
    if label_index_actual ~= label_index_expected
        MissClassificationRate_Testing = MissClassificationRate_Testing + 1;
    end
end
TestingAccuracy = 1 - MissClassificationRate_Testing / size(TV.T,2);

end

