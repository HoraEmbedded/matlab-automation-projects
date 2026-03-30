function test_ImageLabEdu_core
%TEST_IMAGELABEDU_CORE Script de test rapide des fonctions cœur.
    fprintf('--- Test du cœur ImageLab Edu ---\n');
    I = imread('cameraman.tif');

    % Prétraitement
    P = preprocessImage(I, struct('operation', 'Filtre gaussien', 'param1', 5, 'param2', 1));
    assert(~isempty(P), 'Prétraitement vide');

    % Texture
    T = computeTextureFeatures(I, struct('methods', {{'Statistiques','GLCM','LBP'}}, 'grayLevels', 16, 'distance', 1, 'direction', '0'));
    assert(isfield(T, 'scalarFeatures'), 'Pas de résultats texture');

    % Génération
    G = generateTexture(struct('method', 'Périodique', 'width', 128, 'height', 128, 'regularity', 0.7, 'contrast', 1.0, 'granularity', 8, 'exampleImage', []));
    assert(all(size(G) == [128 128]), 'Texture générée invalide');

    % Haut niveau
    H = highLevelGenerate(I, struct('mode', 'Stylisation simple', 'alpha', 0.5, 'referenceImage', I));
    assert(~isempty(H), 'Transformation haut niveau vide');

    % Stéganographie
    [S, info] = lsbEmbedText(I, 'Bonjour MATLAB', 'cle'); %#ok<ASGLU>
    [msg, inf2] = lsbExtractText(S, 'cle'); %#ok<ASGLU>
    assert(strcmp(msg, 'Bonjour MATLAB'), 'Le message décodé est incorrect');

    % Évaluation
    Q = computeImageQualityMetrics(I, S);
    assert(isfield(Q, 'psnr') && isfield(Q, 'ssim'), 'Métriques manquantes');

    fprintf('Tous les tests cœur sont passés.\n');
end
