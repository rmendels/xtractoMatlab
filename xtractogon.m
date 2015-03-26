function [extract, xlon, xlat, xtime] = xtractogon(polyfile,tpos,id);
% 
% Function XTRACTOGON downloads a 3-D data chunk 
% and applies a two-D spatial mask along the t-axis.
%
% INPUTS:
% 
% tpos gives min/max time in matlab days (e.g., datenum (year,month,day))
% id - numerical or string code for remote data set - complete list is given
%          in the xtracto_3D_bdap.m 
% polyfile = xy vector file (space-delimitered lon lat, ) that defines
%             the polygon.  If it is not closed, the program will do this
%                           automatically.
%
%  OUTPUTS:
%  extract(t,z,y,x) = 4-Dimensional array containing desired data.
%  xlon, xlat, xtime - basis vectors of extract array.
%    For satellite data, the only index of z is 1, and z(1) = 0.  Th
%
%  Dependencies:  requires xtracto_3D_bdap.m
%    http://coastwatch.pfel.noaa.gov/xfer/xtracto/matlab
%
% CoastWatch
% 15 Mar 08
% DGF
%

% set up path where xtracto_3D_bdap.m resides
%path(path,'/u00/becker/mfiles');

% just in case someone inputs a numerical data id
if ~isstr(id)
  id = num2str(id);
end

% read in polygon file
a=load(polyfile);
xpoly = a(:,1);
ypoly = a(:,2);

% set up vectors for call to xtracto
xmin = min(xpoly); 
xmax = max(xpoly);
ymin = min(ypoly);
ymax = max(ypoly);
tmin = min(tpos);
tmax = max(tpos);

xpos = [xmin xmax];
ypos = [ymin ymax];

% call xtracto to get data
[extract xlon xlat xtime] = xtracto_3D(xpos,ypos,tpos,id);
[nt nz ny nx] = size(extract);

% make sure polygon is closed; if not, close it.
if (xpoly(end) ~= xpoly(1)) | (ypoly(end) ~= ypoly(1)) 
     xpoly(end+1)= xpoly(1);
     ypoly(end+1) = ypoly(1);
end

% make mask (1 = in or on), (nan = out)
[XLON XLAT] = meshgrid(xlon,xlat);
[IN ON] = inpolygon(XLON,XLAT,xpoly,ypoly);
mask2D = IN | ON;

mask4D = permute(repmat(mask2D,[1 1 1 nt]),[4 3 1 2]);

% apply mask to 4-D array
extract(~mask4D) =  nan;


% fin
