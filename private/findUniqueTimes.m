function [unique_times unique_req_time_pos]  = findUniqueTimes(trackTime, dataCoordList)
%
% Find unique times in a track
%
% INPUTS:
%       trackTime: the times in the track
%       dataCoordList: - dat coordinate values from calling getfileCoords()
%
% OUTPUTS:
%        unique_times: the unique times in the track
%        unique_req_time_pos: postion of each unique time in the track
%

    % convert times to udt times to do arithmetic
    trackTimeUDT = erddap8601(trackTime);
    % two cases - time is in the dataset
    if(isfield(dataCoordList, 'time'))
        datasetTimeUDT = erddap8601(dataCoordList.time);
        for i = 1:numel(trackTimeUDT)
            %[~, req_time_index(i)] = min(abs(datasetTimeUDT - trackTimeUDT(i)));
            [~, temp_index] = min(abs(trackTimeUDT(i) - datasetTimeUDT));
            request_time(i) = dataCoordList.time(temp_index);
        end
        [unique_times, unique_req_time_index, unique_req_time_pos] = unique(request_time);
    else
    % time is not a coordinate in the datasets
    % such as extracting bathymetry for animal movng through time
        [unique_times, unique_req_time_index, unique_req_time_pos] = unique(trackTime);
    end
end
