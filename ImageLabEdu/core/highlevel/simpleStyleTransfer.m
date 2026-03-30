function out = simpleStyleTransfer(I, alpha)
%SIMPLESTYLETRANSFER Stylisation légère par lissage + accentuation + pseudo-coloration.
    if nargin < 2, alpha = 0.5; end
    Iu = toUint8Image(I);
    if ndims(Iu) == 3
        G = im2double(safeIm2Gray(Iu));
    else
        G = im2double(Iu);
    end

    h = ones(5,5) / 25;
    smooth = conv2(G, h, 'same');
    detail = G - smooth;
    stylized = smooth + (1 + 2*alpha) * detail;
    stylized = mat2gray(stylized);

    if ndims(Iu) == 3
        out = Iu;
        out(:,:,1) = im2uint8(stylized);
        out(:,:,2) = im2uint8(min(max(0.8*stylized + 0.1, 0),1));
        out(:,:,3) = im2uint8(min(max(1.1*smooth, 0),1));
    else
        out = im2uint8(stylized);
    end
end
