%% track data example
% Marlin tag data and chla
xpos = Marlin38606.lon';
ypos  = Marlin38606.lat';
tpos= Marlin38606.date;
tpos=datenum(tpos);
tpos = cellstr(datestr(tpos,'yyyy-mm-dd' ));
swchl = xtracto(xpos, ypos, tpos, 'swchla8day', .2, .2);

% Marlin Tag data and bathymetry
topo = xtracto(xpos,ypos,tpos,'ETOPO360',.1,.1)


%% gridded data examples
xpos = [235 240];
ypos = [36 39];
tpos = ['1998-01-01';'2014-11-30']; 

% Seawifs chla this will cause an error
SeaWiFS= xtracto_3D(xpos, ypos, tpos, 'swchlamday');

%this fixes the error
tpos{1} = '1998-01-16';
tpos{2} = 'last';

SeaWiFS= xtracto_3D(xpos, ypos, tpos, 'swchlamday');

%MODIS chla for same bounds
tpos{1}='2003-01-16';
MODIS = xtracto_3D(xpos, ypos, tpos,'mhchlamday');

% VIIS chla for same bounds
tpos{1} = '2012-01-15';
VIIRS = xtracto_3D(xpos, ypos, tpos, 'erdVH2chlamday');

%upwelling
xpos= [238 238];
ypos = [37 37];
tpos{1} = '2005-01-01';
tpos{2} = '2005-12-31';
ektrx = xtracto_3D(xpos,ypos,tpos,'erdlasFnTran6ektrx');
ektry = xtracto_3D(xpos,ypos,tpos,'erdlasFnTran6ektry');
upwelling  = upwell(ektrx.ektrx,ektry.ektry,152);
tpos{1} = '1977-01-01';
tpos{2} = '1977-12-31';
ektrx77 = xtracto_3D(xpos,ypos,tpos,'erdlasFnTran6ektrx');
ektry77 = xtracto_3D(xpos,ypos,tpos,'erdlasFnTran6ektry');
upwelling77  = upwell(ektrx77.ektrx,ektry77.ektry,152);

% wind stress comparison
xpos = [237 237];
ypos = [36 36];
tpos{1} = '2009-10-05';
tpos{2} = '2009-11-19';
ascat = xtracto_3D(xpos,ypos,tpos,'erdQAstress3daytauy');
quikscat = xtracto_3D(xpos,ypos,tpos,'erdQSstress3daytauy');

% last times
xpos = [235 240];
ypos = [36 39];
tpos{1} = 'last-5';
tpos{2} = 'last';
poes = xtracto_3D(xpos,ypos,tpos,'agsstamday');

