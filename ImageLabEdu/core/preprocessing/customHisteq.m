function out = customHisteq(I)
%CUSTOMHISTEQ Égalisation d'histogramme sans histeq.
    Iu8 = toUint8Image(I);
    if ndims(Iu8) == 3
        out = Iu8;
        for c = 1:3
            out(:,:,c) = customHisteqGray(Iu8(:,:,c));
        end
    else
        out = customHisteqGray(Iu8);
    end
end

function J = customHisteqGray(I)
    counts = histcounts(I(:), 0:256);
    cdf = cumsum(counts) / numel(I);
    lut = uint8(round(255 * cdf));
    J = lut(double(I)+1);
end
