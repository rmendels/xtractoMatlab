function lon360 = is_long360(longitudes)
    lon360 = true;
    lon_test = any(longitudes < 0.);
    if (lon_test)
        lon360 = false; 
    end  
end