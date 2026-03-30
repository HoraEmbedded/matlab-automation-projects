function out = texturePeriodic(width, height, regularity, contrast, granularity)
%TEXTUREPERIODIC Texture périodique sinusoidale modulée.
    [X,Y] = meshgrid(1:width, 1:height);
    freq = max(granularity,1) / max(width,height);
    phase = 2*pi*rand();
    base = sin(2*pi*freq*X + phase) + cos(2*pi*freq*(1+regularity)*Y);
    noise = (1-regularity) * randn(height, width);
    I = base + 0.3 * noise;
    I = mat2gray(contrast * I);
    out = im2uint8(I);
end
