function [ data, gender ] = readData_WVU( datapath, scanner )
% Funct : read fingerprint data and the label (age, gender, id) from dataset.
% Input : datapath - The store path of the dataset.
%         scanner - The sensor name, such as 'GreenBit', 'DigitalPersona', 
%                   'Orcathus'.
%         type - choice of 'train' or 'test'.
% Output: data - the fingerprint image cell {n, 1}.
%         gender - the gender information (n,1) (0 = female, 1 = male).
%         age - the age information (n, 1).
%         id - the ID information (n, 1).
% Author: Shu Wang, George Mason University.
% Data  : 2019-10-20.

%% path judgement.
if ~exist(datapath, 'dir') == 1
   disp('The dataset path does not exist.');
   return;
end

scannerList = {'CrossmatchR2', 'i3_digID_Mini', ...
    'L1_TouchPrint_5300', 'Seek', 'Ten_Print_Scans'};
if ~ismember(scanner, scannerList)
    disp('The scanner name error.');
    return;
end

cross = 0;
if strcmp('CrossmatchR2', scanner) == 1
    cross = 1;
end

%% output initialize.
data = [];
gender = [];
cnt = 0;

%% get ground truth.
xlsfile = [datapath, '/subject data - all.xlsx'];
[list_id, lg, ~] = xlsread(xlsfile, 1, 'A2:B5388');
list_g = zeros( size(list_id) );
for i = 1 : length(list_g)
    if 1 == strcmp(lg{i}, 'Female')
        list_g(i) = 0;
    else
        list_g(i) = 1;
    end
end

%% read data.
folderpath = [datapath, '/'];
folderdir = dir( folderpath );
disp(['Totally 500 users in ', folderpath]);

for iuser = 1 : 500   % idx = iuser + 2
    % get the user id.
    userid = folderdir(iuser + 2).name; disp(userid);
    gd = list_g( find(list_id == str2num(userid)) );
    % explore scanner folder.
    userpath = [folderpath, userid, '/Fingerprint/', scanner, '/'];
    if ~exist(userpath, 'dir') continue; end
    % explore sub folder.
    userdir = dir( userpath );
    subnum = size( userdir, 1 ) - 2;
    if (subnum == 0) continue; end
    userpath = [userpath, userdir(3).name, '/'];
    if (cross)
        userdir = dir( userpath );
        subnum = size( userdir, 1 ) - 2;
        if (subnum == 0) continue; end
        userpath = [userpath, userdir(3).name, '/'];
    end
    filedir = dir( [userpath, '*.bmp'] );
    subnum = size( filedir, 1 );
    if (subnum == 0) continue; end
    % get file name
    filename = [userpath, filedir(1).name];
    img = imread(filename);
    % store image.
    data{end+1, 1} = img;
    % store label.
    gender(end+1, 1) = gd;
    cnt = cnt + 1;
end

disp(['There are totally ', num2str(cnt), ' data.']);

end
