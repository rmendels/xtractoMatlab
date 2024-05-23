baseUrl = string('https://polarwatch.noaa.gov/erddap/');
dataID = string('noaacwVIIRSn20iceconcNP06Daily');
testInfo = erddapInfo(dataID, baseUrl);
xpos = [-99772.5 -400282.5];
ypos = [99772.5 400282.5];
zpos = [0 0];
tpos{1} = '2024-05-09T11:43:16Z';
tpos{2} = '2024-05-09T11:43:16Z';
testExtract = xtracto_3D(testInfo, 'IceConc', xpos, ypos, 'tpos', tpos, 'zpos', zpos, 'xName', 'rows', 'yName', 'cols', 'urlbase', baseUrl);
String proj4text "+proj=stere +lat_0=90 +lat_ts=70 +lon_0=-45 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs";
m_proj('stereographic', 'latitude', 90, 'lon', -45, 'radius', 70, 'rectbox', 'off', 'radius', '25', 'clongitude', -45);
EPSG:3413

m_proj('stereographic', 'lat', 90, 'long', -45, 'radius', 70);

% Step 1: Set up the projection
m_proj('stereographic', 'lat', 90, 'long', -45, 'radius', 25, 'rec', 'off');

% Example EPSG:3413 coordinates (X, Y)
x_coordinates = [1000000, 2000000, 3000000];  % example X coordinates in meters
y_coordinates = [1000000, 2000000, 3000000];  % example Y coordinates in meters

% Step 2: Convert the coordinates to latitude and longitude
[longitudes, latitudes] = m_xy2ll(x_coordinates, y_coordinates);

% Display the results
disp('Longitudes:');
disp(longitudes);
disp('Latitudes:');
disp(latitudes);




% Add m_map to the MATLAB path if not already added
% addpath('/path/to/m_map'); % Uncomment and modify this line as needed

% Define the stereographic projection with the specified parameters
m_proj('stereographic', ...
       'lat', 90, ...         % latitude of the center of projection
       'long', -45, ...       % central meridian
       'lat_ts', 70, ...      % latitude of true scale
       'k', 1, ...            % scale factor
       'x_0', 0, 'y_0', 0, ...% false easting and northing
       'a', 6378273, ...      % semi-major axis
       'b', 6356889.449);     % semi-minor axis

% Example EPSG:3413 coordinates (X, Y)
x_coordinates = [1000000, 2000000, 3000000];  % example X coordinates in meters
y_coordinates = [1000000, 2000000, 3000000];  % example Y coordinates in meters

% Convert the coordinates to latitude and longitude
[longitudes, latitudes] = m_xy2ll(x_coordinates, y_coordinates);

% Display the results
disp('Longitudes:');
disp(longitudes);
disp('Latitudes:');
disp(latitudes);


/Polarwatch/nsidc_g02202_v4/north/daily

<?xml version="1.0" encoding="UTF-8"?>
<catalog xmlns="http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dataset="http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0" name="Sea Ice Concentration Data" version="1.0">
  <service name="odap" serviceType="OPENDAP" base="/thredds/dodsC/"/>
  <dataset name="Sea Ice Concentration Data Aggregation" ID="sea_ice_concentration_aggregation">
    <aggregation type="joinExisting" dimName="time" recheckEvery="1 hour">
      <scan location="/u00/ice/" suffix=".nc" subdirs="false" regExp="seaice_conc_daily_nh_.*_f17_v04r00\.nc"/>
    </aggregation>
  </dataset>
</catalog>





xpos = [ -889533.8  -469356.9];
ypos = [622858.3  270983.4];
tpos{1} = '2023-01-30T00:00:00Z';
tpos{2} = '2023-01-30T00:00:00Z';
myURL =  'https://polarwatch.noaa.gov/erddap/';
myInfo = erddapInfo('noaacwVIIRSn20icethickNP06Daily', myURL);
extract = xtracto_3D(myInfo, 'IceThickness', xpos, ypos, 'tpos', tpos,  ...
                      'xName', 'rows', 'yName', 'cols');
                      
% Load GeographicLib
addpath('path_to_geographiclib'); % Adjust the path to where GeographicLib is located

% Define the projection strings
from_proj = '+proj=stere +lat_0=90 +lat_ts=70 +lon_0=-45 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs';
to_proj = '+proj=longlat +datum=WGS84 +no_defs';

% Create the projection objects
[~, proj_info] = proj(from_proj);
[~, proj_inv_info] = proj(to_proj);

% Your coordinates in polar stereographic
x_coords = rows; % Replace with your actual x-coordinates array
y_coords = cols; % Replace with your actual y-coordinates array

% Convert coordinates to latitude and longitude
[lon, lat] = projinv(proj_info, x_coords, y_coords);

% Display the results
disp(lon);
disp(lat);

% Example coordinates in EPSG:3413 (Polar Stereographic)
x_coords = [500000, 1000000]; % Replace with your actual x-coordinates array
y_coords = [500000, 1000000]; % Replace with your actual y-coordinates array

% Write the coordinates to a temporary file
inputFile = 'input_coords.txt';
outputFile = 'output_coords.txt';

fid = fopen(inputFile, 'w');
for i = 1:length(x_coords)
    fprintf(fid, '%f %f\n', x_coords(i), y_coords(i));
end
fclose(fid);

% Define the command for the PROJ library to transform coordinates
projCommand = ['proj -f "%.10f" +proj=stere +lat_0=90 +lat_ts=70 +lon_0=-45 +datum=WGS84 +units=m +to +proj=longlat +datum=WGS84 < ', inputFile, ' > ', outputFile];

% Execute the command
system(projCommand);

% Read the transformed coordinates from the output file
fid = fopen(outputFile, 'r');
transformedCoords = textscan(fid, '%f %f');
fclose(fid);

% Extract longitude and latitude
longitude = transformedCoords{1};
latitude = transformedCoords{2};

% Display the results
disp('Longitude:');
disp(longitude);
disp('Latitude:');
disp(latitude);

% Clean up temporary files
delete(inputFile);
delete(outputFile);

