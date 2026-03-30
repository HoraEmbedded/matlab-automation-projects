function results = computeFourierTextureFeatures(Igray)
%COMPUTEFOURIERTEXTUREFEATURES Mesures simples dans le domaine fréquentiel.
    I = im2double(Igray);
    F = abs(fftshift(fft2(I)));
    F = log1p(F);
    [m,n] = size(F);
    [X,Y] = meshgrid(1:n, 1:m);
    cx = (n+1)/2; cy = (m+1)/2;
    R = round(sqrt((X-cx).^2 + (Y-cy).^2));
    maxR = min(floor(min(m,n)/2), max(R(:)));
    radial = zeros(maxR+1,1);
    for r = 0:maxR
        mask = (R == r);
        radial(r+1) = mean(F(mask));
    end
    results.spectrum = F;
    results.radialProfile = radial;
    results.radialMean = mean(radial);
    results.radialStd = std(radial);
end
