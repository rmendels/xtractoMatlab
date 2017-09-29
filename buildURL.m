 function myURL = buildURL(info, parameter, timeBounds, altitude, latBounds, lonBounds)
  urlbase = info.access.urlBase;
  lon1 = lonBounds(1);
  lon2 = lonBounds(2);
  lat1 = latBounds(1);
  lat2 = latBounds(2);
  datasetname = info.access.datasetID;
  varname = parameter;
  myURL=strcat(urlbase, 'griddap/', datasetname, '.mat?', varname);
  if (info.dimensions.time.exists)
      time1 = timeBounds(1);
      time2 = timeBounds(2);
      time_temp = strcat('[(', time1, '):1:(', time2, ')]');
      myURL = strcat(myURL, time_temp);
  end
  if (~isnan(altitude))
      altitude_temp = strcat('[(',num2str(altitude),'):1:(',num2str(altitude),')]');
      myURL = strcat(myURL, altitude_temp);
  end
  lat_temp = strcat('[(', num2str(lat1), '):1:(', num2str(lat2), ')]');
  lon_temp = strcat( '[(', num2str(lon1), '):1:(', num2str(lon2), ')]');
  myURL = strcat(myURL, lat_temp,  lon_temp);