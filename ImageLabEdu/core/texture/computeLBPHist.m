function results = computeLBPHist(Igray)
%COMPUTELBPHIST LBP avec extractLBPFeatures si dispo, sinon implémentation custom 8 voisins.
    if exist('extractLBPFeatures', 'file') == 2
        feat = extractLBPFeatures(Igray, 'Upright', true);
        histo = feat(:)';
        lbpImage = [];
    else
        [histo, lbpImage] = localLBP8(Igray);
    end
    results.histogram = histo;
    results.lbpImage = lbpImage;
end

function [histNorm, lbpImage] = localLBP8(I)
    I = double(I);
    [m,n] = size(I);
    lbpImage = zeros(m-2, n-2);
    weights = [1 2 4; 128 0 8; 64 32 16];
    for y = 2:m-1
        for x = 2:n-1
            patch = I(y-1:y+1, x-1:x+1);
            c = patch(2,2);
            bits = patch >= c;
            bits(2,2) = 0;
            lbpImage(y-1,x-1) = sum(bits(:) .* weights(:));
        end
    end
    h = histcounts(uint8(lbpImage(:)), 0:256);
    histNorm = h / sum(h);
end
