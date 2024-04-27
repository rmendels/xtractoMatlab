function lonout=make180(lon)
%
% Function to convert an array of longitudes to lie in (-180, 180)
%
% INPUTS:
%       lon -  array of longitudes
%
% OUTPUTS:
%        lonout - a transformed array of longitudes all on (-180, 180)
%

  lonout=lon;
  ind=find(lon>180);
  lonout(ind)=lonout(ind)-360;
