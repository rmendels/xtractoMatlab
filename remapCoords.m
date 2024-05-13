function callDims = remapCoords(datasetInfo, callDims, dataCoordList,  xlen, ylen)
%
% Internal function to remap longitudes from (0, 360) to (-180, 180)
%   or from (-180, 180) to (0, 360) to agree with that of the dataset
%
% INPUTS:
%       datasetInfo - result from calling 'erddapInfo()'
%       callDims - bounds given to any of the 'xtracto' functions
%       dataCoordList - list of coordinates of the dataset
%       xlen - if called from 'xtracto()' - given radii x-axis of extract
%       ylen - if called from 'xtracto()' - given radii y-axis of extract
%
% OUTPUTS:
%       callDims - longtiude dimension remapped to agree with dataset
%


    xlen_max = max(xlen) / 2;
    ylen_max = max(ylen) / 2;
    

    % Logic for longitude adjustment, assuming dataInfo is a struct
    if isfield(callDims, 'longitude')
        longitudes = dataCoordList.longitude;
        lon360 = is_lon360(longitudes);
        if (lon360) 
            callDims.('longitude') = make360(callDims.('longitude'));
        else 
            callDims.('longitude') = make180(callDims.('longitude'));
        end
    end
%    if isfield(callDims, 'time')
%        if(~isempty(callDims.time))
%            callDims.time(2)  = dataCoordList.time(end);
%        end
%   end
end
