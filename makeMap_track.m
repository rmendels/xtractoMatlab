function makeMap_track(swchlExtract)
    % Ensure m_map is on the path
    % addpath('path_to_m_map');

    % Initialize the map
    figure;
    m_proj('Mercator', 'lon', [min(swchlExtract.requested_longitude_min) max(swchlExtract.requested_longitude_max)], ...
        'lat', [min(swchlExtract.requested_latitude_min) max(swchlExtract.requested_latitude_max)]);
    
    % Add grid and coastlines
    m_grid;
    m_gshhs_h('patch', [.7 .7 .7]); % Add coastlines

    % Handling NaNs: Plot points with NaN values as unfilled circles
    nanIndices = isnan(swchlExtract.mean_chlorophyll);
    m_line(swchlExtract.requested_longitude_min(nanIndices), swchlExtract.requested_latitude_min(nanIndices), ...
        'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none');

    % Normalize mean_chlorophyll excluding NaNs for colormap indexing
    validIndices = ~nanIndices;
    minChl = min(swchlExtract.mean_chlorophyll(validIndices));
    maxChl = max(swchlExtract.mean_chlorophyll(validIndices));
    chlNormalized = (swchlExtract.mean_chlorophyll(validIndices) - minChl) / (maxChl - minChl);
    
    % Generate a colormap and get color for each non-NaN point
    cmap = colormap(parula(256)); % Use 256 colors from the jet colormap
    validLongs = swchlExtract.requested_longitude_min(validIndices);
    validLats = swchlExtract.requested_latitude_min(validIndices);
    
    for i = 1:length(chlNormalized)
        colorIndex = ceil(chlNormalized(i) * (size(cmap, 1)-1)) + 1; % Ensure index is within colormap range
        m_line(validLongs(i), validLats(i), ...
            'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', cmap(colorIndex, :), 'MarkerSize', 5);
    end
    
    % Add a colorbar
    colorbar;
    caxis([minChl, maxChl]);
    title('Mean Chlorophyll Concentration');
end
