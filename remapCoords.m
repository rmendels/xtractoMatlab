function callDims = remapCoords(datasetInfo, callDims, dataCoordList,  xlen, ylen)
    % Initialize variables
    if nargin < 5, xlen = 0; end
    if nargin < 6, ylen = 0; end

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
