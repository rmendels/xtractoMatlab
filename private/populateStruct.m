function erddapStruct = populateStruct(erddapStruct,  innerData, erddapCoords1, innerDim, t_value, counter)
%
% Internal function to populate output structure with the results from ech tme period
%
% INPUTS:
%        erddapStruct - output structure
%          FIELDS:
%          mean_parameter - mean of the parameter within the bounds of that time period
%          std_parameter - standard deviation of the parameter within the bounds of that time period
%          n - number of observations in the extract at each time period
%          satellite_date - time of the actual request to the dataset at ech time period
%          requested_xName_min - minimun x-axis value in request at each time period
%          requested_xName_max - maximum x-axis value in request at each time period
%          requested_yName_min - minimun y-axis value in request at each time period
%          requested_yName_max - maximum y-axis value in request at each time period
%          requested_zName_min - minimun z-axis value in request at each time period
%          requested_zName_max - maximum z-axis value in request at each time period
%          requested_date - date given in track
%          median - median of the parameter within the bounds of that time period
%          mad - Mean absolute deviation of the parameter within the bounds of that time period
%          innerData -  data extracd for that time period
%          erddapCoords1 - actual coordinates uses in ERDDAP™ request
%          innerDim - dataset dimensions
%          t_value - time of request
%          counter - position in structure
%
% OUTPUTS:
%         erddapStruct - updated structure
% 
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
    for(i = 1:numel(f_names2))
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
