function erddapCoord = findERDDAPcoords(dataCoordList, callDims)
%
% Function to find the nearest dataset coordinates to those given in the callDims
%
% INPUTS:
%    dataCoordList: dataset coordinate values from calling getfileCoords()
%    callDims:  coordinate values given in initial function call
%
% OUTPUTS:
%    erddapCoord: closest coordinates is dataset to use in ERDDAP call

    coords = string(fieldnames(dataCoordList));
    callFields = string(fieldnames(callDims));
    for i = 1:numel(coords)  
        temp_limit = callDims.(coords(i));
        if(strcmp(coords(i), 'time'))
            udtime = erddap8601(dataCoordList.('time'));
            tcoord_dt = erddap8601(callDims.('time'));
            % Calculate absolute differences in time
           % Find the index of the minimum difference
            timeDiffs = abs(udtime - tcoord_dt(1));
            [~, newIndex] = min(timeDiffs);
            temp_time1 = string(dataCoordList.('time')(newIndex));
            timeDiffs = abs(udtime - tcoord_dt(2));
            [~, newIndex] = min(timeDiffs);
            temp_time2 = string(dataCoordList.('time')(newIndex));
            erddapCoord.time = [temp_time1 temp_time2];
         else
             if (isscalar(dataCoordList.(coords(i))))
                 erddapCoord1 = dataCoordList.(coords(i));
                 erddapCoord2 = dataCoordList.(coords(i));
             else
                  [~, newIndex] = min(abs(dataCoordList.(coords(i)) - temp_limit(1)));
                  erddapCoord1 = dataCoordList.(coords(i))(newIndex);
                  if newIndex == 1 && abs(dataCoordList.(coords(i))(newIndex) - temp_limit(1)) < 0.0001
                      erddapCoord1 = temp_limit(1);
                  end
                  [~, newIndex] = min(abs(dataCoordList.(coords(i)) - temp_limit(2)));
                  erddapCoord2 = dataCoordList.(coords(i))(newIndex);
                  if newIndex == length(dataCoordList.(coords(i))) && abs(dataCoordList.(coords(i))(newIndex) - temp_limit(2)) < 0.0001
                      erddapCoord2 = temp_limit(2);
                  end
             end
             erddapCoord.(coords(i)) = [erddapCoord1 erddapCoord2];
         end
    end             
end
