function parseargtest(varargin)

%define the acceptable named arguments and assign default values
Args=struct('Holdaxis',0, ...
'SpacingVertical',0.05,'SpacingHorizontal',0.05, ...
'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, ...
'MarginLeft',.1,'MarginRight',.1,'MarginTop',.1,'MarginBottom',.1, ...
'rows',[],'cols',[]);

%The capital letters define abrreviations.
% Eg. parseargtest('spacingvertical',0) is equivalent to parseargtest('sv',0)

Args=parseArgs(varargin,Args, ... 
% fill the arg-struct with values entered by the user, e.g.
% {'Holdaxis'}, ... %this argument has no value (flag-type)
% {'Spacing' {'sh','sv'}; 'Padding' {'pl','pr','pt','pb'}; 'Margin' {'ml','mr','mt','mb'}});

disp(Args)


function xtracto_3D(info, parameter, xpos, ypos, varargin)
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
    addParameter(p, 'tpos', [], @isnumeric); % Assuming no default, will remain empty if not provided
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
