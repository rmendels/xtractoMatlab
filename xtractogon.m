function [extract, xlon, xlat, xtime] = xtractogon(info, parameter, xpoly, ypoly, varargin);
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


% read in polygon file
% set up vectors for call to xtracto
numvarargs = length(varargin);
tpos = NaN;
if numvarargs > 0
    tpos = varargin{1};
    if(~iscellstr(tpos))
        error('tpos must be a cell-array of ISO times');
    end
    tmin = tpos{1};
    tmax= tpos{2};
end

xmin = min(xpoly); 
xmax = max(xpoly);
ymin = min(ypoly);
ymax = max(ypoly);
xpos = [xmin xmax];
ypos = [ymin ymax];

% call xtracto to get data
extract = xtracto_3D(info, parameter, xpos, ypos, tpos);
names = fieldnames(extract);
xtime = NaN;
if (strmatch('time', names))
   size(extract.time) 
   nt = size(extract.time, 1);
   xtime = extract.time;
else
    nt = 1;
end
ny = size(extract.latitude);
nx = size(extract.longitude);

% make sure polygon is closed; if not, close it.
if (xpoly(end) ~= xpoly(1)) | (ypoly(end) ~= ypoly(1)) 
     xpoly(end+1) = xpoly(1);
     ypoly(end+1) = ypoly(1);
end

% make mask (1 = in or on), (nan = out)
[xlon xlat] = meshgrid(extract.longitude, extract.latitude);
[in on] = inpolygon(xlon, xlat, xpoly, ypoly);
mask2D = in | on;

mask4D = permute(repmat(mask2D, [1 1 1 nt]), [4 3 1 2]);
names = fieldnames(extract);

% apply mask to 4-D array
cmd = strcat('extract.', names{end}, '(~mask4D)=nan' );
junk = evalc(cmd);
%extract(~mask4D) =  nan;


% fin
