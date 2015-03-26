 function myURL = buildURL(dataStruct,lonBounds,latBounds,timeBounds,urlbase)
  lon1=lonBounds(1);
  lon2=lonBounds(2);
  lat1=latBounds(1);
  lat2=latBounds(2);
  time1=timeBounds(1);
  time2=timeBounds(2);
  hasAltitude=dataStruct.hasAlt;
  datasetname=dataStruct.datasetname;
  varname=dataStruct.varname;
if(hasAltitude);
    altitude=dataStruct.minAltitude;
    altitudeBound=strcat('[(',num2str(altitude),'):1:(',num2str(altitude),')]');
    myURL=strcat(urlbase,datasetname,'.mat?',varname,'[(',time1,'):1:(',time2,')]',...
        altitudeBound,...
        '[(',num2str(lat1),'):1:(',num2str(lat2),')]',...
        '[(',num2str(lon1),'):1:(',num2str(lon2),')]');
else
    myURL=strcat(urlbase,datasetname,'.mat?',varname,'[(',time1,'):1:(',time2,')]',...
     '[(',num2str(lat1),'):1:(',num2str(lat2),')]',...
     '[(',num2str(lon1),'):1:(',num2str(lon2),')]');
end ;    
