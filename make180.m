function lonout=make180(lon)
  lonout=lon;
  ind=find(lon>180);
  lonout(ind)=lonout(ind)-360;
