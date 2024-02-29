function [erddapCoords, newIndex] = findERDDAPcoord(dataCoordList, isotime, udtime, xcoordLim, ycoordLim, tcoordLim, zcoordLim, xName, yName, tName, zName, cross_dateline_180)
    % Initialize indices and coordinates with NaNs
    newxIndex = NaN(1,2);
    newyIndex = NaN(1,2);
    newTimeIndex = NaN(1,2);
    newzIndex = NaN; % Assuming a single value for z-index
    erddapXcoord = NaN(1,2);
    erddapYcoord = NaN(1,2);
    erddapTcoord = cell(1,2);
    erddapZcoord = NaN(1,2);
    
    % Helper function to adjust coordinates for crossing dateline
    function adjustedCoord = make180(coord)
        adjustedCoord = coord;
        if any(coord > 180)
            adjustedCoord(coord > 180) = coord(coord > 180) - 360;
        end
    end
    
    % Check and process x coordinates
    if isfield(dataCoordList, xName)
        temp_xlimit = xcoordLim;
        if cross_dateline_180
            temp_xlimit = make180(temp_xlimit);
        end
        [~, newxIndex(1)] = min(abs(dataCoordList.(xName) - temp_xlimit(1)));
        [~, newxIndex(2)] = min(abs(dataCoordList.(xName) - temp_xlimit(2)));
        erddapXcoord = dataCoordList.(xName)(newxIndex);
        % Edge effect adjustments
        if newxIndex(1) == 1 && abs(dataCoordList.(xName)(newxIndex(1)) - xcoordLim(1)) < 0.0001
            erddapXcoord(1) = xcoordLim(1);
        end
        if newxIndex(2) == length(dataCoordList.(xName)) && abs(dataCoordList.(xName)(newxIndex(2)) - xcoordLim(2)) < 0.0001
            erddapXcoord(2) = xcoordLim(2);
        end
    end
    
    % Check and process y coordinates
    if isfield(dataCoordList, yName)
        [~, newyIndex(1)] = min(abs(dataCoordList.(yName) - ycoordLim(1)));
        [~, newyIndex(2)] = min(abs(dataCoordList.(yName) - ycoordLim(2)));
        erddapYcoord = dataCoordList.(yName)(newyIndex);
        % Edge effect adjustments
        if newyIndex(1) == 1 && abs(dataCoordList.(yName)(newyIndex(1)) - ycoordLim(1)) < 0.0001
            erddapYcoord(1) = ycoordLim(1);
        end
        if newyIndex(2) == length(dataCoordList.(yName)) && abs(dataCoordList.(yName)(newyIndex(2)) - ycoordLim(2)) < 0.0001
            erddapYcoord(2) = ycoordLim(2);
        end
    end
    
    % Check and process t coordinates
    if isfield(dataCoordList, tName)
        [~, newTimeIndex(1)] = min(abs(udtime - tcoordLim(1)));
        [~, newTimeIndex(2)] = min(abs(udtime - tcoordLim(2)));
        erddapTcoord{1} = datestr(isotime(newTimeIndex(1)), 'yyyy-mm-ddTHH:MM:SS');
        erddapTcoord{2} = datestr(isotime(newTimeIndex(2)), 'yyyy-mm-ddTHH:MM:SS');
    end
    
    % Check and process z coordinates
    if isfield(dataCoordList, zName)
        [~, newzIndex(1)] = min(abs(dataCoordList.(zName) - zcoordLim(1)));
        [~, newzIndex(2)] = min(abs(dataCoordList.(zName) - zcoordLim(2)));
        erddapZcoord = dataCoordList.(zName)(newzIndex);
        % Edge effect adjustments
        if newzIndex(1) == 1 && abs(dataCoordList.(zName)(newzIndex(1)) - zcoordLim(1)) < 0.0001
            erddapZcoord(1) = zcoordLim(1);
        end
        if newzIndex(2) == length(dataCoordList.(zName)) && abs(dataCoordList.(zName)(newzIndex(2)) - zcoordLim(2)) < 0.0001
            erddapZcoord(2) = zcoordLim(2);
        end
    end
    
    % Compile results into structures
    erddapCoords = struct('X', erddapXcoord, 'Y', erddapYcoord, 'T', {erddapTcoord}, 'Z', erddapZcoord);
    newIndex = struct('X', newxIndex, 'Y', newyIndex, 'T', newTimeIndex, 'Z', newzIndex);
end
