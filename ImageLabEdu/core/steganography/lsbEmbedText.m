function [stego, info] = lsbEmbedText(I, message, key)
%LSBEMBEDTEXT Cache un texte dans l'image via LSB.
% Supporte images gris et RGB uint8.
    if nargin < 3, key = ''; end
    Iu8 = toUint8Image(I);
    msgBytes = uint8(char(message));
    msgBytes = xorCipherUint8(msgBytes, key);

    msgLen = uint32(numel(msgBytes));
    lenBytes = typecast(msgLen, 'uint8');
    payload = [lenBytes(:); msgBytes(:)];
    payloadBits = reshape(dec2bin(payload, 8).'-'0', [], 1);

    capacityBits = numel(Iu8);
    maxChars = floor(capacityBits/8) - 4;
    if numel(payloadBits) > capacityBits
        error('Message trop long. Capacité max approximative : %d caractères.', maxChars);
    end

    data = Iu8(:);
    data(1:numel(payloadBits)) = bitset(data(1:numel(payloadBits)), 1, payloadBits);
    stego = reshape(data, size(Iu8));

    q = computeImageQualityMetrics(Iu8, stego);
    info = struct();
    info.messageLength = double(msgLen);
    info.maxChars = maxChars;
    info.psnr = q.psnr;
    info.ssim = q.ssim;
end
