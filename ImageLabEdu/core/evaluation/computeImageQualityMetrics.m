function metrics = computeImageQualityMetrics(A, B)
%COMPUTEIMAGEQUALITYMETRICS Calcule MSE, PSNR et SSIM (fallback inclus).
    A = im2double(toUint8Image(A));
    B = im2double(toUint8Image(B));
    if any(size(A) ~= size(B))
        error('Les images doivent avoir la même taille pour l''évaluation.');
    end

    mseVal = mean((A(:) - B(:)).^2);
    if mseVal < eps
        psnrVal = Inf;
    else
        psnrVal = 10 * log10(1 / mseVal);
    end

    if exist('ssim', 'file') == 2
        if ndims(A) == 3
            ssimVal = ssim(rgb2gray_local(B), rgb2gray_local(A));
        else
            ssimVal = ssim(B, A);
        end
    else
        ssimVal = ssimFallback(A, B);
    end

    metrics = struct('mse', mseVal, 'psnr', psnrVal, 'ssim', ssimVal);
end

function g = rgb2gray_local(I)
    if ndims(I) == 2
        g = I;
    else
        g = 0.2989 * I(:,:,1) + 0.5870 * I(:,:,2) + 0.1140 * I(:,:,3);
    end
end

function val = ssimFallback(A, B)
    A = rgb2gray_local(A);
    B = rgb2gray_local(B);
    K1 = 0.01; K2 = 0.03; L = 1;
    C1 = (K1*L)^2;
    C2 = (K2*L)^2;
    muA = mean(A(:));
    muB = mean(B(:));
    sigmaA2 = var(A(:), 1);
    sigmaB2 = var(B(:), 1);
    sigmaAB = mean((A(:)-muA).*(B(:)-muB));
    val = ((2*muA*muB + C1) * (2*sigmaAB + C2)) / ((muA^2 + muB^2 + C1) * (sigmaA2 + sigmaB2 + C2));
end
