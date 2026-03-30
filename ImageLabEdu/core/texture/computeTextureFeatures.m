function results = computeTextureFeatures(I, params)
%COMPUTETEXTUREFEATURES Extrait plusieurs familles de descripteurs texture.
% Sortie :
%   results.scalarFeatures : structure plate pour affichage rapide
%   results.detail         : structures détaillées par méthode

    Igray = toUint8Image(safeIm2Gray(I));
    Id = im2double(Igray);

    methods = string(params.methods);
    results = struct();
    results.scalarFeatures = struct();
    results.detail = struct();

    % Statistiques de base toujours disponibles
    if any(methods == "Statistiques")
        sf.mean = mean(Id(:));
        sf.variance = var(Id(:), 1);
        sf.std = std(Id(:), 1);
        sf.entropy = imageEntropyLocal(Igray);
        results.detail.statistics = sf;
        results.scalarFeatures.mean = sf.mean;
        results.scalarFeatures.variance = sf.variance;
        results.scalarFeatures.std = sf.std;
        results.scalarFeatures.entropy = sf.entropy;
    end

    if any(methods == "GLCM")
        glcmRes = computeGLCMFeatures(Igray, params.grayLevels, params.distance, params.direction);
        results.detail.glcm = glcmRes;
        appendStructPrefixed();
    end

    if any(methods == "LBP")
        lbpRes = computeLBPHist(Igray);
        results.detail.lbp = lbpRes;
        results.scalarFeatures.lbpMean = mean(lbpRes.histogram);
        results.scalarFeatures.lbpStd = std(lbpRes.histogram);
    end

    if any(methods == "Gabor")
        gaborRes = computeGaborFeaturesCustom(Igray);
        results.detail.gabor = gaborRes;
        results.scalarFeatures.gaborEnergyMean = mean(gaborRes.energy);
        results.scalarFeatures.gaborEnergyStd = std(gaborRes.energy);
    end

    if any(methods == "Fourier")
        fourierRes = computeFourierTextureFeatures(Igray);
        results.detail.fourier = fourierRes;
        results.scalarFeatures.fourierRadialMean = fourierRes.radialMean;
        results.scalarFeatures.fourierRadialStd = fourierRes.radialStd;
    end

    if any(methods == "Laws")
        lawsRes = computeLawsFeatures(Igray);
        results.detail.laws = lawsRes;
        fields = fieldnames(lawsRes.energy);
        for k = 1:numel(fields)
            results.scalarFeatures.(sprintf('laws_%s', fields{k})) = lawsRes.energy.(fields{k});
        end
    end

    if any(methods == "Wavelet")
        waveletRes = computeWaveletTextureFeatures(Igray);
        results.detail.wavelet = waveletRes;
        results.scalarFeatures.waveletApproxEnergy = waveletRes.approxEnergy;
        results.scalarFeatures.waveletDetailEnergy = waveletRes.detailEnergy;
    end

    function appendStructPrefixed
        f = fieldnames(glcmRes.scalarFeatures);
        for ii = 1:numel(f)
            results.scalarFeatures.(f{ii}) = glcmRes.scalarFeatures.(f{ii});
        end
    end
end

function H = imageEntropyLocal(I)
    counts = histcounts(I(:), 0:256);
    p = counts / sum(counts);
    p = p(p > 0);
    H = -sum(p .* log2(p));
end
