function [] = makeMap_grid(extract, time_period, varargin)
% function to map results from either 'xtracto_3D()' or 'xtratogon()'
%
% INPUTS:
%        extract - result from either 'xtracto_3D()' or 'xtratogon()'
%        time_period - which time perio to map
%        varargin - optional arguments
%                'projection' - map projection, default 'mercator'
%                'myFunc' - function to transform the data, default none
%                'c_map' - colormap to use in map,  default 'parula'
% 
% OUTPUT:
%        map of data
%
    inputInfo = inputParser;

    % Set the default values for the optional parameters.
    defaultProjName = string("mercator");
    defaultLambda = @(x) x;
    defaultColormap = string('parula');
    mustBeTextScalar = @(x) ischar(x) || (isstring(x) && isscalar(x));
    % Add optional name-value pairs
    addParameter(inputInfo, 'projection', defaultProjName, mustBeTextScalar);
    addParameter(inputInfo, 'myFunc', defaultLambda, @(x) isa(x, 'function_handle'));
    addParameter(inputInfo, 'c_map', defaultColormap, mustBeTextScalar);
    parse(inputInfo, varargin{:});
    projection = inputInfo.Results.projection;
    myFunc = inputInfo.Results.myFunc;
    c_map = inputInfo.Results.c_map;

    extract_names = string(fieldnames(extract));
    extract_size = size(extract_names);
    param_index = extract_size(1);
    param_name = extract_names(param_index); 
    hasTime = find(strcmp('time', extract_names));
    if (~isempty(hasTime))
        string(extract.time);
        temp_time = string(extract.time);
        time_index  = find(strcmp(time_period, temp_time));
        if (isempty(time_index))
            error_msg = strcat('request time ', time_period', ' not in extract');
            error(error_msg) 
        end
    end
    no_dims = size(size(extract.(param_name)));
    no_dims = ndims(extract.(param_name));
    indexing = repmat({':'}, 1, (no_dims));
    if (~isempty(hasTime))
        if( numel(string(extract.time)) > 1)
            indexing{1} = time_index; 
        end
    end
    parameter = extract.(param_name)(indexing{:}); 
    parameter = squeeze(parameter);
    parameter = myFunc(parameter);
    latitude = extract.latitude;
    longitude = extract.longitude;
    [Plg, Plt] = meshgrid(longitude, latitude);
    lat = [min(latitude) max(latitude)];
    lon = [min(longitude) max(longitude)];
    m_proj(projection, 'lon', lon, 'lat', lat);
    m_pcolor(Plg, Plt, parameter);
    shading flat;
    if (~strcmp(c_map, 'parula'))
        cmocean(c_map)
    end
    m_grid;
    m_gshhs_h('patch',[.7 .7 .7]);
    colorbar;

end
