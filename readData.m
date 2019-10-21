function [ data, gender, age, id ] = readData( datapath, scanner, type )
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

scannerList = {'GreenBit', 'DigitalPersona', 'Orcathus'};
if ~ismember(scanner, scannerList)
    disp('The scanner name error.');
    return;
end

typeList = {'train', 'test'};
if ~ismember(type, typeList)
    disp('The scanner name error.');
    return;
end

%% output initialize.
data = [];
gender = [];
age = [];
id = [];
cnt = 0;

%% read data.
folderpath = [datapath, '/', type, scanner, '/'];
folderdir = dir( folderpath );
foldernum = size( folderdir, 1 ) - 2;
disp(['Totally ', num2str(foldernum), ' users in ', folderpath]);
for iuser = 1 : foldernum   % idx = iuser + 2
    % sparse the user information.
    username = folderdir(iuser + 2).name;
    userinfo = split(username, '_');
    userid = userinfo{1};
    if strcmp( scanner, 'GreenBit' )
        userage = userinfo{2};
        usergender = userinfo{3};
    else
        userage = userinfo{3};
        usergender = 1 - userinfo{2};   
    end
    % explore subfolder.
    userpath = [folderpath, username, '/Live/'];
    userdir = dir( userpath );
    subnum = size( userdir, 1 ) - 2;
    for isub = 1 : subnum  % idx = isub + 2
        subname = userdir(isub + 2).name;
        % explore different version.
        subpath = [userpath, subname, '/'];
        subdir = dir( subpath );
        imgnum = size( subdir, 1 ) - 2;
        for iimg = 1 : imgnum  % idx = iimg + 2
            imgname = subdir(iimg + 2).name;
            % explore images.
            imgpath = [subpath, imgname];
            img = imread(imgpath);
            % imshow(img);
            data{end+1, 1} = img;
            gender(end+1, 1) = str2num(usergender);
            age(end+1, 1) = str2num(userage);
            id(end+1, 1) = str2num(userid);
            cnt = cnt + 1;
        end
    end
end

disp(['There are totally ', num2str(cnt), ' ', type, ' data.']);

end
