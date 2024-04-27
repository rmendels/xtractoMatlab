function makeMap_track(track_extract, varargin)
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
    f_name = string(fieldnames(track_extract));
    f_name = f_name(1);
    track_extract.(f_name) = myFunc(track_extract.(f_name));

    % Initialize the map
    figure;
    m_proj('Mercator', 'lon', [min(track_extract.requested_longitude_min) max(track_extract.requested_longitude_max)], ...
        'lat', [min(track_extract.requested_latitude_min) max(track_extract.requested_latitude_max)]);
    
    % Add grid and coastlines
    m_grid;
    m_gshhs_h('patch', [.7 .7 .7]); % Add coastlines

    % Handling NaNs: Plot points with NaN values as unfilled circles
    nanIndices = isnan(track_extract.(f_name));
    m_line(track_extract.requested_longitude_min(nanIndices), track_extract.requested_latitude_min(nanIndices), ...
        'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none');

    % Normalize mean_chlorophyll excluding NaNs for colormap indexing
    validIndices = ~nanIndices;
    minParm = min(track_extract.(f_name)(validIndices));
    maxParm = max(track_extract.(f_name)(validIndices));
    ParmNormalized = (track_extract.(f_name)(validIndices) - minParm) / (maxParm - minParm);
    
    % Generate a colormap and get color for each non-NaN point
    cmap = colormap(parula(256)); % Use 256 colors from the jet colormap
    if (strcmp(c_map, 'parula'))
      cmap = colormap(parula(256));
    else
      cmap = cmocean(c_map, 256);
    end
    validLongs = track_extract.requested_longitude_min(validIndices);
    validLats = track_extract.requested_latitude_min(validIndices);
    
    for i = 1:length(ParmNormalized)
        colorIndex = ceil(ParmNormalized(i) * (size(cmap, 1)-1)) + 1; % Ensure index is within colormap range
        m_line(validLongs(i), validLats(i), ...
            'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', cmap(colorIndex, :), 'MarkerSize', 5);
    end
    
    % Add a colorbar
    colormap(cmap);
    colorbar;
    clim([minParm, maxParm]);
end
