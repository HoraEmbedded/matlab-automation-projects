function out = textureRandom(width, height, contrast)
%TEXTURERANDOM Texture bruitée simple.
    if nargin < 3, contrast = 1; end
    I = rand(height, width);
    I = 0.5 + contrast * (I - 0.5);
    I = min(max(I,0),1);
    out = im2uint8(I);
end
