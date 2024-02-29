function myURL = buildURL(myStruct)
    % Initialize the URL
     myURL=strcat(urlbase, 'griddap/', datasetname, '.mat?', varname);
    
    % Get the field names of the input structure
    fieldNames = fieldnames(myStruct);
    
    % Loop through each field of the structure
    for i = 1:length(fieldNames)
        fieldName = fieldNames{i};
        fieldValue = myStruct.(fieldName);
        
        % Check if the field value is a cell array of size two
        if iscell(fieldValue) && numel(fieldValue) == 2
            % Extract values from the cell array
            value1 = fieldValue{1};
            value2 = fieldValue{2};
            % Concatenate the values into the specified format
            formattedStr = strcat('[(', value1, '):1:(', value2, ')]');
            myURL = strcat(myURL, formattedStr);
        % Check if the field value is a numeric array of size two
        elseif isnumeric(fieldValue) && numel(fieldValue) == 2
            % Convert numeric values to strings
            value1 = num2str(fieldValue(1));
            value2 = num2str(fieldValue(2));
            % Concatenate the values into the specified format
            formattedStr = strcat('[(', value1, '):1:(', value2, ')]');
            myURL = strcat(myURL, formattedStr);
        else
            % Optionally handle other cases or do nothing
            % For this version, we'll just copy the original value
             myURL = strcat(myURL, formattedStr);
        end
    end
end
