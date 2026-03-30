function out = customMorphology(BW, operationName, seSize)
%CUSTOMMORPHOLOGY Morphologie binaire simple par convolution.
    if ~islogical(BW)
        BW = BW ~= 0;
    end
    se = true(seSize);
    nSe = numel(se);
    convMap = conv2(double(BW), double(se), 'same');

    switch operationName
        case 'Morphologie - dilatation'
            out = convMap > 0;
        case 'Morphologie - érosion'
            out = convMap == nSe;
        case 'Morphologie - ouverture'
            eroded = convMap == nSe;
            out = conv2(double(eroded), double(se), 'same') > 0;
        case 'Morphologie - fermeture'
            dilated = convMap > 0;
            out = conv2(double(dilated), double(se), 'same') == nSe;
        otherwise
            error('Opération morphologique non reconnue.');
    end
end
