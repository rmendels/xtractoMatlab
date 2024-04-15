function erddapStruct = populateStruct(erddapStruct,  innerData, erddapCoords1, innerDim, t_value, counter)
    f_names = string(fieldnames(erddapStruct));
    f_names1 = string(fieldnames(erddapCoords1));
    disp(f_names)
    disp(f_names1)
%    save('track_prob.mat', 'innerData', 'erddapCoords1', 'innerDim', 't_value')
    nobs = sum(~isnan(innerData), 'all');
    mean_value = mean(innerData, 'all', 'omitnan');
    std_dev = std(innerData, 0,  'all', 'omitnan');
    median_value = median(innerData,  'all', 'omitnan');
    mad_value = mad(innerData(:));
    erddapStruct.(f_names(1))(counter) = mean_value;
    erddapStruct.(f_names(2))(counter) = std_dev;
    erddapStruct.n(counter) = nobs;
    if(any(strcmp(f_names1, 'time')))
        disp('here')
        erddapStruct.satellite_date(counter) = erddapCoords1.time(1);
        erddapStruct.requested_date(counter) = innerDim.time(1);
    else
        erddapStruct.satellite_date(counter) = NaN;
        erddapStruct.requested_date(counter) =  t_value;
    end
    erddapStruct.(f_names(5))(counter) = innerDim.(f_names1(1))(1);
    erddapStruct.(f_names(6))(counter) = innerDim.(f_names1(1))(2);
    erddapStruct.(f_names(7))(counter) = innerDim.(f_names1(2))(1);
    erddapStruct.(f_names(8))(counter) = innerDim.(f_names1(2))(2);
    if(numel(f_names1) > 2)
       erddapStruct.(f_names(9))(counter) = innerDim.(f_names1(3))(1);
       erddapStruct.(f_names(10))(counter) = innerDim.(f_names1(3))(2);
    end
    erddapStruct.median(counter) = median_value;
    erddapStruct.mad(counter) = mad_value;
end
