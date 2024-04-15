function matTime = erdap8601(erddapTime)
    timeSize = numel(erddapTime);
    matTime = zeros(1, timeSize);
    for i=1:timeSize(1)
        temp_time = erddapTime{i};
        matTime(1, i) = datenum8601(temp_time);
    end
    matTime=squeeze(matTime);
 end
    