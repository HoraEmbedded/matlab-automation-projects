function out = textureExampleQuilt(exampleImage, width, height, patchSize)
%TEXTUREEXAMPLEQUILT Synthèse simple par tuilage aléatoire de patchs.
% Version pédagogique. Pas de couture optimale.
    ex = toUint8Image(exampleImage);
    if ndims(ex) == 2
        channels = 1;
    else
        channels = size(ex,3);
    end
    [m,n,~] = size(ex);
    if patchSize >= min(m,n)
        patchSize = max(8, floor(min(m,n)/4));
    end
    out = zeros(height, width, channels, 'uint8');
    for y = 1:patchSize:height
        for x = 1:patchSize:width
            ry = randi([1, m-patchSize+1]);
            rx = randi([1, n-patchSize+1]);
            patch = ex(ry:ry+patchSize-1, rx:rx+patchSize-1, :);
            y2 = min(y+patchSize-1, height);
            x2 = min(x+patchSize-1, width);
            out(y:y2, x:x2, :) = patch(1:(y2-y+1), 1:(x2-x+1), :);
        end
    end
    if channels == 1
        out = out(:,:,1);
    end
end
