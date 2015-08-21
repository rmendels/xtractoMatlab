function [] = makeMap( longitude, latitude, param )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
latitude=double(latitude);
longitude=double(longitude);
[Plg,Plt]=meshgrid(longitude,latitude);
lat=[min(latitude) max(latitude)];
lon=[min(longitude) max(longitude)];
m_proj('mercator','lon',lon, 'lat', lat);
m_pcolor(Plg,Plt,param);
shading flat;
m_grid;
m_gshhs_h('patch',[.7 .7 .7]);
colorbar;


end

