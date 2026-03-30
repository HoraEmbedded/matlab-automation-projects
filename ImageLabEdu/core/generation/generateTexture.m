function out = generateTexture(params)
%GENERATETEXTURE Répartiteur des méthodes de génération de texture.
    method = string(params.method);
    switch method
        case "Aléatoire"
            out = textureRandom(params.width, params.height, params.contrast);
        case "Périodique"
            out = texturePeriodic(params.width, params.height, params.regularity, params.contrast, params.granularity);
        case "Paramétrique"
            out = textureParametric(params.width, params.height, params.regularity, params.contrast, params.granularity);
        case "Par exemple"
            if isempty(params.exampleImage)
                error('Une image d''exemple est requise.');
            end
            out = textureExampleQuilt(params.exampleImage, params.width, params.height, max(8, round(params.granularity*4)));
        case "Par patchs"
            if isempty(params.exampleImage)
                error('Une image d''exemple est requise.');
            end
            out = textureExampleQuilt(params.exampleImage, params.width, params.height, max(16, round(params.granularity*8)));
        otherwise
            error('Méthode de génération de texture non reconnue.');
    end
end
