function callDims = findTimeCoords(dataCoordList, unique_time, unique_req_time_pos, time_loop, track, xrad, yrad, zrad)
    unique_time_indices = find(unique_req_time_pos == time_loop);
    %track1 = track(unique_time_indices)
    xrad1 = xrad(unique_time_indices);
    yrad1 = yrad(unique_time_indices);
    zrad1 = zrad(unique_time_indices);
    f_names = string(fieldnames(track));
    temp_coord = track.(f_names(1))(unique_time_indices);
    temp_coord1 = min(temp_coord - (xrad1/2));
    temp_coord2 = max(temp_coord + (xrad1/2));
    callDims.(f_names(1)) = [temp_coord1   temp_coord2];
    temp_coord = track.(f_names(2))(unique_time_indices);
    temp_coord1 = min(temp_coord - (yrad1/2));
    temp_coord2 = max(temp_coord + (yrad1/2));
    callDims.(f_names(2)) = [temp_coord1   temp_coord2];
    if (~isempty(track.(f_names(3))))
        dimSize = numel(dataCoordList.(f_names(3)));
        if (dimSize == 1)  
            callDims.(f_names(3)) = [dataCoordList.(f_names(3))   dataCoordList.(f_names(3))]; 
        else   
            temp_coord = track.(f_names(3))(unique_time_indices);
            temp_coord1 = min(temp_coord - (zrad1/2));
            temp_coord2 = max(temp_coord + (zrad1/2));
            callDims.(f_names(3)) = [temp_coord1   temp_coord2];
        end
    end
    if (~isempty(track.(f_names(4))))
      callDims.time = [unique_time unique_time];
    end
end