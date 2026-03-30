function H = computeHistogramLocal(I)
%COMPUTEHISTOGRAMLOCAL Calcule un histogramme 8 bits gris ou RGB.
    Iu8 = toUint8Image(I);
    H = struct();
    if ndims(Iu8) == 2
        H.isGray = true;
        H.gray = histcounts(Iu8(:), 0:256);
    else
        H.isGray = false;
        H.red   = histcounts(Iu8(:,:,1), 0:256);
        H.green = histcounts(Iu8(:,:,2), 0:256);
        H.blue  = histcounts(Iu8(:,:,3), 0:256);
    end
end
