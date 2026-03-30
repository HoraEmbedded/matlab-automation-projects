function feat = extractFeatureVector(I, method)
%EXTRACTFEATUREVECTOR Produit un vecteur de caractéristiques pour une image.
    method = string(method);
    Igray = toUint8Image(safeIm2Gray(I));
    params = struct('methods', {{'Statistiques','GLCM'}}, 'grayLevels', 16, 'distance', 1, 'direction', '0');

    switch method
        case "stats+glcm"
            R = computeTextureFeatures(Igray, params);
            feat = structToRow(R.scalarFeatures);

        case "lbp"
            L = computeLBPHist(Igray);
            feat = double(L.histogram(:))';

        case "gabor"
            G = computeGaborFeaturesCustom(Igray);
            feat = double(G.energy(:))';

        case "fusion"
            R = computeTextureFeatures(Igray, params);
            L = computeLBPHist(Igray);
            G = computeGaborFeaturesCustom(Igray);
            F = computeFourierTextureFeatures(Igray);
            feat = [structToRow(R.scalarFeatures), double(L.histogram(:))', double(G.energy(:))', F.radialMean, F.radialStd];

        otherwise
            error('Méthode de caractéristiques non reconnue.');
    end
end

function row = structToRow(S)
    vals = struct2cell(S);
    row = zeros(1, numel(vals));
    for k = 1:numel(vals)
        row(k) = double(vals{k});
    end
end
