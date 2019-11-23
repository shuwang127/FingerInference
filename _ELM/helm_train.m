function [TrainingAccuracy, TestingAccuracy, Training_time, Testing_time, ...
    beta1, beta2, beta, l3, ps1, ps2, T1, T2, T3] = ...
    helm_train( train_x, train_y, test_x, test_y, b1, b2, b3, s, C )

%  Input:
%    train_x: N * inputDim
%    train_y: N * outputDim
%    test_x : n * inputDim
%    test_y : n * outputDim  like [1 -1 -1 -1; -1 1 -1 -1]
%    b1     : (inputDim+1) * hidden1Dim
%    b2     : (hidden1Dim+1) * hidden2Dim
%    b3     : (hidden2Dim+1) * hidden3Dim
%    s      : activi-parameter
%    C      : regular parameter
%  Output:
%    TrainingAccuracy, TestingAccuracy, Training_time, Testing_time
%
%  Wang Shu @ GMU CSIC 2018
%

% train_x = TrainingData;
% train_y = TrainingLabel;
% test_x = TestingData;
% test_y = TestingLabel;

%% Prepare the data
tic;
train_x = zscore(train_x')';
H1 = [train_x .1 * ones(size(train_x,1),1)];
clear train_x;

%% First layer RELM
A1 = H1 * b1;
A1 = mapminmax(A1);
clear b1;
beta1 = sparse_elm_autoencoder(A1, H1, 1e-3, 50)'; %size(beta1) = (inputDim+1) * hidden1Dim
clear A1;
T1 = H1 * beta1;
fprintf(1, 'Layer 1: Max Val of Output %f Min Val %f\n', max(T1(:)), min(T1(:)) );
[T1, ps1] = mapminmax(T1', 0, 1);
T1 = T1';
clear H1;

%% Second layer RELM
H2 = [T1 .1 * ones(size(T1,1),1)];
%clear T1;
A2 = H2 * b2;
A2 = mapminmax(A2);
clear b2;
beta2 = sparse_elm_autoencoder(A2, H2, 1e-3, 50)';
clear A2;
T2 = H2 * beta2;
fprintf(1, 'Layer 2: Max Val of Output %f Min Val %f\n', max(T2(:)), min(T2(:)) );
[T2, ps2] = mapminmax(T2', 0, 1);
T2 = T2';
clear H2;

%% Original ELM
H3 = [T2 .1 * ones(size(T2,1),1)];
%clear T2;
T3 = H3 * b3;
l3 = max(max(T3));
l3 = s / l3;
fprintf(1, 'Layer 3: Max Val of Output %f Min Val %f\n', l3, min(T3(:)) );
T3 = tansig(T3 * l3);
clear H3;

%% Finsh Training
% beta = ( T3' * T3 + eye(size(T3',1)) * (C) ) \ ( T3'  *  train_y );

beta = [];
threV = 1;
stopV = 1e-2;
for nout = 1 : size(train_y,2)
    %%
    beta0 = ( T3' * T3 + eye(size(T3',1)) * (C) ) \ ( T3'  *  train_y(:,nout) );
    
    for o = 1:20
        r = abs(T3 * beta0 - train_y(:,nout));
        w = ones(size(train_y,1), 1);
        w(r>threV) = threV ./ r(r>threV);
        betaTemp = ( T3' * (repmat(w,1,size(T3,2)) .* T3) + eye(size(T3',1)) * (C) ) ...
            \ ( T3' * (w .* train_y(:,nout)) );
        
        normV = norm(beta0-betaTemp);
        if o == 1
            %disp([nout, o, abs(max(beta0)-max(betaTemp)), normV, 1]);
            if normV < 1e-5 %norm == 0
                break;
            end
        else
            normR = (normVpre - normV) / normVpre;
            %disp([nout, o, abs(max(beta0)-max(betaTemp)), normV, normR]);
            if normR < stopV
                break;
            end
        end
        beta0 = betaTemp;
        normVpre = normV;
    end
    %%
    beta = [beta betaTemp];
end

Training_time = toc;
disp('Training has been finished!');
disp(['The Total Training Time is : ', num2str(Training_time), ' seconds' ]);

%% Calculate the training accuracy
xx = T3 * beta;
%clear T3;
yy = result_tra(xx);
train_yy = result_tra(train_y);
TrainingAccuracy = length(find(yy == train_yy)) / size(train_yy,1);
disp(['Training Accuracy is : ', num2str(TrainingAccuracy * 100), ' %' ]);

%% First layer feedforward
tic;
test_x = zscore( test_x' )';
HH1 = [ test_x .1 * ones( size(test_x,1), 1 ) ];
clear test_x;
TT1 = HH1 * beta1;
TT1 = mapminmax( 'apply', TT1' , ps1 )';
clear HH1;
%clear beta1;

%% Second layer feedforward
HH2 = [ TT1 .1 * ones( size(TT1,1), 1 ) ];
clear TT1;
TT2 = HH2 * beta2;
TT2 = mapminmax( 'apply', TT2' , ps2 )';
clear HH2;
%clear beta2;

%% Last layer feedforward
HH3 = [ TT2 .1 * ones( size(TT2,1) ,1 ) ];
clear TT2;
TT3 = tansig(HH3 * b3 * l3);
clear HH3;
clear b3;

%% Finsh Testing
x = TT3 * beta;
y = result_tra(x);
test_yy = result_tra(test_y);
TestingAccuracy = length(find(y == test_yy)) / size(test_yy,1);
clear TT3;
Testing_time = toc;

%% Calculate the testing accuracy
disp('Testing has been finished!');
disp(['The Total Testing Time is : ', num2str(Testing_time), ' seconds' ]);
disp(['Testing Accuracy is : ', num2str(TestingAccuracy * 100), ' %' ]);

