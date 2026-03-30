function out = customEdgeDetect(I, method, threshold)
%CUSTOMEDGEDETECT Détection de contours basique sans edge().
    if nargin < 2, method = 'sobel'; end
    if nargin < 3, threshold = 0.2; end
    Igray = im2double(safeIm2Gray(I));

    switch lower(method)
        case 'sobel'
            Kx = [1 0 -1; 2 0 -2; 1 0 -1];
            Ky = [1 2 1; 0 0 0; -1 -2 -1];
        case 'prewitt'
            Kx = [1 0 -1; 1 0 -1; 1 0 -1];
            Ky = [1 1 1; 0 0 0; -1 -1 -1];
        otherwise
            error('Méthode de contour non prise en charge.');
    end

    Gx = conv2(Igray, Kx, 'same');
    Gy = conv2(Igray, Ky, 'same');
    mag = sqrt(Gx.^2 + Gy.^2);
    thr = threshold;
    if thr > 1, thr = thr / max(mag(:)); end
    BW = mag >= thr * max(mag(:));
    out = uint8(BW) * 255;
end
