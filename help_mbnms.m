function help_mbnms
% help_mbnms
% 
% This function provides help information for the DatasetName mbnms.mat.
% 
% Description: A dataset containing the latitudes and longitudes of a polygon
%              that define boundaries of the Monterey Bay National Marine Sanctuary.
% 
% Format:
% - Variable1: Longitude of track on (-180, 180)
% - Variable2: Latitude of track
% 
% Example usage:
% data = load('mbnms.mat');
% disp(data);

disp('Description: A dataset containing the latitudes and longitudes of a polygon that define boundaries of the Monterey Bay National Marine Sanctuary.');
disp('Source: https://sanctuaries.noaa.gov/library/imast_gis.html');
disp('- Variable1: Longitude of boundary on (-180, 180)');
disp('- Variable2: Latitude of boundary');
disp('Example usage:');
disp('data = load(''mbnms.mat'');');
disp('disp(data);');
end
