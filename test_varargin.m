function test_varagin(info, parameter, xpos, ypos, varargin)
    % Create an instance of the inputParser class.
    p = inputParser;

    % Set the default values for the optional parameters.
    defaultXName = "Longitude";
    defaultYName = "Latitude";
    defaultZName = "Altitude"; 
    % Add optional name-value pairs
    % Note: If "tpos" and "zpos" have default values, add them similarly with default values
    addParameter(p, 'xName', defaultXName, @ischar);
    addParameter(p, 'yName', defaultYName, @ischar);
    addParameter(p, 'zName', defaultZName, @ischar);
    
    % For numerical parameters, if they have default values, initialize them similarly
    % Here assuming they don't have default values and thus not adding a default value
    % Example: addParameter(p, 'tpos', defaultTpos, @isnumeric);
    % Example: addParameter(p, 'zpos', defaultZpos, @isnumeric);
    addParameter(p, 'tpos', [], @iscellstr); % Assuming no default, will remain empty if not provided
    addParameter(p, 'zpos', [], @isnumeric); % Assuming no default, will remain empty if not provided

    % Parse the varargin input
    parse(p, varargin{:});

    % Extract the values
    xName = p.Results.xName;
    yName = p.Results.yName;
    zName = p.Results.zName;
    tpos = p.Results.tpos;
    zpos = p.Results.zpos;

    % Your function's main code starts here
    % Use xName, yName, zName, tpos, zpos as needed
end
