%% track data example
% Marlin tag data and chla
load('Marlin38606.mat');
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
chla=double(squeeze(SeaWiFS.chlorophyll(1,:,:)));
makeMap(SeaWiFS.longitude-360, SeaWiFS.latitude, log(chla));

%MODIS chla for same bounds
tpos{1}='2003-01-16';
MODIS = xtracto_3D(xpos, ypos, tpos,'mhchlamday');
chla=double(squeeze(MODIS.chlorophyll(1,:,:)));
makeMap(MODIS.longitude-360, MODIS.latitude, log(chla));

% VIIS chla for same bounds
tpos{1} = '2012-01-15';
VIIRS = xtracto_3D(xpos, ypos, tpos, 'erdVH2chlamday');
chla=double(squeeze(VIIRS.chla(1,:,:)));
makeMap(VIIRS.longitude-360, VIIRS.latitude, log(chla));

%upwelling
xpos= [238 238];
ypos = [37 37];
tpos{1} = '2005-01-01';
tpos{2} = '2005-12-31';
ektrx = xtracto_3D(xpos,ypos,tpos,'erdlasFnTran6ektrx');
ektry = xtracto_3D(xpos,ypos,tpos,'erdlasFnTran6ektry');
upwelling  = upwell(ektrx.ektrx,ektry.ektry,152);

times=datenum(ektrx.time);
plot(times,upwelling);
datetick('x','mmm')

tpos{1} = '1977-01-01';
tpos{2} = '1977-12-31';
ektrx77 = xtracto_3D(xpos,ypos,tpos,'erdlasFnTran6ektrx');
ektry77 = xtracto_3D(xpos,ypos,tpos,'erdlasFnTran6ektry');
upwelling77  = upwell(ektrx77.ektrx,ektry77.ektry,152);
times77=datenum(ektrx77.time);
plot(times77,upwelling77);
datetick('x','mmm')

% wind stress comparison
xpos = [237 237];
ypos = [36 36];
tpos{1} = '2009-10-05';
tpos{2} = '2009-11-19';
ascat = xtracto_3D(xpos,ypos,tpos,'erdQAstress3daytauy');
quikscat = xtracto_3D(xpos,ypos,tpos,'erdQSstress3daytauy');
times=datenum(ascat.time);
plot(times,double(ascat.tauy),times, double(quikscat.tauy));
datetick('x','mmm');

% last times
xpos = [235 240];
ypos = [36 39];
tpos{1} = 'last-5';
tpos{2} = 'last';
poes = xtracto_3D(xpos,ypos,tpos,'agsstamday');
datetick('x','mmm')

for i=1:6;
   sst=double(squeeze(poes.sst(i,:,:)));
   subplot(3,2,i);
   makeMap(poes.longitude-360,poes.latitude,sst);
end;

%% xtractogon examples

% chla in sanctuary
load('mbnms.mat');
tpos{1} = '2014-09-01';
tpos{2} = '2014-10-01';
xpoly = mbnms(:,1);
ypoly = mbnms(:,2);
sanctchl = xtractogon(xpoly,ypoly,tpos,'erdVH2chlamday');
chla=double(squeeze(sanctchl.chla(1,:,:)));
makeMap(double(sanctchl.longitude), double(sanctchl.latitude), log(chla));

% sanctuary bathymetry
bathy = xtractogon(xpoly,ypoly,tpos,'ETOPO180');
depth=double(bathy.altitude);
depth(depth==0)=NaN;
makeMap(bathy.longitude, bathy.latitude, depth);

%getInfo examples
getInfo('mhchla8day');
getInfo('mbchla8day') ;

% searchData example
myList=cell(2,2);
myList(1,1:2)={'varname';'chl'}';
myList(2,1:2)={'datasetname';'mday'}';
searchData(mylist);



