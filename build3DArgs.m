function xtracto3DArgs = build3DArgs(dataInfo, parameter, erddapCoord)
    f_names = string(fieldnames(erddapCoord));
    xtracto3DArgs  =  cell(0, 0);
    xtracto3DArgs{1} = dataInfo;
    xtracto3DArgs{2} = parameter;
    xtracto3DArgs{3} = erddapCoord.(f_names(1));
    xtracto3DArgs{4} = erddapCoord.(f_names(2));
    xtracto3DArgs{5} = 'xName';
    xtracto3DArgs{6} = f_names(1);
    xtracto3DArgs{7} = 'yName';
    xtracto3DArgs{8} = f_names(2);
    arg_count = 8;
    if numel(f_names) > 2
        for i = 3, numel(f_names)
           arg_count = arg_count + 1;
           xtracto3DArgs{arg_count} = f_names(1);
           arg_count = arg_count + 1;
           xtracto3DArgs{arg_count} = erddapCoord.(f_names(i));         
        end
    end
end