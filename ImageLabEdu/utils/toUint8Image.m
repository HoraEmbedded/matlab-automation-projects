function Iu8 = toUint8Image(I)
%TOUINT8IMAGE Convertit proprement toute image numérique en uint8.
    if isa(I, 'uint8')
        Iu8 = I;
    elseif isfloat(I)
        Iu8 = im2uint8(mat2gray(I));
    elseif isa(I, 'uint16')
        Iu8 = uint8(double(I) / 257);
    elseif isinteger(I)
        Iu8 = uint8(double(I) / double(intmax(class(I))) * 255);
    else
        error('Type image non géré.');
    end
end
