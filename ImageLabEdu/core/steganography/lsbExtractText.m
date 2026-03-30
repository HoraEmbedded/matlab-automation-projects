function [message, info] = lsbExtractText(I, key)
%LSBEXTRACTTEXT Extrait le texte caché par la méthode LSB.
    if nargin < 2, key = ''; end
    Iu8 = toUint8Image(I);
    data = Iu8(:);
    if numel(data) < 32
        error('Image trop petite pour contenir un en-tête valide.');
    end

    lenBits = bitget(data(1:32), 1);
    lenBytes = uint8(bin2dec(reshape(char(lenBits+'0'), 8, 4).'));
    msgLen = typecast(lenBytes(:).', 'uint32');
    msgLen = double(msgLen);

    totalBits = 32 + msgLen * 8;
    if totalBits > numel(data)
        error('Longueur de message incohérente ou image non stéganographiée.');
    end

    msgBits = bitget(data(33:32+msgLen*8), 1);
    msgBytes = uint8(bin2dec(reshape(char(msgBits+'0'), 8, msgLen).'));
    msgBytes = xorCipherUint8(msgBytes, key);
    message = char(msgBytes(:))';

    info = struct('messageLength', msgLen);
end
