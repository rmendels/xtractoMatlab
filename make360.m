function lonout=make360(lon)
  lonout=lon;
  ind=find(lon<0);
  lonout(ind)=lonout(ind)+360;
