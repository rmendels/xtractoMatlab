function subsetData = extractSubset(extract, erddapCoords1)
    f_names = string(fieldnames(erddapCoords1));
    f_names1 = string(fieldnames(extract));
    if (strcmp(f_names, 'time'))
        erddapCoords1.time = string(erddapCoords1.time);
    end
    no_fields =  numel(f_names);
    if (numel(extract.(f_names(1))) == 1)
        index1 = [1 1];
    else
        [~, index1] = ismember(erddapCoords1.(f_names(1)), extract.(f_names(1)));
    end
    if (numel(extract.(f_names(2))) == 1)
        index2 = [1 1];
    else
       [~, index2] = ismember(erddapCoords1.(f_names(2)), extract.(f_names(2)));
    end
    indices = {index1(1):index1(2), index2(1):index2(2)};
    if (no_fields > 2)
        if (numel(extract.(f_names(3))) == 1)
           index3 = [1 1];
        else
            [~, index3] = ismember(erddapCoords1.(f_names(3)), extract.(f_names(3)));
        end
        indices = {index1(1):index1(2), index2(1):index2(2), index3(1):index3(2)};
    end
    if (no_fields == 4)
        if (numel(extract.(f_names(4))) == 1)
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