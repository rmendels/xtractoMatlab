function lonout=make360(lon)
%
% Function to convert an array of longitudes to lie in (0, 360)
%
% INPUTS:
%       lon -  array of longitudes
%
% OUTPUTS:
%        lonout - a transformed array of longitudes all on (0, 360)
%

  lonout=lon;
  ind=find(lon<0);
  lonout(ind)=lonout(ind)+360;
