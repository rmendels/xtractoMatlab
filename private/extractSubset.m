function subsetData = extractSubset(extract, erddapCoords1)
% Internal function used by xtracto.m
%
% In xtracto.m for each unique satellite time
% an extract is made for a box that includes the requests for all those instances 
% and this function then subsets from that download for the given instance.
%
% INPUTS
%    extract - the data from the large extract
%    erddapCoords1 - the ecoordinates for one of the time periods
% 
% OUTPUT
%   subsetData - an array with the subset of the data
%
    f_names = string(fieldnames(erddapCoords1));
    f_names1 = string(fieldnames(extract));
    if (strcmp(f_names, 'time'))
        erddapCoords1.time = string(erddapCoords1.time);
    end
    no_fields =  numel(f_names);
    if (isscalar(extract.(f_names(1))))
        index1 = [1 1];
    else
        [~, index1] = ismember(erddapCoords1.(f_names(1)), extract.(f_names(1)));
    end
    if (isscalar(extract.(f_names(2))))
        index2 = [1 1];
    else
       [~, index2] = ismember(erddapCoords1.(f_names(2)), extract.(f_names(2)));
    end
    indices = {index1(1):index1(2), index2(1):index2(2)};
    if (no_fields > 2)
        if (isscalar(extract.(f_names(3))))
           index3 = [1 1];
        else
            [~, index3] = ismember(erddapCoords1.(f_names(3)), extract.(f_names(3)));
        end
        indices = {index1(1):index1(2), index2(1):index2(2), index3(1):index3(2)};
    end
    if (no_fields == 4)
        if (isscalar(extract.(f_names(4))))
           index4 = [1 1];
        else
            [~, index4] = ismember(erddapCoords1.(f_names(4)), extract.(f_names(4)));
        end
        indices = {index1(1):index1(2), index2(1):index2(2), index3(1):index3(2), index4(1):index4(2)};
    end
    % Using a function handle to subset parameter dynamically
    %subsetFunc = @(varargin) extract.chlorophyll(varargin{:});
    subsetFunc = @(varargin) extract.(f_names1(end))(varargin{:});

    % Applying the dynamic indices
    subsetData = subsetFunc(indices{:});
end