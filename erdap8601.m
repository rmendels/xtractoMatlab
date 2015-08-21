function matTime=erdap8601(erddapTime)
timeSize=size(erddapTime);
matTime=zeros(timeSize(1),1);
for i=1:timeSize(1);
    matTime(i,1)=datenum8601(erddapTime(i,1:end));
end;
matTime=squeeze(matTime);
    