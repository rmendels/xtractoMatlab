function [unique_times unique_req_time_pos]  = findUniqueTimes(trackTime, dataCoordList)
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
    % time is not a coordinat in the datasets
        [unique_times, unique_req_time_index, unique_req_time_pos] = unique(trackTime);
    end
end
