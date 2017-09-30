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
time = struct('name', 'time', 'exists', false, 'min', NaN, 'max', NaN);
altitude = struct('name', 'altitude', 'exists', false, 'min', NaN, 'max', NaN);
latitude = struct('name', 'latitude', 'exists', false, 'min', NaN, 'max', NaN, 'lat_south', true);
longitude = struct('name', 'longitude', 'exists', false, 'min', NaN, 'max', NaN, 'lon360', true);
[dim_index] = find(strcmp('dimension', tempInfo(:, 1)));
dim_names = tempInfo(dim_index, 2);
actual_range_index = find(strcmp('actual_range', tempInfo(:, 3)));
%  check all dimenisons, if exists get information
% time
dim_test = find(strcmp('time', dim_names));
if (~isempty(dim_test))
    time.exists = true;
    my_index = find(strcmp('time_coverage_start', tempInfo(:, 3)));
    time.min = tempInfo{my_index, 5};
    my_index = find(strcmp('time_coverage_end', tempInfo(:, 3)));
    time.max = tempInfo{my_index, 5};
end
dim_test = find(strcmp('altitude', dim_names));
if (~isempty(dim_test))
    altitude.exists = true;
    altitude_range = find(strcmp('altitude', tempInfo(actual_range_index, 2))); 
    temp_result = tempInfo{actual_range_index(altitude_range), 5};    
    comma_index = strfind(temp_result, ',');
    altitude.min = str2num(temp_result(1:comma_index - 1));
    altitude.max = str2num(temp_result(comma_index + 1:end));
end
dim_test = find(strcmp('latitude', dim_names));
if (~isempty(dim_test))
    latitude.exists = true;
    latitude_range = find(strcmp('latitude', tempInfo(actual_range_index, 2))); 
    temp_result = tempInfo{actual_range_index(latitude_range), 5};    
    comma_index = strfind(temp_result, ',');
    latitude.min = str2num(temp_result(1:comma_index - 1));
    latitude.max = str2num(temp_result(comma_index + 1:end));
    if (latitude.min > latitude.max)
        latitude.lat_south = false;
    end
end
dim_test = find(strcmp('longitude', dim_names));
if (~isempty(dim_test))
    longitude.exists = true;
    longitude_range = find(strcmp('longitude', tempInfo(actual_range_index, 2))); 
    temp_result = tempInfo{actual_range_index(longitude_range), 5};    
    comma_index = strfind(temp_result, ',');
    longitude.min = str2num(temp_result(1:comma_index - 1));
    longitude.max = str2num(temp_result(comma_index + 1:end));
    temp_lon = min(longitude.min, longitude.max);
    longitude.lon360 = true;
    lon_test = sum(temp_lon < 0.);
    if (lon_test >  0.)
        longitude.lon360 = false;
    end
end
dimensions = struct('time', time, 'altitude', altitude, 'latitude', latitude, 'longitude', longitude);
info = struct('access', access, 'dimensions', dimensions);