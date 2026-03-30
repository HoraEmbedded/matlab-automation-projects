function out = xorCipherUint8(dataIn, key)
%XORCIPHERUINT8 Chiffrement XOR simple d'un vecteur uint8.
    if isempty(key)
        out = dataIn;
        return;
    end
    keyBytes = uint8(char(key));
    if isempty(keyBytes)
        out = dataIn;
        return;
    end
    out = dataIn;
    for i = 1:numel(dataIn)
        out(i) = bitxor(dataIn(i), keyBytes(mod(i-1, numel(keyBytes)) + 1));
    end
end
