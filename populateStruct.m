function erddapStruct = populateStruct(erddapStruct,  innerData, erddapCoords1, innerDim, t_value, counter)
    if (counter == 2)
      disp(innerDim)
    end
    f_names = string(fieldnames(erddapStruct));
    f_names1 = string(fieldnames(erddapCoords1));
    f_names2 = string(fieldnames(innerDim));  
    nobs = sum(~isnan(innerData), 'all');
    mean_value = mean(innerData, 'all', 'omitnan');
    std_dev = std(innerData, 0,  'all', 'omitnan');
    median_value = median(innerData,  'all', 'omitnan');
    mad_value = mad(innerData(:));
    erddapStruct.(f_names(1))(counter) = mean_value;
    erddapStruct.(f_names(2))(counter) = std_dev;
    erddapStruct.n(counter) = nobs;
    erddapStruct.median(counter) = median_value;
    erddapStruct.mad(counter) = mad_value;

    % let's go through coordinates
    % 
    for( i = 1:numel(f_names2))
        if(strcmp(f_names2(i), 'time'))
            if(any(strcmp(f_names1, 'time')))
                erddapStruct.satellite_date(counter) = erddapCoords1.time(1);
                erddapStruct.requested_date(counter) = innerDim.time(1);
            else
                erddapStruct.satellite_date(counter) = NaN;
                erddapStruct.requested_date(counter) =  t_value;
            end
        else
            coord_index = find(contains(f_names, f_names2(i)));
            index1 = coord_index(1);
            index2 = coord_index(2);
            erddapStruct.(f_names(index1))(counter) = innerDim.(f_names2(i))(1);
            erddapStruct.(f_names(index2))(counter) = innerDim.(f_names2(i))(2);
        end
    end
end
