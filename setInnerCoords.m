function callDims = setInnerCoords(track, extract_point_loc, ...
                         xrad, yrad, zrad)
% Internal function to set 'inner' coordianates from 'xtracto()' track
%
    xrad1 = xrad(extract_point_loc);
    yrad1 = yrad(extract_point_loc );
    if (~isempty(zrad)) 
        zrad1 = zrad(extract_point_loc );
    end
    f_names = string(fieldnames(track));
    temp_coord = track.(f_names(1))(extract_point_loc);
    callDims.(f_names(1)) = [(temp_coord - (xrad1/2))  (temp_coord + (xrad1/2))];
    temp_coord = track.(f_names(2))(extract_point_loc);
    callDims.(f_names(2)) = [(temp_coord - (yrad1/2))  (temp_coord + (yrad1/2))];
    if (~isempty(track.(f_names(3))))
       temp_coord = track.(f_names(3))(extract_point_loc);
       if (strcmp(f_names(3), 'time'))
           callDims.time = [temp_coord temp_coord];
       else
          temp_coord = track.(f_names(3))(extract_point_loc);
          callDims.(f_names(3)) = [(temp_coord - (zrad1/2))  (temp_coord + (zrad1/2))]; 
       end
    end
    if (~isempty(track.(f_names(4))))
        temp_coord = track.(f_names(4))(extract_point_loc);
        callDims.time = [temp_coord temp_coord]; 
    end      
end