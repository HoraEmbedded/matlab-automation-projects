function glcm = computeGLCMCustom(I, numLevels, offset)
%COMPUTEGLCMCUSTOM Implémentation simplifiée de graycomatrix.
% I : image uint8 2D
% numLevels : nombre de niveaux
% offset : [dy dx]

    Iq = floor(double(I) / 256 * numLevels);
    Iq(Iq == numLevels) = numLevels - 1;

    [m,n] = size(Iq);
    glcm = zeros(numLevels, numLevels);
    dy = offset(1);
    dx = offset(2);

    for y = 1:m
        yy = y + dy;
        if yy < 1 || yy > m, continue; end
        for x = 1:n
            xx = x + dx;
            if xx < 1 || xx > n, continue; end
            i = Iq(y,x) + 1;
            j = Iq(yy,xx) + 1;
            glcm(i,j) = glcm(i,j) + 1;
        end
    end

    s = sum(glcm(:));
    if s > 0
        glcm = glcm / s;
    end
end
