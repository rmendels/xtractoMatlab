function erddapStruct = createOutputStructure(parameter, track)
% Internal function to create blank structure to store the
% resutls from xtracto.m
%
% INPUT:  
%   parameter - parameter name from xtracto.m
%   track - requested track from xtracto.m
%
% OUTPUT: 
%    unpopulated structure where each field is of the same length
%    as track
%
% FIELDS:
%     mean_parameter - mean of the parameter within the bounds of that time period
%     std_parameter - standard deviation of the parameter within the bounds of that time period
%     n - number of observations in the extract at each time period
%     satellite_date - time of the actual request to the dataset at ech time period
%     requested_xName_min - minimun x-axis value in request at each time period
%     requested_xName_max - maximum x-axis value in request at each time period
%     requested_yName_min - minimun y-axis value in request at each time period
%     requested_yName_max - maximum y-axis value in request at each time period
%     requested_zName_min - minimun z-axis value in request at each time period
%     requested_zName_max - maximum z-axis value in request at each time period
%     requested_date - date given in track
%     median - median of the parameter within the bounds of that time period
%     mad - Mean absolute deviation of the parameter within the bounds of that time period

    f_names = string(fieldnames(track));
    track_length = numel(track.(f_names(1)));
    mean_name = strcat('mean', '_', parameter);
    std_name = strcat('std', '_', parameter);
    x_name_min = strcat('requested_', f_names(1), '_min');
    x_name_max = strcat('requested_', f_names(1), '_max');
    y_name_min = strcat('requested_', f_names(2), '_min');
    y_name_max = strcat('requested_', f_names(2), '_max');
    z_name_min = strcat('requested_', f_names(3), '_min');
    z_name_max = strcat('requested_', f_names(3), '_max');
    erddapStruct = struct(mean_name, NaN(1, track_length ), std_name,  NaN(1, track_length ), ...
     'n', NaN(1, track_length ), 'satellite_date', strings(1, track_length), ...
    x_name_min, NaN(1, track_length ), x_name_max, NaN(1, track_length ),...
    y_name_min, NaN(1, track_length ), y_name_max, NaN(1, track_length ), ...
    z_name_min, NaN(1, track_length ), z_name_max, NaN(1, track_length ), ...
    'requested_date', strings(1, track_length), ...
    'median', NaN(1, track_length ), 'mad', NaN(1, track_length ) );
end


% Function to rename fields of a structure
function structOut = renameFields(structIn, oldNames, newNames)
    structOut = struct();
    for i = 1:length(oldNames)
        if isfield(structIn, oldNames{i})
            structOut.(newNames{i}) = structIn.(oldNames{i});
        end
    end
end
