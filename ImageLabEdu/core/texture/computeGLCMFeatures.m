function results = computeGLCMFeatures(Igray, numLevels, distance, directionDeg)
%COMPUTEGLCMFEATURES Mesures GLCM avec graycomatrix si disponible, sinon version custom.
    switch string(directionDeg)
        case "0",   offset = [0 distance];
        case "45",  offset = [-distance distance];
        case "90",  offset = [-distance 0];
        case "135", offset = [-distance -distance];
        otherwise, error('Direction GLCM invalide.');
    end

    if exist('graycomatrix', 'file') == 2
        glcm = graycomatrix(Igray, 'NumLevels', numLevels, 'Offset', offset, 'Symmetric', true);
        if exist('graycoprops', 'file') == 2
            props = graycoprops(glcm, {'Contrast','Correlation','Energy','Homogeneity'});
            contrast = props.Contrast;
            correlation = props.Correlation;
            energy = props.Energy;
            homogeneity = props.Homogeneity;
        else
            [contrast, correlation, energy, homogeneity] = computeProps(glcm(:,:,1));
        end
    else
        glcm = computeGLCMCustom(Igray, numLevels, offset);
        [contrast, correlation, energy, homogeneity] = computeProps(glcm);
    end

    p = glcm(:,:,1);
    p = p / max(sum(p(:)), eps);
    glcmEntropy = -sum(p(p>0) .* log2(p(p>0)));

    results.glcm = p;
    results.offset = offset;
    results.scalarFeatures = struct( ...
        'glcmContrast', contrast, ...
        'glcmCorrelation', correlation, ...
        'glcmEnergy', energy, ...
        'glcmHomogeneity', homogeneity, ...
        'glcmEntropy', glcmEntropy);
end

function [contrast, correlation, energy, homogeneity] = computeProps(P)
    [i,j] = ndgrid(1:size(P,1), 1:size(P,2));
    mu_i = sum(i(:) .* P(:));
    mu_j = sum(j(:) .* P(:));
    sigma_i = sqrt(sum(((i(:)-mu_i).^2) .* P(:)));
    sigma_j = sqrt(sum(((j(:)-mu_j).^2) .* P(:)));

    contrast = sum(((i(:)-j(:)).^2) .* P(:));
    energy = sum(P(:).^2);
    homogeneity = sum(P(:) ./ (1 + abs(i(:)-j(:))));
    if sigma_i < eps || sigma_j < eps
        correlation = 1;
    else
        correlation = sum(((i(:)-mu_i).*(j(:)-mu_j)) .* P(:)) / (sigma_i * sigma_j);
    end
end
