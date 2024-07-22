function isoTimes = secondsToISO(myTimes)
% Internal function to convert seconds from base time to ISO time format
%
% INPUTS:
%       myTimes - times in seocnds from '1970-01-01T00:00:00Z'
% OUTPUTS:
%       isoTimes - times in ISO format
%

    % Define the base time as a datetime object (Unix epoch)
    baseTime = datetime('1970-01-01T00:00:00Z', 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    newTime = baseTime + seconds(myTimes);
    %isoTimes = datestr(newTime, 'yyyy-mm-ddTHH:MM:SSZ'); 
    newTime.Format = 'uuuu-MM-dd''T''HH:mm:ss''Z''';
    isoTimes = string(newTime);
end