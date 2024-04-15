function result = dynamicFunctionCall(funcName, datasetInfo, parameter, erddapCoord)
    % varargin contains any additional arguments such as 'tpos', tpos, etc.

    % Start with the fixed arguments that are always present
    f_names = string(fieldnames(erddapCoord));
    coordCell = struct2cell(erddapCoord);
    args = {datasetInfo, parameter, coordCell{1}, coordCell{2}};
 
    if ((numel(f_names) > 2))
        % check if next coordinate is time
        if(strcmp(f_names(3), 'time'))
            args{end+1} = 'tpos';
            args{end+1} = erddapCoord.time;
        else
            args{end+1} = 'zpos';
            args{end+1} = coordCell{3};
        end
        if ((numel(f_names) > 3))
            args{end+1} = 'tpos';
            args{end+1} = erddapCoord.time;
        end
    end
    % Append any additional arguments passed to this function
    save('args.mat','args');

    % Call the target function using feval
    result = feval(funcName, args{:});
end
