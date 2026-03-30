function results = computeGaborFeaturesCustom(Igray)
%COMPUTEGABORFEATURESCUSTOM Réponses Gabor. Utilise imgaborfilt si dispo, sinon convolution custom.
    I = im2double(Igray);
    wavelengths = [4 8 16];
    orientations = [0 45 90 135];
    energy = zeros(numel(wavelengths) * numel(orientations), 1);
    idx = 1;
    for w = wavelengths
        for theta = orientations
            if exist('imgaborfilt', 'file') == 2
                mag = imgaborfilt(I, w, theta);
            else
                kernel = gaborKernel2D(w, theta, 0.5*w, 21);
                mag = abs(conv2(I, kernel, 'same'));
            end
            energy(idx) = mean(mag(:).^2);
            idx = idx + 1;
        end
    end
    results.wavelengths = wavelengths;
    results.orientations = orientations;
    results.energy = energy;
end

function g = gaborKernel2D(wavelength, orientationDeg, sigma, ksize)
    if mod(ksize,2) == 0, ksize = ksize + 1; end
    c = floor(ksize/2);
    [x,y] = meshgrid(-c:c, -c:c);
    theta = deg2rad(orientationDeg);
    xp = x*cos(theta) + y*sin(theta);
    yp = -x*sin(theta) + y*cos(theta);
    g = exp(-(xp.^2 + yp.^2)/(2*sigma^2)) .* cos(2*pi*xp/wavelength);
    g = g - mean(g(:));
end
