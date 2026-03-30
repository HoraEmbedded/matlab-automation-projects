function results = computeLawsFeatures(Igray)
%COMPUTELAWSFEATURES Calcule quelques énergies de filtres de Laws.
    I = im2double(Igray);
    L5 = [1 4 6 4 1];
    E5 = [-1 -2 0 2 1];
    S5 = [-1 0 2 0 -1];
    W5 = [-1 2 0 -2 1];
    R5 = [1 -4 6 -4 1];

    kernels = struct();
    kernels.L5E5 = L5' * E5;
    kernels.E5L5 = E5' * L5;
    kernels.S5S5 = S5' * S5;
    kernels.W5W5 = W5' * W5;
    kernels.R5R5 = R5' * R5;

    names = fieldnames(kernels);
    energy = struct();
    for k = 1:numel(names)
        resp = conv2(I, kernels.(names{k}), 'same');
        energy.(names{k}) = mean(abs(resp(:)));
    end
    results.energy = energy;
end
