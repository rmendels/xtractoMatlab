function matTime = erddap8601(erddapTime)
% Internal function to convert a vector of ISO times to Matlab time array
%
% INPUTS: erddapTime - array of times in ISO format
%
% OUTPUTS:
%         matTime - array of times as Matlab time objects
%

    timeSize = numel(erddapTime);
    matTime = zeros(1, timeSize);
    for i=1:timeSize(1)
        temp_time = erddapTime{i};
        matTime(1, i) = datenum8601(temp_time);
    end
    matTime=squeeze(matTime);
 end
    