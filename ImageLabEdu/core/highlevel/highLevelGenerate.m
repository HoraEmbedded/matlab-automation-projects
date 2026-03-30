function out = highLevelGenerate(I, params)
%HIGHLEVELGENERATE Transformations "haut niveau" réalistes en MATLAB standard.
% Modes : stylisation simple, transfert histogramme, fusion texture-référence,
% accentuation fréquentielle.
    mode = string(params.mode);
    alpha = min(max(params.alpha, 0), 1);
    ref = params.referenceImage;

    switch mode
        case "Stylisation simple"
            out = simpleStyleTransfer(I, alpha);
        case "Transfert histogramme"
            if isempty(ref)
                error('Image de référence manquante.');
            end
            out = histogramTransferSimple(I, ref, alpha);
        case "Fusion texture-référence"
            if isempty(ref)
                error('Image de référence manquante.');
            end
            out = fuseTextureReference(I, ref, alpha);
        case "Accentuation fréquentielle"
            out = frequencyAccentuation(I, alpha);
        otherwise
            error('Mode de génération haut niveau non reconnu.');
    end
end

function out = histogramTransferSimple(I, ref, alpha)
    Iu = toUint8Image(I);
    Ru = toUint8Image(ref);
    if size(Iu,3) ~= size(Ru,3)
        Ru = repmat(safeIm2Gray(Ru), 1, 1, size(Iu,3));
        if ndims(Iu) == 2
            Ru = safeIm2Gray(ref);
        end
    end
    if ndims(Iu) == 2
        J = matchOneChannel(Iu, Ru);
    else
        J = Iu;
        for c = 1:3
            J(:,:,c) = matchOneChannel(Iu(:,:,c), Ru(:,:,c));
        end
    end
    out = im2uint8((1-alpha) * im2double(Iu) + alpha * im2double(J));
end

function J = matchOneChannel(I, R)
    cdfI = cumsum(histcounts(I(:), 0:256)); cdfI = cdfI / cdfI(end);
    cdfR = cumsum(histcounts(R(:), 0:256)); cdfR = cdfR / cdfR(end);
    lut = zeros(256,1,'uint8');
    for v = 1:256
        [~, idx] = min(abs(cdfI(v) - cdfR));
        lut(v) = uint8(idx-1);
    end
    J = lut(double(I)+1);
end

function out = fuseTextureReference(I, ref, alpha)
    A = im2double(toUint8Image(I));
    B = im2double(toUint8Image(ref));
    B = resizeToMatch(B, size(A));
    out = im2uint8((1-alpha)*A + alpha*B);
end

function out = frequencyAccentuation(I, alpha)
    Igray = im2double(safeIm2Gray(I));
    h = [0 -1 0; -1 5+4*alpha -1; 0 -1 0];
    J = conv2(Igray, h, 'same');
    out = im2uint8(mat2gray(J));
end

function B = resizeToMatch(B, szA)
    [m,n,~] = size(B);
    ma = szA(1); na = szA(2);
    rowIdx = min(round(linspace(1,m,ma)), m);
    colIdx = min(round(linspace(1,n,na)), n);
    B = B(rowIdx, colIdx, :);
end
