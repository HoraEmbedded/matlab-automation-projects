function out = textureParametric(width, height, regularity, contrast, granularity)
%TEXTUREPARAMETRIC Texture paramétrique granulée avec lissage contrôlé.
    I = randn(height, width);
    sigma = max(granularity / 2, 0.5);
    k = max(5, 2*ceil(3*sigma)+1);
    h = localGaussianKernel(k, sigma);
    smooth = conv2(I, h, 'same');
    mix = regularity * smooth + (1-regularity) * I;
    mix = mat2gray(contrast * mix);
    out = im2uint8(mix);
end

function h = localGaussianKernel(k, sigma)
    c = floor(k/2);
    [X,Y] = meshgrid(-c:c, -c:c);
    h = exp(-(X.^2+Y.^2)/(2*sigma^2));
    h = h / sum(h(:));
end
