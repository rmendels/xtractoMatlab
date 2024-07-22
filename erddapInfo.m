function [ info ] = erddapInfo( datasetID, varargin )
% Functon to obtain necessary information about an ERDDAP datasetaaset
%
%  INPUT:  datasetID - datasetID of ERDDAP dataset to be accessed
%          varagin - Base URL of ERDDAP to use
%                    Default URL - 'https://coastwatch.pfeg.noaa.gov/erddap/'
% 
%  OUTPUT:  Struture containing fields
%              access:  contains base URL and datasetD
%              dimensionNames:  Names of dataset dmensions
%              dimensionMin: Minimum valid value for dimension
%              dimensionMax: Maximum valid value for dimension
%              variables: parameters in the dataset
%              cdm_type:  Common Data Model type,  used for checking in othe functions
%              class: 'erddapInfo' - used to check input to other functions is correct
%   
    options = weboptions;
    options.Timeout = Inf;
    
    baseURL = 'https://coastwatch.pfeg.noaa.gov/erddap/';
    numvarargs = length(varargin);
    if numvarargs > 0
        baseURL = varargin(1);
    end
    destfile = 'tempInfo.mat';
    myURL = string(strcat(baseURL,'info/', datasetID, '/index.csv'));
    tempInfo = webread(myURL, options);
    tempInfo = table2array(tempInfo(2:end,:));
    access = struct;
    access.urlBase = baseURL;
    access.datasetID = datasetID;
    [var_index] = find(strcmp('variable', tempInfo(:, 1)));
    var_names = tempInfo(var_index, 2);
    var_names= string(var_names);
    [dim_index] = find(strcmp('dimension', tempInfo(:, 1)));
    dim_names = string(tempInfo(dim_index, 2));
    no_dims = size(dim_names, 1);
    %dimMin = zeros(1, no_dims);
    %dimMax = zeros(1, no_dims);
    for i = 1:numel(dim_names)
        if (strcmp(dim_names(i), 'time'))
             compare_string = strcat(dim_names(i), '_coverage_start');
             my_index = find(strcmp(compare_string, tempInfo(:, 3)));
             %tempInfo{my_index, 5}
             dimMin(i)  = string(tempInfo{my_index, 5});
             compare_string = strcat(dim_names(i), '_coverage_end');
             my_index = find(strcmp(compare_string, tempInfo(:, 3)));
             dimMax(i) = string(tempInfo{my_index, 5});
        else
           actual_range_index = find(strcmp('actual_range', tempInfo(:, 3)));
           dim_range = find(strcmp(dim_names(i), tempInfo(actual_range_index, 2)));  
           temp_result = tempInfo{actual_range_index(dim_range), 5}; 
           comma_index = strfind(temp_result, ',');
           dimMin(i) = str2num(temp_result(1:comma_index - 1));
           dimMax(i) = str2num(temp_result(comma_index + 1:end));
        end
    end
    % get cdm type
    cdm_type_index = find(strcmp('cdm_data_type', tempInfo(:, 3)));
    cdm_type =  string(tempInfo(cdm_type_index, 5));
    class_name = 'erddapInfo';
    info = struct('access', access, 'dimensionNames', dim_names, 'dimensionMin', dimMin, 'dimensionMax', dimMax, 'variables', var_names, 'cdm_type', cdm_type, 'class', class_name);
end