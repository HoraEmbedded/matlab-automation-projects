function results = computeWaveletTextureFeatures(Igray)
%COMPUTEWAVELETTEXTUREFEATURES Ondelettes si disponibles, sinon pyramide gaussienne simple.
    I = im2double(Igray);
    if exist('dwt2', 'file') == 2
        [cA,cH,cV,cD] = dwt2(I, 'db2');
        results.method = 'dwt2';
        results.approxEnergy = mean(cA(:).^2);
        results.detailEnergy = mean([cH(:); cV(:); cD(:)].^2);
    else
        h = [1 4 6 4 1] / 16;
        low = conv2(conv2(I, h, 'same'), h', 'same');
        high = I - low;
        results.method = 'gaussian-pyramid-fallback';
        results.approxEnergy = mean(low(:).^2);
        results.detailEnergy = mean(high(:).^2);
    end
end
