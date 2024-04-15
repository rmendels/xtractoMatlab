function param_data = make_mask(xlon, ylat, xpoly, ypoly, param_data)
    [Xlon, Ylat] = meshgrid(xlon, ylat);
    inPoly = inpolygon(Xlon, Ylat, xpoly, ypoly);;
    param_data(~inPoly) = NaN;
end