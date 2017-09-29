function [] = makeMap(extract, time_period, varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
numvarargs = length(varargin);
myFunc_test = false;
if (numvarargs > 0)
    myFunc = varargin{1};
    myFunc_test = true;
end
temp_time = string(extract.time);
time_index  = find(strcmp(time_period, temp_time));
if (isempty(time_index))
    error_msg = strcat('request time ', time_period', ' not in extract');
    error(error_msg) 
end
extract_names = fieldnames(extract);
extract_size = size(extract_names);
param_index = extract_size(1);
param_name = extract_names{param_index}; 
parameter = extract.(param_name)(time_index, :, :);
parameter = squeeze(parameter);
if (myFunc_test)
    parameter = myFunc(parameter);
end
latitude = extract.latitude;
longitude = extract.longitude;
[Plg, Plt] = meshgrid(longitude, latitude);
lat = [min(latitude) max(latitude)];
lon = [min(longitude) max(longitude)];
m_proj('mercator', 'lon', lon, 'lat', lat);
m_pcolor(Plg, Plt, parameter);
shading flat;
m_grid;
m_gshhs_h('patch',[.7 .7 .7]);
colorbar;

end

