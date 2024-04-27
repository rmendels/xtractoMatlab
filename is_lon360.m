function lon360 = is_lon360(longitudes)
% 
% Function to test if an array of longitudes lie in (0, 360)
%
% INPUTS:
%       longitudes - an array of longitudes
%
% OUTPUTS:
%        true if on (0, 360),  false otherwise
%    

    lon360 = true;
    lon_test = any(longitudes < 0.);
    if (lon_test)
        lon360 = false; 
    end  
end