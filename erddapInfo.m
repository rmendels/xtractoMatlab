function [ info ] = erddapInfo( datasetID, varargin )
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here
    options = weboptions;
    options.Timeout = Inf;
    
    baseURL = 'https://upwell.pfeg.noaa.gov/erddap/';
    numvarargs = length(varargin);
    if numvarargs > 0
        baseURL = varargin(1);
    end
    destfile = 'tempInfo.mat';
    myURL = strcat(baseURL,'info/', datasetID, '/index.csv');
    tempInfo = webread(myURL, options);
    tempInfo = table2array(tempInfo(2:end,:));
    access = struct;
    access.urlBase = baseURL;
    access.datasetID = datasetID;
    %time = struct('name', 'time', 'exists', false, 'min', NaN, 'max', NaN);
    %altitude = struct('name', 'altitude', 'exists', false, 'min', NaN, 'max', NaN);
    %latitude = struct('name', 'latitude', 'exists', false, 'min', NaN, 'max', NaN, 'lat_south', true);
    %longitude = struct('name', 'longitude', 'exists', false, 'min', NaN, 'max', NaN, 'lon360', true);
    [dim_index] = find(strcmp('dimension', tempInfo(:, 1)));
    dim_names = tempInfo(dim_index, 2);
    actual_range_index = find(strcmp('actual_range', tempInfo(:, 3)));
    
    no_dims = size(dim_names, 1);
    dim_info(no_dims) = struct('name', '',  'min', NaN, 'max', NaN);
    for i = 1:size(dim_names, 1);
        dim_info(i).name =   dim_names(i);
        compare_string = strcat(dim_names(i), '_coverage_start');
        my_index = find(strcmp(compare_string, tempInfo(:, 3)));
        dim_info(i).min  = tempInfo{my_index, 5};
        compare_string = strcat(dim_names(i), '_coverage_end');
        my_index = find(strcmp(compare_string, tempInfo(:, 3)));
        dim_info(i).max  = tempInfo{my_index, 5};
    
    end
    info = struct('access', access, 'dimensions', m_info);