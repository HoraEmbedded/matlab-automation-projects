function Igray = safeIm2Gray(I)
%SAFEIM2GRAY Conversion robuste RGB -> gris sans dépendre de rgb2gray.
    if isempty(I)
        error('Image vide.');
    end
    if ndims(I) == 2
        Igray = I;
        return;
    end
    if ndims(I) ~= 3 || size(I,3) < 3
        error('Format image non pris en charge pour la conversion en gris.');
    end
    Id = im2double(I(:,:,1:3));
    Igray = 0.2989 * Id(:,:,1) + 0.5870 * Id(:,:,2) + 0.1140 * Id(:,:,3);
    Igray = im2uint8(Igray);
end
