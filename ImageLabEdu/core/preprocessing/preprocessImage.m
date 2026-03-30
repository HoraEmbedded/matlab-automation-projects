function out = preprocessImage(I, params)
%PREPROCESSIMAGE Applique une opération de prétraitement.
% Dépendances : certaines branches utilisent Image Processing Toolbox.
% Alternatives intégrées : égalisation custom, contours custom, morphologie custom.

    if nargin < 2 || ~isstruct(params)
        error('Les paramètres de prétraitement sont invalides.');
    end

    op = string(params.operation);
    p1 = params.param1;
    p2 = params.param2;

    switch op
        case "Redimensionnement"
            scale = max(p1, 0.05);
            if exist('imresize', 'file') == 2
                out = imresize(I, scale);
            else
                out = resizeNearestNeighbor(I, scale);
            end

        case "Normalisation"
            out = im2uint8(mat2gray(I));

        case "Contraste"
            alpha = max(p1, 0);
            beta = p2;
            out = im2uint8(min(max(alpha * im2double(I) + beta/255, 0), 1));

        case "Égalisation histogramme"
            if exist('histeq', 'file') == 2
                if ndims(I) == 3
                    out = I;
                    for c = 1:size(I,3)
                        out(:,:,c) = histeq(I(:,:,c));
                    end
                else
                    out = histeq(I);
                end
            else
                out = customHisteq(I);
            end

        case "Filtre moyenneur"
            k = max(1, round(p1));
            h = ones(k,k) / (k*k);
            out = applyConvOrImfilter(I, h);

        case "Filtre médian"
            k = max(1, round(p1));
            if mod(k,2) == 0, k = k + 1; end
            if exist('medfilt2', 'file') == 2
                if ndims(I) == 3
                    out = I;
                    for c = 1:3
                        out(:,:,c) = medfilt2(I(:,:,c), [k k]);
                    end
                else
                    out = medfilt2(I, [k k]);
                end
            else
                out = manualMedianFilter(I, k);
            end

        case "Filtre gaussien"
            sigma = max(p2, 0.1);
            k = max(3, round(p1));
            if mod(k,2) == 0, k = k + 1; end
            h = gaussianKernel2D(k, sigma);
            out = applyConvOrImfilter(I, h);

        case "Contours"
            method = 'sobel';
            out = customEdgeDetect(I, method, p1);

        case "Seuillage"
            Igray = safeIm2Gray(I);
            thr = p1;
            if thr > 1
                thr = thr / 255;
            end
            out = uint8(im2double(Igray) >= thr) * 255;

        case {"Morphologie - dilatation", "Morphologie - érosion", "Morphologie - ouverture", "Morphologie - fermeture"}
            Igray = safeIm2Gray(I);
            BW = Igray > 127;
            seSize = max(1, round(p1));
            out = customMorphology(BW, char(op), seSize);
            out = uint8(out) * 255;

        otherwise
            error('Opération de prétraitement non reconnue : %s', op);
    end
end

function out = applyConvOrImfilter(I, h)
    if exist('imfilter', 'file') == 2
        if ndims(I) == 3
            out = I;
            for c = 1:3
                out(:,:,c) = imfilter(I(:,:,c), h, 'replicate');
            end
        else
            out = imfilter(I, h, 'replicate');
        end
    else
        out = convPerChannel(I, h);
    end
    out = cast(out, class(I));
end

function out = convPerChannel(I, h)
    Id = im2double(I);
    if ndims(Id) == 3
        out = zeros(size(Id));
        for c = 1:3
            out(:,:,c) = conv2(Id(:,:,c), h, 'same');
        end
    else
        out = conv2(Id, h, 'same');
    end
    out = im2uint8(mat2gray(out));
end

function out = resizeNearestNeighbor(I, scale)
    [m,n,channels] = size(I);
    m2 = max(1, round(m * scale));
    n2 = max(1, round(n * scale));
    rowIdx = min(round(linspace(1,m,m2)), m);
    colIdx = min(round(linspace(1,n,n2)), n);
    out = I(rowIdx, colIdx, 1:channels);
end

function out = manualMedianFilter(I, k)
    Iu8 = toUint8Image(I);
    pad = floor(k/2);
    if ndims(Iu8) == 3
        out = Iu8;
        for c = 1:3
            out(:,:,c) = localMedian2D(Iu8(:,:,c), pad);
        end
    else
        out = localMedian2D(Iu8, pad);
    end
end

function out = localMedian2D(I, pad)
    P = padarray_custom(I, pad);
    [m,n] = size(I);
    out = zeros(m,n,'uint8');
    w = 2*pad + 1;
    for i = 1:m
        for j = 1:n
            block = P(i:i+w-1, j:j+w-1);
            out(i,j) = median(block(:));
        end
    end
end

function P = padarray_custom(I, pad)
    [m,n] = size(I);
    P = zeros(m + 2*pad, n + 2*pad, class(I));
    P(pad+1:pad+m, pad+1:pad+n) = I;
    P(1:pad, pad+1:pad+n) = repmat(I(1,:), pad, 1);
    P(pad+m+1:end, pad+1:pad+n) = repmat(I(end,:), pad, 1);
    P(:, 1:pad) = repmat(P(:,pad+1), 1, pad);
    P(:, pad+n+1:end) = repmat(P(:,pad+n), 1, pad);
end

function h = gaussianKernel2D(k, sigma)
    c = floor(k/2);
    [X,Y] = meshgrid(-c:c, -c:c);
    h = exp(-(X.^2 + Y.^2) / (2*sigma^2));
    h = h / sum(h(:));
end
