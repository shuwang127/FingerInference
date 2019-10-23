function [ lbp_code ] = lbpMapping( lbp_map, P, type )
% Funct:  Mapping LBP map with different rules, reducing the bin number.
% Input:  lbp_map - LBP image.
%         P - the neighbour number.
%         type - the mapping rule.
%                'ri'   for rotation-invariant LBP
%                'u2'   for uniform LBP
%                'riu2' for uniform rotation-invariant LBP.
% Output: lbp_code - the converted LBP code.
% Author: Shu Wang, George Mason University.
% Date:   2019-10-22.

%% Check the type name.
typeList = {'ri', 'u2', 'riu2'};
if ~ismember(type, typeList)
    disp('Type error.');
    return;
end

%% Preprocess.
[size_y, size_x] = size(lbp_map);   % Get the image size.
lbp_map_d = double(lbp_map);
bin = 2 ^ P;                        % The bin number.

%% Rotation-invariant LBP.
if strcmp(type, 'ri')
    Mapping = (0:1:(bin-1))';       % Initialize the mapping. 
    % get mapping.
    for i = 1 : bin  % traverse (i-1) from 0 to (bin-1)
        m = Mapping(i);
        for j = 1 : (P-1)
            % Loop left shift m.
            bit_last = m - 2 * floor(m / 2); % get last bit.
            m = floor(m / 2) + bit_last * 2 ^ (P-1); % loop shift.
            % If m becomes smaller, update the mapping.
            if m < Mapping(i)
                Mapping(i) = m;
            end
        end
    end
    % reallocate the mapping.
    List = unique(Mapping);
    for i = 1 : bin
        m = Mapping(i);
        ind = find(List == m);
        Mapping(i) = ind - 1;
    end
    % mapping the LBP map.
    for i = 1 : size_y * size_x
        p = lbp_map_d(i);
        lbp_map_d(i) = Mapping(p + 1);
    end  
end


%% Uniform LBP.
if strcmp(type, 'u2')
    Mapping = (0:1:(bin-1))';       % Initialize the mapping. 
    % get mapping.
    for i = 1 : bin  % traverse (i-1) from 0 to (bin-1).
        m = Mapping(i);             % i-th mapping.
        m_bin = dec2bin(m, P);      % the binary code of i-th mapping.
        m_bin_shift = [m_bin(2:P), m_bin(1)]; % loop shift left.
        % count the number of changes.
        cnt = 0;
        for j = 1 : P
            if (m_bin(j) ~= m_bin_shift(j))
                cnt = cnt + 1;
            end
        end
        % if cnt >= 4, the mapping is in 'others' class.
        if (cnt >= 4)
            Mapping(i) = bin;
        end
    end
    % reallocate the mapping.
    List = unique(Mapping);
    for i = 1 : bin
        m = Mapping(i);
        ind = find(List == m);
        Mapping(i) = ind - 1;
    end
    % mapping the LBP map.
    for i = 1 : size_y * size_x
        p = lbp_map_d(i);
        lbp_map_d(i) = Mapping(p + 1);
    end  
end


%% Uniform rotation-invariant LBP.
if strcmp(type, 'riu2')
    Mapping = (0:1:(bin-1))';       % Initialize the mapping. 
    % get mapping.
    for i = 1 : bin  % traverse (i-1) from 0 to (bin-1)
        m = Mapping(i);
        for j = 1 : (P-1)
            % Loop left shift m.
            bit_last = m - 2 * floor(m / 2); % get last bit.
            m = floor(m / 2) + bit_last * 2 ^ (P-1); % loop shift.
            % If m becomes smaller, update the mapping.
            if m < Mapping(i)
                Mapping(i) = m;
            end
        end
        % get the binary code.
        m_bin = dec2bin(m, P);      % the binary code of i-th mapping.
        m_bin_shift = [m_bin(2:P), m_bin(1)]; % loop shift left.
        % count the number of changes.
        cnt = 0;
        for j = 1 : P
            if (m_bin(j) ~= m_bin_shift(j))
                cnt = cnt + 1;
            end
        end
        % if cnt >= 4, the mapping is in 'others' class.
        if (cnt >= 4)
            Mapping(i) = bin;
        end
    end
    % reallocate the mapping.
    List = unique(Mapping);
    for i = 1 : bin
        m = Mapping(i);
        ind = find(List == m);
        Mapping(i) = ind - 1;
    end
    % mapping the LBP map.
    for i = 1 : size_y * size_x
        p = lbp_map_d(i);
        lbp_map_d(i) = Mapping(p + 1);
    end  
end


%% Convert the output.
valmax = max(max(lbp_map_d));
if (valmax <= intmax('uint8'))
    lbp_code = uint8(lbp_map_d);
elseif (valmax <= intmax('uint16'))
    lbp_code = uint16(lbp_map_d);
else
    lbp_code = uint32(lbp_map_d);
end

end

